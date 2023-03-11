//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Account
import SwiftUI
import Views


public struct ProfileNavigationButton: View {
    @EnvironmentObject private var account: Account
    @State private var showProfile = false
    
    
    public var body: some View {
        List {
            if account.signedIn {
                Button(
                    action: {
                        showProfile.toggle()
                    }, label: {
                        ProfileImage()
                            .frame(height: 30)
                    }
                )
            }
        }
            .sheet(isPresented: $showProfile) {
                NavigationStack {
                    ProfileSummary()
                }
            }
            .onChange(of: account.signedIn) { signedIn in
                if !signedIn {
                    showProfile = false
                }
            }
    }
    
    
    public init() { }
}
