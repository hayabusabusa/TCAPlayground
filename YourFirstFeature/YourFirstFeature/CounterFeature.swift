//
//  CounterFeature.swift
//  YourFirstFeature
//
//  Created by Shunya Yamada on 2023/11/19.
//

import ComposableArchitecture

@Reducer
struct CounterFeature {
    /// その機能を実行するために必要な状態を保持しておく.
    ///
    /// `ViewStore` で利用するために `State` を `Equatable` に準拠させる必要がある.
    struct State: Equatable {
        var count = 0
    }

    /// ユーザーがその機能で実行できるすべてのアクションを表す
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
    }

    /// `body` プロパティの実装が必要.
    /// `Action` を受け取って、現在の `State` を次の状態に変化させる.
    var body: some ReducerOf<Self> {
        // 複数の Reducer をまとめることが多い.
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                // 実行する副作用？ `Effect` がないため `.none` を返す.
                return .none
            case .incrementButtonTapped:
                state.count += 1
                return .none
            }
        }
    }
}
