//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit

public extension UIView {
    func setupConstraints(with view: UIView) {
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}