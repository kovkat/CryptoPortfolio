//
//  Main
//

import SwiftUI

struct Main: View {
    
    // StateObject для доступу до даних та керування головними функціями
    @StateObject private var vm: HomeViewModel
    // State для відображення екрану запуску
    @State private var showLaunchView: Bool = true
    
    // Ініціалізатор, що створює ViewModel та налаштовує зовнішній вигляд
    init(vm: CoinDataServiceProtocol) {
        _vm = StateObject(wrappedValue: HomeViewModel(coinDataService: vm))
        
        // Налаштування кольорів для елементів навігації
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        navBarAppearance.tintColor = UIColor(Color.theme.accent)
        
        // Налаштування фону для TableView
        let tableView = UITableView.appearance()
        tableView.backgroundColor = UIColor.clear
    }
    
    // Структура екрану
    var body: some View {
        // Основний екран із навігацією
            ZStack {
                NavigationStack {
                    HomeView()
                }
                .environmentObject(vm) // Передача ViewModel для доступу до даних
                
                // Екран запуску
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunch: $showLaunchView)
                            .transition(.move(edge: .leading)) // Анімація переміщення зліва
                    }
                }
                .zIndex(2.0) // Розташування екрану запуску поверх основного
            }
    }
}

