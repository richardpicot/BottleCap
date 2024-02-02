import UIKit

enum QuickAction: String {
    
    case logDrink = "LogDrink"
    case logMultipleDrinks = "LogMultipleDrinks"
    
}

enum QA: Equatable {
    
    case logDrink
    case logMultipleDrinks
    
    init?(shortcutItem: UIApplicationShortcutItem) {
        
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            return nil
        }
        
        switch action {
        case .logDrink:
            self = .logDrink
        case .logMultipleDrinks:
            self = .logMultipleDrinks
        }
    }
}

class QAService: ObservableObject {
    
    static let shared = QAService()
    @Published var action: QA?
    
}
