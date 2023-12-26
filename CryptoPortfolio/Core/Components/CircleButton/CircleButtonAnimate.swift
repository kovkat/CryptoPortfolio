

import SwiftUI

struct CircleButtonAnimate: View {
    
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .foregroundColor(Color.theme.red)
                .opacity(animate ? 1.0 : 0.0)
                .scaleEffect(animate ? 0.4 : 1.0)
                .animation(.easeInOut(duration: 0.7), value: animate)
        }
    }
}

struct CircleButtonAnimate_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonAnimate(animate: .constant(false))
    }
}
