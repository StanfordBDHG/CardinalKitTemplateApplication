//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIR
import ModelsR4
import SwiftUI


public struct FHIRObservationChart: View {
    let code: String
    @EnvironmentObject var fhirStandard: FHIR
    @State var observations: [Observation] = []
    
    
    public var body: some View {
        QuantityObservationsChart(observations: observations)
            .task {
                loadObservations()
            }
            .onReceive(fhirStandard.objectWillChange.receive(on: RunLoop.main)) {
                _Concurrency.Task {
                    try? await _Concurrency.Task.sleep(for: .seconds(0.1))
                    loadObservations()
                }
            }
    }
    
    
    public init(code: String) {
        self.code = code
    }
    
    
    func loadObservations() {
        _Concurrency.Task {
            let observations = await fhirStandard.resources(resourceType: Observation.self)
            self.observations = observations.filter { observation in
                observation.code.coding?.contains(where: { coding in coding.code?.value?.string == code }) ?? false
            }
        }
    }
}
