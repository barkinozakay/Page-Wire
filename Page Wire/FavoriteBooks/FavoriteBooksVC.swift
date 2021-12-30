//
//  FavoriteBooksVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 22.04.2021.
//

import UIKit
import Hero

class FavoriteBooksVC: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateView: UIView!
    
    var favoritedBooks: [BookModel] = []
    private var showEmptyState: Bool = false {
        didSet {
            tableView.isHidden = showEmptyState
            emptyStateView.isHidden = !showEmptyState
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingAnimation()
        tableView.register(UINib(nibName: "BookResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookResultsTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        FavoriteBooksManager.shared.getFavoritedBooks({ favoritedBooks in
            self.favoritedBooks = favoritedBooks
            self.checkForEmptyState()
            self.hideLoadingAnimaton()
        })
        NotificationCenter.default.addObserver(self, selector: #selector(changeBookFavoriteStateFromDetail(_:)), name: .changeBookFavoriteStateFromDetail, object: nil)
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Functions
extension FavoriteBooksVC {
    private func checkForEmptyState() {
        showEmptyState = favoritedBooks.isEmpty ? true : false
        tableView.reloadData()
    }
    
    private func goToBookDetail(_ book: BookModel) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        vc.book = book
        vc.isComingFromFavorites = true
        vc.isHeroEnabled = true
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .pageIn(direction: .left), dismissing: .pageOut(direction: .right))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func changeBookFavoriteStateFromDetail(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let book = userInfo["book"] as? BookModel, let action = userInfo["action"] as? FavoriteBookAction else { return }
        switch action {
        case .add:
            favoritedBooks.append(book)
        case .remove:
            guard let index = favoritedBooks.firstIndex(where: { $0.isbn == book.isbn }) else { return }
            favoritedBooks.remove(at: index)
        }
        checkForEmptyState()
    }
}

// MARK: - Table View Delegate, Datasource
extension FavoriteBooksVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { favoritedBooks.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookResultsTableViewCell", for: indexPath) as? BookResultsTableViewCell else { return UITableViewCell() }
        cell.book = favoritedBooks[indexPath.row]
        cell.setBook()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToBookDetail(favoritedBooks[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            FavoriteBooksManager.shared.removeBookFromFavorites(favoritedBooks[indexPath.row]) { isSuccess in
                if isSuccess {
                    NotificationCenter.default.post(name: .removeBookFromFavorites, object: nil, userInfo: ["book": self.favoritedBooks[indexPath.row]])
                    self.favoritedBooks.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.checkForEmptyState()
                } else {
                    self.showErrorAlert()
                }
            }
        }
    }
}
