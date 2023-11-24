//
//  AddContactFeature.swift
//  Navigation
//
//  Created by Shunya Yamada on 2023/11/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AddContactFeature {
    struct State: Equatable {
        var contact: Contact
    }

    enum Action {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setName(String)

        /// 子から親へのやりとりのために利用するデリゲート.
        ///
        /// ⚠️ 画面を閉じる処理に関しては、TCA 側にある `DismissEffect` を利用する.
        enum Delegate: Equatable {
//            case cancel
            case saveContact(Contact)
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                // デリゲートに通知を送る.
//                return .send(.delegate(.cancel))

                // `DismissEffect` を利用して画面間のやり取りを行う.
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            case .saveButtonTapped:
                // デリゲートに通知を送る.
//                return .send(.delegate(.saveContact(state.contact)))

                // `DismissEffect` を利用して画面間のやり取りを行う.
                return .run { [contact = state.contact] send in
                    await send(.delegate(.saveContact(contact)))
                    await self.dismiss()
                }
            case let .setName(name):
                state.contact.name = name
                return .none
            }
        }
    }
}

struct AddContactView: View {
    let store: StoreOf<AddContactFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                TextField("Name", text: viewStore.binding(get: \.contact.name, send: { .setName($0) }))
                Button("Save") {
                    viewStore.send(.saveButtonTapped)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Cancel") {
                        viewStore.send(.cancelButtonTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddContactView(
            store: Store(initialState: AddContactFeature.State(
                contact: Contact(
                    id: UUID(),
                    name: "Blob"
                )
            )
            ) {
                AddContactFeature()
            }
        )
    }
}
