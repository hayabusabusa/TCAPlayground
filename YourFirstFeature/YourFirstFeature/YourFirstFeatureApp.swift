//
//  YourFirstFeatureApp.swift
//  YourFirstFeature
//
//  Created by Shunya Yamada on 2023/11/19.
//

import ComposableArchitecture
import SwiftUI

@main
struct MyApp: App {
    /// `Store` の作成は 1 回だけにしておく.
    ///
    /// ほとんどの場合は `Scene` のルートにある `WindowGroup` で直接作成すれば良い.
    static let store = Store(initialState: CounterFeature.State()) {
        // `_printChanges()` をつけるとデバッグが可能.
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: MyApp.store)
        }
    }
}
