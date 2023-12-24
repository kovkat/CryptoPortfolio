//
//  PortfolioView - використовується для редагування портфеля криптовалют
//

import SwiftUI

struct PortfolioView: View {
    
    // Отримання доступу до спільного ViewModel
    @EnvironmentObject private var vm: HomeViewModel
    
    // Збережена монета та її кількість
    @State private var selectedCoin: CoinModel? = nil
    @State private var amount: String = ""
    
    // Стан галочки та сповіщення
    @State private var checkMark: Bool = false
    @State private var showAlert: Bool = false
    
    // Повідомлення для сповіщення
    private var message = "Enter the quantity of the selected coin, or 0 to delete 🥳"
    
    var body: some View {
        // Основний макет екрану
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 0) {
                    // Рядок пошуку
                    SearchBarView(searchText: $vm.searchText)
                    
                    // Список доступних монет
                    logoCoinList
                    
                    // Інформація про вибрану монету
                    coinInfo
                    
                    // Кнопка збереження
                    saveButton
                }
            }
            // Фонове оформлення та заголовок
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Edit Portfolio")
            // Кнопки навігації
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { DismissButton() } // Кнопка закриття
                ToolbarItem(placement: .navigationBarTrailing) { getCheckMark } // Галочка збереження
            }
            // Обробники подій
            .onChange(of: vm.searchText, perform: { newValue in
                if newValue == "" {
                    removeSelection() // Очистити вибір після очищення пошуку
                }
            })
            .onTapGesture {  hideKeyboard() } // Приховати клавіатуру при натисканні на екран
            // Сповіщення при помилці
            .alert("Try again", isPresented: $showAlert) {
                Button(role: .destructive) {
                    removeSelection()
                    hideKeyboard()
                } label: {
                    Text("Clear search")
                        .accessibilityIdentifier("alert_ButtonTryAgain_ID")
                }
            } message: {
                Text(message)
            }
        }
    }
}

// MARK: - Preview Provider
struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM) // Використовує тестовий ViewModel для попереднього перегляду
    }
}

// MARK: - Компоненти
extension PortfolioView {
    
    private var logoCoinList: some View {
        // Горизонтальний список логотипів криптовалют
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack (spacing: 11) {
                ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 80)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                updateSelectionAmount(coin: coin)
                            }
                        }
                        .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(selectedCoin?.id == coin.id ? Color.theme.red : Color.clear,
                                    lineWidth: 1)
                        )
                }
            }
            .padding(.vertical, 4)
            .padding(.leading, 25)
        }
    }
    
    private var coinInfo: some View {
        // Інформація про вибрану монету
        VStack {
            HStack {
                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6() ?? "")
            }
            Divider()
            HStack {
                Text(amount == "" ? "Quantity of coin" : "Clear amount")
                    .onTapGesture {
                        amount = "0"
                    }
                Spacer()
                TextField("Ex: 1.73", text: $amount)
                    .accessibilityIdentifier("amount_TextField_ID")
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numbersAndPunctuation)
                    .autocorrectionDisabled(true)
                    .textContentType(.init(rawValue: ""))
            }
            Divider()
            HStack {
                Text("Current value")
                Spacer()
                Text(getCurrentValue().asCurrencyWith6())
            }
        }
        .padding()
        .padding(.top)
        .font(.headline)
        .foregroundColor(Color.theme.accent)
        .opacity(selectedCoin == nil ? 0.0 : 1.0)
    }
    
    private var saveButton: some View {
        // Кнопка збереження змін до портфелю
        VStack {
            Button {
                guard
                    let coin = selectedCoin,
                    let amount = Double(amount) else {
                    showAlert.toggle()
                    return
                }
                // Зберігає зміни в ViewModel
                vm.updatePortfolio(coin: coin, amount: amount)
                
                // Приховує клавіатуру
                hideKeyboard()
                
                // Показує галочку збереження
                withAnimation(.spring()) { checkMark = true }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.spring()) {
                        checkMark = false
                    }
                }
                
                // Очищає вибір після збереження
                removeSelection()
            } label: {
                Text("Save Currency")
                    .accessibilityIdentifier("portfolioSave_Button_ID")
                    .foregroundColor(Color.theme.accent)
                    .font(.title2 .bold())
            }.buttonMode()
        }
        .padding(.top)
        .opacity(selectedCoin == nil ? 0.0 : 1.0) // Приховує кнопку, якщо монета не вибрана
    }
    
    private var getCheckMark: some View {
        // Галочка збереження
        VStack {
            Image(systemName: "checkmark.shield")
                .font(.headline)
                .foregroundColor(Color.theme.green)
        }
        .opacity(checkMark ? 1.0 : 0.0) // Показує галочку, якщо checkMark true
        .padding(.top, 18)
        .padding(.trailing, 15)
    }
}

//MARK: - Private Methods
extension PortfolioView {
    
    private func getCurrentValue() -> Double {
        if let item = Double(amount) {
            return item * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
    private func removeSelection() {
        vm.searchText = ""
        selectedCoin = nil
        amount = ""
    }
    
    private func updateSelectionAmount(coin: CoinModel) {
        selectedCoin = coin
        /// This method get current amount from portfolio if exist
        guard
            let portfolioCoin = vm.portfolioCoins.first(where: { $0.id == coin.id }),
            let currentAmount = portfolioCoin.currentHoldings else {
            amount = ""
            return
        }
        amount = "\(currentAmount)"
    }
    
}
