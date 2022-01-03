//
//  TabBarView.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/12/29.
//

import SwiftUI
import SFSafeSymbols
import ComposableArchitecture

struct TabBarView: View {
    @Environment(\.scenePhase) private var scenePhase
    private let store: Store<AppState, AppAction>
    @ObservedObject private var viewStore: ViewStore<AppState, Never>
    @ObservedObject private var tabStore: ViewStore<TabBarState, TabBarAction>

    init(store: Store<AppState, AppAction>) {
        self.store = store
        viewStore = ViewStore(store.actionless)
        tabStore = ViewStore(store.scope(state: \.tabBarState, action: AppAction.tabBar))
    }

    var body: some View {
        TabView(selection: tabStore.binding(\.$tabBarItemType)) {
            ForEach(TabBarItemType.allCases) { type in
                Group {
                    switch type {
                    case .favorites:
                        FavoritesView(
                            store: store.scope(state: \.favoritesState, action: AppAction.favorites),
                            user: viewStore.settingState.user, setting: viewStore.settingState.setting,
                            tagTranslator: viewStore.settingState.tagTranslator
                        )
                    case .setting:
                        SettingView(store: store.scope(state: \.settingState, action: AppAction.setting))
                    }
                }
                .tabItem(type.label).tag(type)
            }
            .accentColor(viewStore.settingState.setting.accentColor)
        }
//        .onChange(of: scenePhase) { newValue in
//            <#code#>
//        }
    }
}

// MARK: TabType
enum TabBarItemType: String, CaseIterable, Identifiable {
    var id: String { rawValue }

//    case home = "Home"
    case favorites = "Favorites"
//    case search = "Search"
    case setting = "Setting"
}

extension TabBarItemType {
    var symbol: SFSymbol {
        switch self {
//        case .home:
//            return .houseCircle
        case .favorites:
            return .heartCircle
//        case .search:
//            return .magnifyingglassCircle
        case .setting:
            return .gearshapeCircle
        }
    }
    func label() -> Label<Text, Image> {
        Label(rawValue.localized, systemSymbol: symbol)
    }
}
