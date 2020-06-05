//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import RxSwift
import RxEnumKit

class TransactionListPresenter {
    
    let useCase: TransactionListUseCase

    fileprivate static let outboundDateFormatter = DateFormatter.dateFormatter( format: "MMM' 'dd', 'yyyy" )

    required init(useCase: TransactionListUseCase) {
        self.useCase = useCase
    }

    func transform(input: Observable<TransactionListPresenterInput>) -> Observable<TransactionListPresenterOutput> {

        let output = useCase.transform(input: input.compactMap(toUseCaseInput))
        
        func refresh() -> Observable<TransactionListPresenterOutput> {
        
            func formatDate(date: Date) -> String { Self.outboundDateFormatter.string(from: date) }
            
            func toRefreshPresenterOutput(useCaseOutput: TransactionListRefreshUseCaseOutput) -> TransactionListRefreshPresenterOutput? {
                switch useCaseOutput {
                case .initialize:
                    return .initialize
                default:
                    return nil
                }
            }

            var odd = false
            var rows =  ReplaySubject<TransactionListRowViewModel>.createUnbounded()
            let rowsSubject = PublishSubject<ReplaySubject<TransactionListRowViewModel>>()

            let general = output.capture(case: TransactionListUseCaseOutput.refresh)
                .do( onNext: { row in
                    switch row {
                    case .initialize:
                        odd = false
                        rows = ReplaySubject<TransactionListRowViewModel>.createUnbounded()
                    case let .header(group):
                        rows.onNext(.header(title: group.toString() + " Transactions"));
                    case let .subheader(date):
                        odd = !odd;
                        rows.onNext(.subheader(title: formatDate(date: date), odd: odd))
                    case let .detail(description, amount):
                        rows.onNext(.detail(description: description, amount: amount.asString, odd: odd));
                    case .subfooter:
                        rows.onNext(.subfooter(odd: odd));
                    case let .footer(total):
                        odd = !odd;
                        rows.onNext(.footer(total: total.asString, odd: odd));
                    case let .grandFooter(grandTotal):
                        rows.onNext(.grandfooter(total: grandTotal.asString));
                    case let .notFoundMessage(group):
                        rows.onNext(.message(message: "\(group.toString()) Transactions are not currently available."))
                    case .notFoundMessageAll:
                        rows.onNext(.message(message: "Transactions are not currently available."))
                    case let .noTransactionsMessage(group):
                        rows.onNext(.message(message: "There are no \(group.toString()) Transactions in this period" ));
                    case let .failure(code, description):
                        rows.onNext(.message(message: "Error: \(code), Message: \(description)" ));
                    case .finalize:
                        rows.onCompleted()
                        rowsSubject.onNext(rows)
                    }
                })
                .compactMap(toRefreshPresenterOutput)
                
            let showReport = rowsSubject
                .flatMapLatest { rows in
                    return rows
                        .toArray().asObservable()
                        .map(TransactionListRefreshPresenterOutput.showReport)
                }
            
            return Observable.merge(general, showReport)
                .map(TransactionListPresenterOutput.refresh)
        }
        
        let refreshOutput = refresh()
        return Observable.merge(refreshOutput)
    }
    
    func toUseCaseInput(presenterInput: TransactionListPresenterInput) -> TransactionListUseCaseInput? {
        switch presenterInput {
        case .refreshTwoSource:
            return .refreshTwoSource
            case .refreshOneSource:
                return .refreshOneSource
        }
    }
}

// MARK: -

private extension Double {
    var asString: String {
        return String(format: "%0.2f", self)
    }
}
