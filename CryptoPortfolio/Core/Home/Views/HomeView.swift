//
//  HomeView - основна візуальна частиною програми для перегляду криптовалют, що відповідає за відображення списку монет, а також за надання користувачеві можливості сортувати монети, додавати їх до портфеля та отримувати оновлені дані
//

import SwiftUI

struct HomeView: View {
    // Отримання доступу до HomeViewModel
    @EnvironmentObject private var vm: HomeViewModel
    
    // Змінна для відстеження відображення портфеля
    @State private var showPortfolio : Bool = false // Анімація
    
    // Змінні для відображення аркушів
    @State private var showSheet     : Bool = false // Аркуш додавання монет
    @State private var showSettings  : Bool = false // Аркуш налаштувань
    
    var body: some View {
        // Основний контейнер ZStack для розміщення різних шарів
        ZStack {
            // Шар фону
            Color.theme.background.ignoresSafeArea()
            // Аркуш (sheet) для відображення PortfolioView
                .sheet(isPresented: $showSheet) {
                    PortfolioView()
                        .environmentObject(vm)
                }
            
            // Шар контенту
            VStack {
                // Заголовок
                homeHeader
                
                // Статистичний блок
                StatisticBarSection(showPortfolio: $showPortfolio)
                
                // Рядок пошуку
                SearchBarView(searchText: $vm.searchText)
                
                // Рядок із заголовками стовпців
                infoColumn
                
                // Списки монет
                if !showPortfolio {
                    allCoinsList
                    .transition(.move(edge: .leading)) // Анімація пересування зі сторони leading
                }
                if showPortfolio {
                    ZStack {
                        // Якщо портфель порожній і не введено пошуковий запит, відобразити повідомлення про порожній портфель
                        if vm.portfolioCoins.isEmpty && vm.searchText.isEmpty {
                            
                        } else {
                            portfolioCoinsList
                        }
                    }
                    .transition(.move(edge: .trailing)) // Анімація пересування зі сторони trailing
                }
                // Розділювач для заповнення нижнього простору
                Spacer(minLength: 0)
            }
        }
        // Аркуш (sheet) для відображення SettingsView
//        .sheet(isPresented: $showSettings) {
//            SettingsView()
//        }
    }
}

// MARK: - Попередній перегляд
struct HomeView_Previews: PreviewProvider {
    // Попередній перегляд HomeView у NavigationStack
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(dev.homeVM) // Надання доступу до HomeViewModel
    }
}

