//
//  CounterFeatureTests.swift
//  YourFirstFeatureTests
//
//  Created by Shunya Yamada on 2023/11/23.
//

import ComposableArchitecture
import XCTest

@testable import YourFirstFeature

@MainActor
final class CounterFeatureTests: XCTestCase {
    func testCounter() async {
        // `TestStore` で `Action` による `State` の変化をアサートできるようにする.
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }

        // ユーザーの動作を再現する.
        // ほとんどの機能は非同期の副作用を伴っているため `send()` は非同期メソッドになっている.
        // ⚠️ この状態のままだとテストは失敗する.
        // await store.send(.incrementButtonTapped)

        // ⚠️ `TestStore` に `Action` を送信するたびに、その `Action` が送信された後に `State` がどのように変化するかを記載しないといけない.
//         State was not expected to change, but a change occurred: …
//
//          CounterFeature.State(
//        −   count: 0,
//        +   count: 1,
//            fact: nil,
//            isLoading: false,
//            isTimerRunning: false
//          )
//
//         (Expected: −, Actual: +)

        await store.send(.incrementButtonTapped) {
            // `Action` が送信された結果 `State` がどのように変化するかをここで記載して比較する.
            // クロージャーの引数に `Action` が送信される前の `State` が渡されるので、
            // `Action` が送信された後の `State` と等しくなるように変化させる.

            // `count += 1` のような相対的な変化よりも絶対的な変化を使った方が良い.
            // どのような変換が `State` に適応されたかではなく、どのような状態になるかを記載する.
            $0.count = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }

    func testTimer() async {
        // タイマーの処理を DI してテスト用のものに差し替える.
        let clock = TestClock()

        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }


        // `isTimerRunning` を 1 度送信しただけだと、タイマーの `Effect` が実行されたままになるためテストが失敗する.
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }

        // DI したテスト用の実装を利用して時間の流れをシミュレートする.
        await clock.advance(by: .seconds(1))

        // タイマーの `Action` を受け取るために `receive()` メソッドを利用して、`Action` を受けとった時に `State` がどのように変化するかを記載する.
        // ただこの状態だとテストが `receive()` のタイムアウトで失敗する状態になってしまう.
        // 引数の `timeout` を指定して無理やり通すこともできるが、それだと実際のテスト時間も伸びてしまう.
        await store.receive(\.timerTick) {
            $0.count = 1
        }
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }

    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            // 直接 API に通信してしまうのを防ぐためテスト用の実装に差し替える.
            $0.numberFact.fetch = { "\($0) is a good number." }
        }

        // そのまま `Action` を送るだけだと通信が完了していないため `Effect` が実行中のままになりテストが失敗する.
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }

        // `receive()` のタイムアウトを利用して無理やりレスポンスを待とうとしても、レスポンスが毎回変わってしまうためテストをとすことが出来ない
//        await store.receive(\.factResponse, timeout: .seconds(1)) {
//            $0.isLoading = false
//            $0.fact = "ここが変わる"
//        }

        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}
