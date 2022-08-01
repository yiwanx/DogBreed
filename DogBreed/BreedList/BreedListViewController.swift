//
// Created by Ivan Petukhov on 30.07.2022.
//

import UIKit

protocol BreedListDisplayLogic: class {
    func display(_ list: [String])
}

class BreedListViewController: UIViewController, BreedListDisplayLogic {

    var interactor: BreedListBusinessLogic?

    var breedList: [String] = []

    var isFirstTime = true

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List of Dog Breeds"
        view.addSubview(tableView)
        view.setupConstraints(with: tableView)
        interactor?.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Reloading data when coming back to the screen from others.
        if !isFirstTime {
            interactor?.load()
        }

        isFirstTime = false
    }

    func display(_ list: [String]) {
        breedList = list
        DispatchQueue.main.async { [weak tableView] in
            tableView?.reloadData()
        }

    }

    func setupAutoLayout() {
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func routeToPhotos(for breedString: String) {
        let vc = BreedPhotosViewController()
        let interactor = BreedPhotosInteractor(breedString: breedString)
        vc.interactor = interactor
        vc.hidesBottomBarWhenPushed = true
        interactor.viewController = vc
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BreedListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        breedList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.transform = .capitalized
        content.text = breedList[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}
extension BreedListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < breedList.count else {
            assertionFailure("Row doesnt exist")
            return
        }
        routeToPhotos(for: breedList[indexPath.row])
    }
}