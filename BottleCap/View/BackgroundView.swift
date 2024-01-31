import SwiftUI

struct BackgroundView: View {
    var progress: CGFloat  // A number between 0 and 1
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let totalWidth = geometry.size.width
            let progressHeight = totalHeight * progress
            
            ZStack(alignment: .bottom) {
                Color.backgroundPrimary
                
                Rectangle()
                    .fill(.backgroundSecondary)
                    .frame(width: totalWidth, height: totalHeight)
                
                BubbleEffectView(color: .white)
                    .frame(width: totalWidth, height: totalHeight)
                    .clipShape(Rectangle())
            }
            .mask(
                VStack {
                    Rectangle().frame(height: progressHeight)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            )
        }
        .ignoresSafeArea()
        .animation(.spring(duration: 1.0, bounce: 0), value: progress)
    }
}

// Preview
struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView(progress: 0.5)
    }
}
