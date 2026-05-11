//
//  Hedge_CratesApp.swift
//  Hedge Crates
//
//  Created by Fabs on 29/04/26.
//

import ClerkConvex
import ClerkKit
import ClerkKitUI
import ConvexMobile
import SwiftUI

@MainActor
let client = ConvexClientWithAuth(deploymentUrl: Env.convexCloudURL, authProvider: ClerkConvexAuthProvider())
let crateService = CrateService(deploymentUrl: Env.convexSiteURL)

@main
struct Hedge_CratesApp: App {
    init() {
        Clerk.configure(publishableKey: Env.clerkPublishableKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
