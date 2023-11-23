//
//  CounterFeature.swift
//  YourFirstFeature
//
//  Created by Shunya Yamada on 2023/11/19.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CounterFeature {
    /// その機能を実行するために必要な状態を保持しておく.
    ///
    /// `ViewStore` で利用するために `State` を `Equatable` に準拠させる必要がある.
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }

    /// ユーザーがその機能で実行できるすべてのアクションを表す
    enum Action {
        case decrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case incrementButtonTapped
        case timerTick
        case toggleTimerButtonTapped
    }

    /// `Effect` をキャンセルする際に利用する ID.
    enum CancelID {
        case timer
    }

    /// `Task.sleep` などのタイマーに関する処理をテスト側では差し替えられるようにする.
    @Dependency(\.continuousClock) var clock
    /// 通信処理をテスト時に差し替えられるようにする.
    @Dependency(\.numberFact) var numberFact

    /// `body` プロパティの実装が必要.
    /// `Action` を受け取って、現在の `State` を次の状態に変化させる.
    var body: some ReducerOf<Self> {
        // 複数の Reducer をまとめることが多い.
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                // 実行する副作用？ `Effect` がないため `.none` を返す.
                return .none
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true

                // `state.fact` は API の値を利用するため副作用が発生する.
                // ここで URLSession などで通信の処理を行いたいが、非同期処理なのでここに書くことが出来ない.
                // TCA では State の単純な変換を複雑で厄介な副作用から切り離している. これは核となる考え方であり、多くのメリットがある.
                // この副作用を実行するためのものを `Effect` と呼んでいる.
                // ❌ let (date, _) = await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(state.count)")!)

                // `Effect` を実行するメインの手段が `run(priority:operation:catch:fileID:line:)`.
                return .run { [count = state.count] send in
                    // ここでなら非同期処理を実行することができる.
                    // ⚠️ 今はエラーのことを考慮していないが、本来は `TaskResult` を利用してエラーを `Reducer` に伝えて適切に処理する.
//                    let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(count)")!)
//                    let fact = String(decoding: data, as: UTF8.self)

                    // ただし、取得したデータを使ってそのまま `State` を更新することはできない.
                    // `Reducer` が実行する純粋な `State` の変更を複雑は `Effect` の処理から分離するため、クロージャー内で `State` をキャプチャ出来ないようにしている.
                    // ❌ state.fact = fact

                    // `Effect` の情報を `Reducer` に戻すため、別の `Action` を利用して `Reducer` に戻して `State` を更新する.
                    try await send(.factResponse(self.numberFact.fetch(count)))
                }
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    // タイマーの停止を再現するため `Effect` を途中でキャンセルさせる.
                    // キャンセルのために `cancellable(id:)` メソッドを利用する.
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            // `Effect` の結果を `Reducer` に戻す `Action` を実行して `State` を更新する.
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    // タイマー実行中の場合はキャンセルさせる.
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}
