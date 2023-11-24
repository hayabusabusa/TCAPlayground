//
//  NavigationApp.swift
//  Navigation
//
//  Created by Shunya Yamada on 2023/11/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct NavigationApp: App {
    static let store = Store(initialState: ContactsFeature.State()) {
        ContactsFeature()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
