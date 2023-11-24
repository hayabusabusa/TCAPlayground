//
//  ContactFeature.swift
//  Navigation
//
//  Created by Shunya Yamada on 2023/11/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

@Reducer
struct ContactsFeature {
    struct State: Equatable {
        /// 画面遷移先の `State` を `PresentationState` として持たせる.
        @PresentationState var addContact: AddContactFeature.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }

    enum Action {
        case addButtonTapped
        /// 画面遷移先の `Action` を持たせる.
        case addContact(PresentationAction<AddContactFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                // 画面遷移できるように `State` に値を入れる.
                state.addContact = AddContactFeature.State(
                    contact: Contact(id: UUID(), name: "")
                )
                return .none
//            case .addContact(.presented(.delegate(.cancel))):
//                // 次の画面でキャンセルボタンが押された時の `Action` で `State` を nil にして画面を閉じる.
//                state.addContact = nil
//                return .none
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                // 次の画面で保存のボタンが押された時の `Action`.
                state.contacts.append(contact)
                // 子画面の方で `DismissEffect` を利用しているため nil にする必要はなくなる.
//                state.addContact = nil
                return .none
            case .addContact:
                return .none
            }
        }
        // `ifLet()` で子 `Action` が入ってきた時に子 `Reducer` を実行する.
        // 画面を閉じた時に `Effect` を自動でキャンセルしたりしてくれる.
        // これで `Reducer` 間の接続ができる.
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
        }
    }
}

struct ContentView: View {
    let store: StoreOf<ContactsFeature>

    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: \.contacts) { viewStore in
                List {
                    ForEach(viewStore.state) { contact in
                        Text(contact.name)
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        // `sheet(store:)` を利用して画面遷移を実現する.
        // “.addContact` の `Action` が流れてきた時に `State` に値を入れる.
        .sheet(
            store: self.store.scope(
                state: \.$addContact,
                action: { .addContact($0) }
            )
        ) { addContactStore in
            // `State` が nil じゃなくなると新しい `Store` が派生して View に渡せるようになる.
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
    }
}

#Preview {
    ContentView(
        store: Store(
            initialState: ContactsFeature.State(
                contacts: [
                    Contact(id: UUID(), name: "Blob"),
                    Contact(id: UUID(), name: "Blob Jr"),
                    Contact(id: UUID(), name: "Blob Sr")
                ]
            )
        ) {
            ContactsFeature()
        }
    )
}
