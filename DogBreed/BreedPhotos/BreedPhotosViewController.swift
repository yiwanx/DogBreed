//
// Created by Ivan Petukhov on 30.07.2022.
//

import UIKit

protocol BreedPhotosDisplayLogic: class {
    func displayPhotos(_ models: [BreedPhotoModel])
}
class BreedPhotosViewController: UIViewController, BreedPhotosDisplayLogic {

    var interactor: BreedPhotosBusinessLogic?
    var gridCollectionView: UICollectionView!

    var models: [BreedPhotoModel] = []

    private var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let sideLength = UIScreen.main.bounds.size.width / 3 - 1
        layout.itemSize = CGSize(width: sideLength, height: sideLength)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        return layout
    }()

    func setGridCollectionView() -> UICollectionView {
        var gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        gridCollectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.reuseId)
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        gridCollectionView.prefetchDataSource = self
        return gridCollectionView
    }

    override func loadView() {
        super.loadView()
        gridCollectionView = setGridCollectionView()
        view.addSubview(gridCollectionView)
        gridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        gridCollectionView.setupConstraints(with: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = interactor?.breedString.capitalized
        interactor?.load()
    }

    func displayPhotos(_ models: [BreedPhotoModel]) {
        self.models = models
        DispatchQueue.main.async { [weak gridCollectionView] in
            gridCollectionView?.reloadData()
        }
    }

    func routeToDetailedPhoto(_ url: URL) {
        let vc = BreedPhotoDetailViewController()
        let interactor = BreedPhotoDetailInteractor(url: url)
        vc.interactor = interactor
        interactor.viewController = vc
        DispatchQueue.main.async { [weak navigationController] in
            navigationController?.present(vc, animated: true)
        }
    }
}

extension BreedPhotosViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        routeToDetailedPhoto(model.imageUrl)
    }
}

extension BreedPhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            Task {
                do {
                    try await ImageLoader.shared.preFetch(model.imageUrl)
                } catch {
                    print("Prefetch Error \(error)")
                }
            }
        }
    }
}

extension BreedPhotosViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.reuseId, for: indexPath)
                as? PhotoCollectionCell, indexPath.row < models.count  else { return .init() }
        let model = models[indexPath.row]
        cell.id = model.imageUrl.relativeString
        Task { () -> _ in
            let image = try await ImageLoader.shared.fetch(model.imageUrl)
            await MainActor.run {
                if cell.id == model.imageUrl.relativeString {
                    cell.imageView.image = image
                    cell.imageView.contentMode = .scaleAspectFill
                }
            }
        }
        return cell
    }
}