//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import Charts
import HealthKit
import HealthKitOnFHIR
import ModelsR4
import SwiftUI


struct QuantityObservationsChart: View {
    @SceneStorage("FHIRCharts.StatusChartScopeSelection") private var scopeSelection: ChartScope = .day
    
    
    let observations: [Observation]
    
    
    @State private var chartData: [(date: Date, value: Double)] = []
    @State private var maxValue: Double = 0.0
    
    
    var body: some View {
        VStack{
            Picker("FHIR_CHART_SCOPE_PICKER", selection: $scopeSelection.animation()) {
                ForEach(ChartScope.allCases) { scope in
                    Text(scope.localizedString)
                }
            }
                .pickerStyle(.segmented)
                .padding(.bottom, 8)
            Chart(chartData, id: \.date) { item in
                BarMark(
                    x: .value("FHIR_CHART_X_AXIS", item.date, unit: scopeSelection.presentationUnit),
                    y: .value("FHIR_CHART_Y_AXIS", item.value)
                )
            }
                .chartYScale(domain: 0...maxValue)
                .chartXAxis {
                    scopeSelection.axisContent
                }
                .onChange(of: scopeSelection) { newScopeSelection in
                    recalculateChartData(basedOn: newScopeSelection)
                }
                .task {
                    recalculateChartData(basedOn: scopeSelection)
                }
        }
    }
    
    
    func recalculateChartData(basedOn newScopeSelection: ChartScope) {
        chartData = newScopeSelection.group(
            observations
                .compactMap { observation in
                    observation.chartData
                }
            )
        maxValue = chartData
            .max {
                $0.value < $1.value
            }?
            .value ?? 0.0
    }
}


struct MyView_Previews: PreviewProvider {
    private static var observations: [Observation] = {
        return [
            createObservationFrom(
                type: HKQuantityType(.stepCount),
                quantity: .init(unit: .count(), doubleValue: 12.0),
                date: .now.addingTimeInterval(-60 * 60 * 1)
            ),
            createObservationFrom(
                type: HKQuantityType(.stepCount),
                quantity: .init(unit: .count(), doubleValue: 22.0),
                date: .now.addingTimeInterval(-60 * 60 * 2))
            ,
            createObservationFrom(
                type: HKQuantityType(.stepCount),
                quantity: .init(unit: .count(), doubleValue: 32.0),
                date: .now.addingTimeInterval(-60 * 60 * 3)
            ),
            createObservationFrom(
                type: HKQuantityType(.stepCount),
                quantity: .init(unit: .count(), doubleValue: 42.0),
                date: .now.addingTimeInterval(-60 * 60 * 4)
            ),
            createObservationFrom(
                type: HKQuantityType(.stepCount),
                quantity: .init(unit: .count(), doubleValue: 22.0),
                date: .now.addingTimeInterval(-60 * 60 * 5)
            ),
            createObservationFrom(
                type: HKQuantityType(.stepCount),
                quantity: .init(unit: .count(), doubleValue: 62.0),
                date: .now.addingTimeInterval(-60 * 60 * 6)
            )
        ]
    }()
    
    
    static var previews: some View {
        QuantityObservationsChart(observations: observations)
            .frame(minHeight: 200, maxHeight: 400)
            .padding()
    }
    
    
    static func createObservationFrom(
        type quantityType: HKQuantityType,
        quantity: HKQuantity,
        date: Date,
        metadata: [String: Any] = [:]
    ) -> Observation {
        let quantitySample = HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: date,
            end: date,
            metadata: metadata
        )
        return (try? quantitySample.resource.get(if: Observation.self))!
    }
}
