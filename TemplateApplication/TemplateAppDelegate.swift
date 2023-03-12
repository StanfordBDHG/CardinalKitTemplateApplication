//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import FHIR
import FHIRToFirestoreAdapter
import FirebaseAccount
import FirebaseAuth
import FirestoreDataStorage
import FirestoreStoragePrefixUserIdAdapter
import HealthKit
import HealthKitDataSource
import HealthKitToFHIRAdapter
import Questionnaires
import Scheduler
import SwiftUI
import TemplateMockDataStorageProvider
import TemplateSchedule


class TemplateAppDelegate: CardinalKitAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
            if !CommandLine.arguments.contains("--disableFirebase") {
                // If debug scheme, use Firebase authentication emulator. If release scheme,
                // use cloud live authentication in production project
                #if DEBUG
                FirebaseAccountConfiguration(emulatorSettings: (host: "localhost", port: 9099))
                #else
                FirebaseAccountConfiguration()
                #endif
                firestore
            }
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
            QuestionnaireDataSource()
            MockDataStorageProvider()
            TemplateApplicationScheduler()
        }
    }
    
    
    private var firestore: Firestore<FHIR> {
        // If debug scheme, use Firebase firestore emulator. If release scheme,
        // use cloud live firestore in production project
        #if DEBUG
        Firestore(
            adapter: {
                FHIRToFirestoreAdapter()
                FirestoreStoragePrefixUserIdAdapter()
            },
            settings: .emulator // sets up firestore simulator
        )
        #else
        Firestore(
            adapter: {
                FHIRToFirestoreAdapter()
                FirestoreStoragePrefixUserIdAdapter()
            }
        )
        #endif
    }
    
    
    private var healthKit: HealthKit<FHIR> {
        HealthKit {
            CollectSample(
                HKQuantityType(.stepCount),
                deliverySetting: .anchorQuery(.afterAuthorizationAndApplicationWillLaunch)
            )
        } adapter: {
            HealthKitToFHIRAdapter()
        }
    }
}
