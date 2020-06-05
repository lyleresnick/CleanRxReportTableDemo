//  Copyright © 2020 Lyle Resnick. All rights reserved.

import UIKit

class TransactionListConnector {
    
    let viewController: TransactionListViewController
    let presenter: TransactionListPresenter
    
    init(viewController: TransactionListViewController, presenter: TransactionListPresenter) {
        
        self.viewController = viewController
        self.presenter = presenter
    }
    
    convenience init(viewController: TransactionListViewController, entityGateway: EntityGateway = EntityGatewayFactory.gateway) {
        
        let useCase = TransactionListUseCase(entityGateway: entityGateway)
        let presenter = TransactionListPresenter(useCase: useCase)
        
        self.init(viewController: viewController, presenter: presenter)
    }
    
    func configure() {
        viewController.presenter = presenter
    }
}
