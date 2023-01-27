//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Charts
import Foundation
import SwiftUI


enum ChartScope: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case halfYear
    
    
    var id: Self {
        self
    }
    
    var localizedString: String {
        switch self {
        case .day: return String(localized: "FHIR_CHART_SCOPE_DAY", bundle: .module)
        case .week: return String(localized: "FHIR_CHART_SCOPE_WEEK", bundle: .module)
        case .month: return String(localized: "FHIR_CHART_SCOPE_MONTH", bundle: .module)
        case .halfYear: return String(localized: "FHIR_CHART_SCOPE_YEAR", bundle: .module)
        }
    }
    
    var earliestDate: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        switch self {
        case .day:
            return startOfDay
        case .week:
            return calendar.date(byAdding: .day, value: -6, to: startOfDay) ?? Date()
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: startOfDay) ?? Date()
        case .halfYear:
            let startOfMonth = calendar.date(bySetting: .day, value: 1, of: startOfDay) ?? Date()
            return calendar.date(byAdding: .month, value: -6, to: startOfMonth) ?? Date()
        }
    }
    
    var enumerationDateComponents: DateComponents {
        switch self {
        case .day:
            return DateComponents(minute: 0)
        case .week, .month:
            return DateComponents(hour: 0)
        case .halfYear:
            return DateComponents(day: 1)
        }
    }
    
    var presentationUnit: Calendar.Component {
        switch self {
        case .day:
            return .hour
        case .week, .month:
            return .day
        case .halfYear:
            return .month
        }
    }
    
    var axisContent: some AxisContent {
        switch self {
        case .day:
            return AxisMarks(values: .stride(by: .hour))
        case .week:
            return AxisMarks(values: .stride(by: .day))
        case .month:
            return AxisMarks(values: .stride(by: .weekOfYear))
        case .halfYear:
            return AxisMarks(values: .stride(by: .month))
        }
    }
    
    
    func group(_ data: [(date: Date, value: Double)]) -> [(date: Date, value: Double)] {
        var latestDate: Date = earliestDate
        var filteredData: [(Date, Double)] = []
        
        Calendar.current.enumerateDates(
            startingAfter: latestDate,
            matching: enumerationDateComponents,
            matchingPolicy: .nextTime
        ) { result, _, stop in
            guard let result else {
                stop = true
                return
            }
            
            let summedUpData = data
                .filter { element in
                    latestDate < element.date && element.date < result
                }
                .map {
                    $0.value
                }
                .reduce(0.0, +)
            filteredData.append((result, summedUpData))
            
            latestDate = result
            
            if result > Date() {
                stop = true
            }
        }
        
        return filteredData
    }
}
