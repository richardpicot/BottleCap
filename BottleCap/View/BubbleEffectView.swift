import SwiftUI

class BubbleViewModel: Identifiable, ObservableObject {
    let id = UUID()
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var opacity: Double // Add opacity property

    var color: Color
    var width: CGFloat
    var height: CGFloat
    let lifetime: TimeInterval

    init(height: CGFloat, width: CGFloat, x: CGFloat, y: CGFloat, color: Color, lifetime: TimeInterval) {
        let size = CGFloat.random(in: 5...10) // Size range
        self.width = size
        self.height = size
        self.x = x
        self.y = y
        self.color = color // Bubble Color
        self.lifetime = TimeInterval.random(in: 3...6) // Lifetime range
        self.opacity = Double.random(in: 0.1...0.4) // Opacity

    }

    func xFinalValue() -> CGFloat {
        CGFloat.random(in: -width...width)
    }
}


class BubbleEffectViewModel: ObservableObject {
    @Published var bubbles: [BubbleViewModel] = []
    private var timer: Timer?
    
    private var bubbleColor: Color

    init(bubbleColor: Color = .white) {
        self.bubbleColor = bubbleColor
        startGeneratingBubbles()
    }
    
    private func startGeneratingBubbles() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.generateBubble()
        }
    }

    private func generateBubble() {
        let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        let bubble = BubbleViewModel(height: 30, width: 30, x: randomX, y: UIScreen.main.bounds.height, color: bubbleColor, lifetime: 4)

        bubbles.append(bubble)

        let removalDelay = bubble.lifetime + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + removalDelay) {
            self.bubbles.removeAll { $0.id == bubble.id }
        }
    }


    deinit {
        timer?.invalidate()
    }
}

extension Color {
    static var random: Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}

struct BubbleView: View {
    @ObservedObject var bubble: BubbleViewModel

    var body: some View {
        Circle()
            .foregroundColor(bubble.color)
            .opacity(bubble.opacity)
            .frame(width: bubble.width, height: bubble.height)
            .position(x: bubble.x, y: bubble.y)
            .onAppear {
                withAnimation(.linear(duration: bubble.lifetime)) {
                    bubble.y = -bubble.height * 2
                    bubble.x += bubble.xFinalValue()
                }
            }
    }
}


struct BubbleEffectView: View {
    @StateObject private var viewModel = BubbleEffectViewModel()
    init(color: Color) {
        _viewModel = StateObject(wrappedValue: BubbleEffectViewModel(bubbleColor: color))
    }


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(viewModel.bubbles) { bubble in
                    BubbleView(bubble: bubble)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleEffectView(color: .orange)
            .edgesIgnoringSafeArea(.all)
    }
}
