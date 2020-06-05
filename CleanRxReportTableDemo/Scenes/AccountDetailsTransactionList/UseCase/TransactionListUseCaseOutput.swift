//  Copyright © 2020 Lyle Resnick. All rights reserved.
import EnumKit


enum TransactionListUseCaseOutput: CaseAccessible {
    case refresh(TransactionListRefreshUseCaseOutput)
}
