//
// Created by Ivan Petukhov on 31.07.2022.
//

import UIKit


class PhotoCollectionCell: UICollectionViewCell {

    var imageView = UIImageView()
    var activityIndicator = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.setupConstraints(with: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.stopAnimating()
    }
}

extension UICollectionViewCell {
    static var reuseId: String { .init(reflecting: Self.self) }
}

