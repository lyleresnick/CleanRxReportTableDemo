//  Copyright © 2020 Lyle Resnick. All rights reserved.

import UIKit
import RxSwift
import RxEnumKit

class TransactionListViewController: UIViewController, SpinnerAttachable {

    var presenter: TransactionListPresenter!
    @IBOutlet private weak var tableView: UITableView!
    private var adapter: TransactionListAdapter!
    private var spinnerView: UIActivityIndicatorView!
    private let disposeBag = DisposeBag()

    private let input = PublishSubject<TransactionListPresenterInput>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TransactionListConnector(viewController: self).configure()
        adapter = TransactionListAdapter()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = adapter
        spinnerView = attachSpinner()
        spinnerView.hidesWhenStopped = true

        let output = presenter.transform(input: input)
            .publish()

        output.capture(case: TransactionListPresenterOutput.refresh)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .initialize:
                    self.spinnerView.startAnimating()
                case let .showReport(rows):
                    self.spinnerView.stopAnimating()
                    self.adapter.rows = rows
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        output.connect()
            .disposed(by: disposeBag)
        
        input.onNext(.refreshTwoSource)
//        input.onNext(.refreshOneSource)
    }
}

