//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import EnumKit

enum TransactionListRowViewModel: CaseAccessible {
    case header(title: String)
    case subheader(title: String, odd: Bool)
    case detail(description: String, amount: String, odd: Bool)
    case subfooter(odd : Bool)
    case footer(total: String, odd: Bool)
    case grandfooter(total: String)
    case message(message: String)
}

extension TransactionListRowViewModel {
    
    var cellId: String {
        return {
            () -> CellId in
            switch self {
            case .header:
                return .header
            case .subheader:
                return .subheader
            case  .detail:
                return .detail
            case .message:
                return .message
            case .footer:
                return .footer
            case .grandfooter:
                return .grandfooter
            case .subfooter:
                return .subfooter
            }
        } ().rawValue
    }

    private enum CellId: String {
        case header
        case subheader
        case detail
        case subfooter
        case footer
        case grandfooter
        case message
    }
}


