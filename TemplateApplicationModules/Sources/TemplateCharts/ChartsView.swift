//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FHIRCharts
import Foundation
import SwiftUI


/// Displays a FHIR-based Chart in the Template Application
public struct ChartsView: View {
    public var body: some View {
        NavigationStack {
            List {
                Section("Step Count") {
                    FHIRObservationChart(code: "55423-8")
                        .navigationTitle(String(localized: "CHARTS_NAVIGATION_TITLE", bundle: .module))
                        .frame(minHeight: 300)
                        .padding(.vertical)
                }
            }
        }
    }
    
    
    public init() {}
}


struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
