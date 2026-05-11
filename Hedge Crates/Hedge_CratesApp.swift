//
//  Hedge_CratesApp.swift
//  Hedge Crates
//
//  Created by Fabs on 29/04/26.
//

import SwiftUI
import ConvexMobile

let convex = ConvexClient(deploymentUrl: Env.convexCloudURL)
let crateService = CrateService(deploymentUrl: Env.convexSiteURL)

@main
struct Hedge_CratesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
