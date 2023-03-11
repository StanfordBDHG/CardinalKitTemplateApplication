//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Account
import class FHIR.FHIR
import FirebaseAccount
import SwiftUI
import Views


struct ProfileImage: View {
    @EnvironmentObject private var firebaseAccount: FirebaseAccountConfiguration<FHIR>
    
    
    var body: some View {
        if let displayName = firebaseAccount.user?.displayName,
           let name = try? PersonNameComponents(displayName) {
            UserProfileView(name: name)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
        }
    }
}
