//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import RxSwift
import RxEnumKit

extension TransactionListUseCaseTransformer {
    
    func refreshOneSourceTransform(input: Observable<TransactionListUseCaseInput>) -> Observable<TransactionListUseCaseOutput> {

        func transform(transactions: Single<[Transaction]>) -> Observable<TransactionListRefreshUseCaseOutput> {
            return transactions.asObservable()
                .flatMap { transactions -> Observable<TransactionListRefreshUseCaseOutput> in
                    var grandTotal: Double = 0

                    var list = transactions
                        .reduce(into: [:] as [TransactionGroup:[Date:[Transaction]]]) {
                            var groupTransactions = $0[$1.group, default: [:]]
                            var dateTransactions = groupTransactions[$1.date, default: []]
                            dateTransactions.append($1)
                            groupTransactions[$1.date] = dateTransactions
                            $0[$1.group] = groupTransactions
                        }
                        .sorted { left, _ in left.key == .authorized }
                        .reduce(into:[]) { result, group in
                            result += transform(transactionGroup: group, grandTotal: &grandTotal)
                        }
                    list += [.grandFooter(grandTotal: grandTotal)]
                    return Observable.from(list)
                }
                .catchError { error in
                    switch error {
                    case TransactionError.notFound:
                        return .just(.notFoundMessageAll)
                    case let TransactionError.failure(code, description):
                        return .just(.failure(code: code, description: description))
                    default:
                        return .empty()
                    }
                }
        }

        func transform(transactionGroup: (key: TransactionGroup, value: [Date:[Transaction]]), grandTotal: inout Double) ->  [TransactionListRefreshUseCaseOutput]  {
            
            let initialList  = [TransactionListRefreshUseCaseOutput.header(group: transactionGroup.key)]

            var (list, total ) = transactionGroup.value
                .map { ($0.key, $0.value) }
                .sorted { $0.0 < $1.0 }
                .reduce(into:(list: initialList,total: 0), transformGroupToUseCaseOutput)
            
            grandTotal += total
            list += [.footer(total: total)]
            return list
        }
        
        func transformGroupToUseCaseOutput(
                            _ accumulator: inout (list: [TransactionListRefreshUseCaseOutput], total: Double),
                            _ group: (key: Date, value: [Transaction]) ) {
               
            accumulator.list += [.subheader(date: group.key)]
            accumulator.list += group.value.map { .detail(description: $0.description, amount: $0.amount) }
            accumulator.list += [.subfooter]
            
            accumulator.total += group.value.reduce(0) { $0 + $1.amount }
        }
        
        return input.filter(case: TransactionListUseCaseInput.refreshOneSource)
            .flatMap { _ -> Observable<TransactionListRefreshUseCaseOutput> in
                
                return .concat(
                    .just(TransactionListRefreshUseCaseOutput.initialize),
                    transform(transactions: self.transactionManager.fetchAllTransactions()),
                    .just(TransactionListRefreshUseCaseOutput.finalize)
                )
                
            }
            .map(TransactionListUseCaseOutput.refresh)
    }
}
