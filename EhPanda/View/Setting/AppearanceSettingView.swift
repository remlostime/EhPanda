//
//  AppearanceSettingView.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/01/18.
//

import SwiftUI
import ComposableArchitecture

struct AppearanceSettingView: View {
    private let store: Store<AppearanceSettingState, AppearanceSettingAction>
    @ObservedObject private var viewStore: ViewStore<AppearanceSettingState, AppearanceSettingAction>
    @Binding private var preferredColorScheme: PreferredColorScheme
    @Binding private var accentColor: Color
    @Binding private var appIconType: AppIconType
    @Binding private var listDisplayMode: ListDisplayMode
    @Binding private var showsTagsInList: Bool
    @Binding private var listTagsNumberMaximum: Int

    init(
        store: Store<AppearanceSettingState, AppearanceSettingAction>,
        preferredColorScheme: Binding<PreferredColorScheme>, accentColor: Binding<Color>,
        appIconType: Binding<AppIconType>, listDisplayMode: Binding<ListDisplayMode>,
        showsTagsInList: Binding<Bool>, listTagsNumberMaximum: Binding<Int>
    ) {
        self.store = store
        viewStore = ViewStore(store)
        _preferredColorScheme = preferredColorScheme
        _accentColor = accentColor
        _appIconType = appIconType
        _listDisplayMode = listDisplayMode
        _showsTagsInList = showsTagsInList
        _listTagsNumberMaximum = listTagsNumberMaximum
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Theme")
                    Spacer()
                    Picker(
                        selection: $preferredColorScheme,
                        label: Text(preferredColorScheme.rawValue.localized),
                        content: {
                            ForEach(PreferredColorScheme.allCases) { colorScheme in
                                Text(colorScheme.rawValue.localized).tag(colorScheme)
                            }
                        }
                    )
                }
                .pickerStyle(.menu)
                ColorPicker("Tint Color", selection: $accentColor)
                Button("App Icon") {
                    viewStore.send(.setNavigation(.appIcon))
                }
                .foregroundStyle(.primary).withArrow()
            }
            Section("List".localized) {
                HStack {
                    Text("Display mode")
                    Spacer()
                    Picker(
                        selection: $listDisplayMode,
                        label: Text(listDisplayMode.rawValue.localized),
                        content: {
                            ForEach(ListDisplayMode.allCases) { listMode in
                                Text(listMode.rawValue.localized).tag(listMode)
                            }
                        }
                    )
                }
                .pickerStyle(.menu)
                Toggle(isOn: $showsTagsInList) {
                    Text("Shows tags in list")
                }
                HStack {
                    Text("Maximum number of tags")
                    Spacer()
                    Picker(
                        selection: $listTagsNumberMaximum,
                        label: Text("\(listTagsNumberMaximum)")
                    ) {
                        Text("Infinity").tag(0)
                        ForEach(Array(stride(from: 5, through: 20, by: 5)), id: \.self) { num in
                            Text("\(num)").tag(num)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .disabled(!showsTagsInList)
            }
        }
        .background(navigationLink)
        .navigationTitle("Appearance")
    }
    private var navigationLink: some View {
        NavigationLink(unwrapping: viewStore.binding(\.$route), case: /AppearanceSettingState.Route.appIcon) { _ in
            AppIconView(appIconType: $appIconType)
        }
    }
}

// MARK: SelectAppIconView
private struct AppIconView: View {
    @Binding private var appIconType: AppIconType

    init(appIconType: Binding<AppIconType>) {
        _appIconType = appIconType
    }

    var body: some View {
        Form {
            Section {
                ForEach(AppIconType.allCases) { icon in
                    AppIconRow(
                        iconName: icon.iconName,
                        iconDesc: icon.rawValue,
                        isSelected: icon == appIconType
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { appIconType = icon }
                }
            }
        }
        .navigationTitle("App Icon")
    }
}

// MARK: AppIconRow
private struct AppIconRow: View {
    private let iconName: String
    private let iconDesc: String
    private let isSelected: Bool

    init(iconName: String, iconDesc: String, isSelected: Bool) {
        self.iconName = iconName
        self.iconDesc = iconDesc
        self.isSelected = isSelected
    }

    var body: some View {
        HStack {
            Image(uiImage: .init(named: iconName, in: .main, with: nil) ?? .init())
                .resizable().scaledToFit().frame(width: 60, height: 60).cornerRadius(12)
                .padding(.vertical, 10).padding(.trailing, 20)
            Text(iconDesc.localized)
            Spacer()
            Image(systemSymbol: .checkmarkCircleFill)
                .opacity(isSelected ? 1 : 0).foregroundStyle(.tint).imageScale(.large)
        }
    }
}

// MARK: Definition
enum AppIconType: String, Codable, Identifiable, CaseIterable {
    var id: Int { hashValue }

    case normal = "Normal"
    case `default` = "Default"
    case weird = "Weird"
}

extension AppIconType {
    var iconName: String {
        switch self {
        case .normal:
            return "AppIcon_Normal"
        case .default:
            return "AppIcon_Default"
        case .weird:
            return "AppIcon_Weird"
        }
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppearanceSettingView(
                store: .init(
                    initialState: .init(),
                    reducer: appearanceSettingReducer,
                    environment: AppearanceSettingEnvironment()
                ),
                preferredColorScheme: .constant(.automatic),
                accentColor: .constant(.blue),
                appIconType: .constant(.default),
                listDisplayMode: .constant(.detail),
                showsTagsInList: .constant(false),
                listTagsNumberMaximum: .constant(0)
            )
        }
    }
}
