//
//  LaunchView.swift
//  CryptoPortfolio
//



import SwiftUI

struct LaunchView: View {
    
    @State private var animate: CGFloat = 0
    
    /// Convert each character to a String
    @State private var loadingText: [String] = "Loading Portfolio ... ".map { String($0) }
    @State private var isLoading: Bool = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State private var counter = 0
    @State private var loops = 0
    @Binding var showLaunch: Bool
    
    var body: some View {
        ZStack {
            launchImage
            launchText
        }
        .onAppear{
            isLoading.toggle()
            withAnimation(.easeInOut(duration: 4.7)) {
                animate = 2000
            }
        }
        .onReceive(timer, perform: { _ in
            withAnimation(.spring()) {
                let lastIndex = loadingText.count - 1
                if counter == lastIndex {
                    counter = 0
                    loops += 1
                    if loops > 1 {
                        showLaunch = false
                    }
                } else {
                    counter += 1
                }
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.LaunchBackground)
    }
}

//                🔱
struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunch: .constant(true))
    }
}

//MARK: Components
extension LaunchView {
    
    private var launchImage: some View {
        Image(systemName: "circle.hexagongrid.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(Color.theme.red)
            .rotationEffect(Angle(degrees: animate))
    }
    
    private var launchText: some View {
        ZStack {
            if isLoading {
                HStack (spacing: 0) {
                    ForEach(loadingText.indices, id: \.self) { item in
                        Text(loadingText[item])
                            .font(.title2 .bold())
                            .foregroundColor(Color.theme.red)
                            .offset(y: counter == item ? -8 : 0)
                    }
                }
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.1)))
            }
        }
        .offset(y: 90)
    }
}

