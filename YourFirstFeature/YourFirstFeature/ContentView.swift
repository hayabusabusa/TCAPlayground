//
//  ContentView.swift
//  YourFirstFeature
//
//  Created by Shunya Yamada on 2023/11/19.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    /// `Reducer` を保持しておく `Store` を持たせる.
    ///
    /// これを通して `Action` を実行して `Effect` で `State` を変化させて `View` 側に戻す.
    /// `Store` から `State` を直接読み取ることはできない.
    let store: StoreOf<CounterFeature>

    var body: some View {
        // `observe` ですべての State を監視しているが、パフォーマンスを最適化させるためには最低限のものを監視するようにする.
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                    .font(.largeTitle)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                }
                Button(viewStore.isTimerRunning ? "Stop timer" : "Start Timer") {
                    viewStore.send(.toggleTimerButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)

                Button("Fact") {
                    viewStore.send(.factButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)

                if viewStore.isLoading {
                    ProgressView()
                } else if let fact = viewStore.fact {
                    Text(fact)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView(
        // `Store` を作成する際には初期状態と機能を動かす `Reducer` を指定する.
        store: Store(initialState: CounterFeature.State()) {
            // `Store` には状態の変異や `Effect` を実行しない `Reducer` がデフォルトで指定されるためコメントアウトしてレイアウトだけ確認することもできる.
            CounterFeature()
        }
    )
}