// MARK: - Компоненти
extension HomeView {
    // Заголовок
    private var homeHeader: some View {
        HStack {
            // Кнопка з динамічною іконкою
            if showPortfolio{
                CircleButtonView(iconName:  "plus" )
                    .background(CircleButtonAnimate(animate: $showPortfolio)) // Додавання анімації
                    .onTapGesture {
                        hideKeyboard()
                        showSheet.toggle()
                    }
                }
            
            Spacer()
            
            // Текст заголовка (Портфель або Живі ціни)
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .accessibilityIdentifier("mainHeader_Label_ID")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
            Spacer()
            
            // Кнопка перемикання між портфелем і живими цінами
            CircleButtonView(iconName: "chevron.right")
                .accessibilityIdentifier("showPortfolio_Button_ID")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0)) // Поворот на 180 градусів
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle() // Перемикання стану
                    }
                }
        }
        .padding(.horizontal)
    }
    
    // Список усіх монет
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                NavigationLink {
                    // Ліниве завантаження DetailView
                    LazyView<DetailView>(DetailView(coin: coin))
                } label: {
                    CoinRowView(coin: coin, showHoldingColumn: false) // Відображення рядка монети
                }
            }
            .listRowSeparator(.hidden) // Приховування роздільників
            .listRowBackground(Color.theme.background) // Встановлення фону рядків
        }
        .listStyle(.plain) // Простий стиль списку
        .refreshable {
            vm.reloadData()  // Оновлення даних при перетягуванні вниз
        }
    }
    
    // Список монет портфеля
    private var portfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                NavigationLink {
                    // Ліниве завантаження DetailView
                    LazyView<DetailView>(DetailView(coin: coin))
                } label: {
                    CoinRowView(coin: coin, showHoldingColumn: true)  // Відображення стовпця з кількістю монет
                }
            }
            .listRowSeparator(.hidden) // Приховування роздільників
            .listRowBackground(Color.theme.background) // Встановлення фону рядків
        }
        .listStyle(.plain) // Простий стиль списку
    }
    

    // Рядок із заголовками стовпців для списку монет
    private var infoColumn: some View {
        HStack { // Горизонтальний контейнер для всіх елементів заголовків
            HStack (spacing: 4) {  // Заголовок "Coin" і кнопка для сортування за номером
                Text("Coin")  // Текстове поле з заголовком "Coin"
                    .accessibilityIdentifier("searchOfNumber_Button_ID") // Ідентифікатор доступності
                Image(systemName: "chevron.down") // Іконка стрілки вниз
                    .opacity( (vm.sortOptions == .rank || vm.sortOptions == .rankReversed) ? 1.0 : 0.0 ) // Видимість стрілки залежить від опції сортування
                    .rotationEffect(Angle(degrees: vm.sortOptions == .rank ? 180 : 0)) // Поворот стрілки залежно від порядку сортування
            }
            .onTapGesture { // Обробник натиснення на заголовок "Coin"
                withAnimation(.linear(duration: 0.5)) { // Анімація перемикання сортування
                    vm.sortOptions = vm.sortOptions == .rank ? .rankReversed :  .rank // Зміна опції сортування
                }
                HapticManager.notification(type: .success)  // Тактильний зворотний зв'язок
            }
            Spacer(minLength: 160) // Розділювач між заголовками
            
            // Заголовок "Holdings" і кнопка для сортування за кількістю (якщо показано портфель)
            if showPortfolio {
                HStack (spacing: 4) {
                    Text("Holdings") // Текстове поле з заголовком "Holdings"
                        .accessibilityIdentifier("searchOfHoldings_Button_ID")  // Ідентифікатор доступності
                    Image(systemName: "chevron.down") // Іконка стрілки вниз
                        .opacity( (vm.sortOptions == .holdings || vm.sortOptions == .holdingsReversed) ? 1.0 : 0.0 ) // Видимість стрілки залежить від опції сортування
                        .rotationEffect(Angle(degrees: vm.sortOptions == .holdings ? 180 : 0 ))  // Поворот стрілки залежно від порядку сортування
                }
                .onTapGesture { // Обробник натиснення на заголовок "Holdings"
                    withAnimation(.linear(duration: 0.5)) { // Анімація перемикання сортування
                        vm.sortOptions = vm.sortOptions == .holdings ? .holdingsReversed : .holdings // Зміна опції сортування
                    }
                    HapticManager.notification(type: .success) // Тактильний зворотний зв'язок
                }
            }
            Spacer(minLength: 50) // Розділювач між заголовками
            
            // Заголовок "Price" і кнопка для сортування за ціною
            HStack (spacing: 4) {
                Text("Price") // Текстове поле з заголовком "Price"
                    .accessibilityIdentifier("searchOfPrice_Button_ID")  // Ідентифікатор доступності
                Image(systemName: "chevron.down") // Іконка стрілки вниз
                    .opacity( (vm.sortOptions == .price || vm.sortOptions == .priceReversed) ? 1.0 : 0.0 ) // Видимість стрілки залежить від опції сортування
                    .rotationEffect(Angle(degrees: vm.sortOptions ==  .price ? 180 : 0 ))  // Поворот стрілки залежно від порядку сортування
            }
            .onTapGesture { // Обробник натиснення на заголовок "Price"
                withAnimation(.linear(duration: 0.5)) { // Анімація перемикання сортування
                    vm.sortOptions = vm.sortOptions == .price ? .priceReversed : .price // Зміна опції сортування
                }
                HapticManager.notification(type: .success)
            }
            // Кнопка "Оновити"
            Button { // Обробник натиснення на кнопку "Оновити"
                withAnimation(.linear(duration: 0.5)) { // Анімація оновлення
                    vm.reloadData() // Оновлення даних
                }
            } label: {
                Image(systemName: "goforward") // Іконка стрілки вперед
                    .accessibilityIdentifier("refresh_Button_ID") // Ідентифікатор доступності
                    .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)  // Поворот стрілки залежно від стану завантаження
            }
            .padding(.leading, 8) // Відступ від лівого краю
        }
        .padding(.horizontal)  // Відступ від правого краю
        .font(.caption)  // Шрифт розміру caption
        .foregroundColor(Color.theme.secondaryText) // Колір тексту вторинного кольору
    }
}

