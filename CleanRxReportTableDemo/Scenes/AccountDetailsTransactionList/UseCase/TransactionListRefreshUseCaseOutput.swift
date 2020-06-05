//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import EnumKit

enum TransactionListRefreshUseCaseOutput: CaseAccessible {
    
    case initialize
    case header(group: TransactionGroup)
    case subheader(date: Date)
    case detail(description: String, amount: Double)
    case subfooter
    case footer(total: Double)
    case grandFooter(grandTotal: Double)
    case notFoundMessage(group: TransactionGroup)
    case noTransactionsMessage(group: TransactionGroup)
    case notFoundMessageAll
    case finalize
    case failure(code: Int, description: String)
}
