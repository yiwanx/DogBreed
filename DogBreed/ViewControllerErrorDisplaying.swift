//
// Created by Ivan Petukhov on 03.08.2022.
//

import UIKit

protocol ErrorDisplaying: AnyObject {
    func displayError(_ error: Error)
}

extension ErrorDisplaying where Self: UIViewController {
    func displayError(_ error: Error) {
        let alertVC = UIAlertController.errorStyle(with: error)
        present(alertVC, animated: true)
    }
}

extension UIAlertController {
    static func errorStyle(with error: Error) -> UIAlertController {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return vc
    }
}