//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import EnumKit

enum TransactionListRefreshPresenterOutput: CaseAccessible  {
    case initialize
    case showReport([TransactionListRowViewModel])
}
