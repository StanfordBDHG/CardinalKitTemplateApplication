//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


extension Observation {
    private var chartDate: Date? {
        guard let effective else {
            return nil
        }
        
        switch effective {
        case let .dateTime(dateTime):
            return try? dateTime.value?.asNSDate()
        case let .instant(instant):
            return try? instant.value?.asNSDate()
        case let .period(period):
            return try? period.end?.value?.asNSDate()
        case let .timing(timing):
            return try? timing.event?.last?.value?.asNSDate()
        }
    }
    
    
    private var chartValue: Double? {
        guard let value else {
            return nil
        }
        
        switch value {
        case let .quantity(quantity):
            return quantity.value?.value?.decimal.primitivePlottable
        default:
            return nil
        }
    }
    
    
    private var chartUnit: String? {
        guard let value else {
            return nil
        }
        
        switch value {
        case let .quantity(quantity):
            return quantity.unit?.primitiveDescription
        default:
            return nil
        }
    }
    
    private var chartDescription: String? {
        code.coding?.first?.display?.primitiveDescription
    }
    
    
    var chartData: (Date, Double)? {
        guard let chartDate, let chartValue else {
            return nil
        }
        
        return (chartDate, chartValue)
    }
}
