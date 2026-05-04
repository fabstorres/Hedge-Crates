//
//  Hedge_CratesApp.swift
//  Hedge Crates
//
//  Created by Fabs on 29/04/26.
//

import SwiftUI
import ConvexMobile

let convex = ConvexClient(deploymentUrl: "https://rugged-pheasant-484.convex.cloud")
let crateService = CrateService(deploymentUrl: "https://rugged-pheasant-484.convex.site")

@main
struct Hedge_CratesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
