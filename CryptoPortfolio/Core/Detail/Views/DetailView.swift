
import SwiftUI

struct DetailView: View {
    
    @StateObject private var vm: DetailViewModel
    @State private var showAllDescription: Bool = false
    
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    

    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        VStack {
            detailHeader
            chart
            ScrollView(showsIndicators: false) {
                overview
                divider
                details
                coinImage
                description
                links
            }
            .padding()
            .navigationBarBackButtonHidden()
        }
        .background(Color.theme.background)
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
            DetailView(coin: dev.coin)
    }
}


extension DetailView {
    

    private var detailHeader: some View {
        HStack  {
            DismissButton()
            Text(vm.coin.name)
                .font(.title2 .bold())
                .foregroundColor(Color.theme.accent)
            Spacer()
            HStack {
                Text(vm.coin.symbol.uppercased())
                    .font(.title2 .bold())
                    .foregroundColor(Color.theme.secondaryText)
                
                CoinImageView(coin: vm.coin)
                    .frame(width: 25, height: 25)
            }
            .padding(10)
        }
    }
    

    private var chart: some View {
        VStack {
            ChartView(coin: vm.coin)
        }
        .padding(.vertical, 5)
    }


    private var overview: some View {
        VStack (spacing: 20) {
            Text("Overview")
                .font(.title .bold())
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                ForEach(vm.overviewStatistic) { stat in
                    StatisticBarView(statistic: stat)
                }
            }
        }
    }
    

    private var divider: some View {
        VStack {
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color.theme.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 1)
        }
    }
    

    private var details: some View {
        VStack (spacing: 20) {
            Text("Details")
                .font(.title .bold())
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 30) {
                ForEach(vm.detailsStatistic) { stat in
                    StatisticBarView(statistic: stat)
                }
            }
        }
    }
    

    private var coinImage: some View {
        CoinImageView(coin: vm.coin)
            .frame(width: 25, height: 25, alignment: .center)
    }
    

    private var links: some View {
        HStack {
            if let website = vm.websiteURL, let url = URL(string: website) {
                Image(systemName: "link.icloud")
                    .foregroundColor(Color.theme.red)
                Link("Website", destination: url)
                    .foregroundColor(Color.theme.accent)
            }
            Spacer ()
            if let reddit = vm.redditURL, let url = URL(string: reddit) {
                Image(systemName: "link.icloud")
                    .foregroundColor(Color.theme.red)
                Link("Reddit", destination: url)
                    .foregroundColor(Color.theme.accent)
            }
        }
        .padding(.horizontal)
    }
    

    private var description: some View {
        VStack {
            if let description = vm.coinDescription, !description.isEmpty {
                
                Text(description)
                    .font(.callout)
                    .foregroundColor(Color.theme.accent)
                    .lineLimit(showAllDescription ? nil : 3)
                    .padding(.top)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showAllDescription.toggle()
                    }
                } label: {
                    Text(showAllDescription ? "Hide description" : "Reed more")
                        .accessibilityIdentifier("description_Button_ID")
                        .foregroundColor(Color.theme.red)
                }
            }
        }
    }
}
