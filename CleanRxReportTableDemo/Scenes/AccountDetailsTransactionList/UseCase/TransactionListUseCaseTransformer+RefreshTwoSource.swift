//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import RxSwift
import RxEnumKit

extension TransactionListUseCaseTransformer {

    func refreshTwoSourceTransform(input: Observable<TransactionListUseCaseInput>) -> Observable<TransactionListUseCaseOutput> {
        
        func transform(transactions: Single<[Transaction]>, group: TransactionGroup, totals: AnyObserver<Double>) -> Observable<TransactionListRefreshUseCaseOutput> {
            return transactions.asObservable()
                .map { transactions -> [TransactionListRefreshUseCaseOutput] in
                    guard transactions.count > 0 else { return [.noTransactionsMessage(group: group)] }

                    var (list, total ) =  transactions
                        .reduce(into: [:]) { $0[$1.date, default: []].append($1) }
                        .map { ($0.key, $0.value) }
                        .sorted { $0.0 < $1.0 }
                        .reduce(into:(list: [], total: 0), transformGroupToUseCaseOutput)
                    
                    totals.onNext(total)
                    list += [.footer(total: total)]
                    return list
                }
                .flatMap { Observable.from($0) }
                .startWith(.header(group: group))
                .catchError { error in
                    switch error {
                    case TransactionError.notFound:
                        return .just(.notFoundMessage(group: group))
                    case let TransactionError.failure(code, description):
                        return .just(.failure(code: code, description: description))
                    default:
                        return .empty()
                    }
                }
            
        }

        func transformGroupToUseCaseOutput(
                            _ accumulator: inout (list: [TransactionListRefreshUseCaseOutput], total: Double),
                            _ group: (key: Date, value: [Transaction]) ) {
               
            accumulator.list += [.subheader(date: group.key)]
            accumulator.list += group.value.map { .detail(description: $0.description, amount: $0.amount) }
            accumulator.list += [.subfooter]
            
            accumulator.total += group.value.reduce(0) { $0 + $1.amount }
        }
        
        return input.filter(case: TransactionListUseCaseInput.refreshTwoSource)
            .flatMap { _ -> Observable<TransactionListRefreshUseCaseOutput> in
                let totals = ReplaySubject<Double>.create(bufferSize: 2)
                
                let grandTotal = totals
                    .reduce(0, accumulator: +)
                    .map(TransactionListRefreshUseCaseOutput.grandFooter)
                
                return .concat(
                        .just(TransactionListRefreshUseCaseOutput.initialize),
                        Observable.concat(
                            transform(transactions: self.transactionManager.fetchAuthorizedTransactions(), group: .authorized, totals: totals.asObserver()),
                            transform(transactions: self.transactionManager.fetchPostedTransactions(), group: .posted, totals: totals.asObserver())
                        )
                            .do( onCompleted: { totals.onCompleted() }),
                        grandTotal,
                        .just(TransactionListRefreshUseCaseOutput.finalize)
                    )
            }
            .map(TransactionListUseCaseOutput.refresh)
    }
}
