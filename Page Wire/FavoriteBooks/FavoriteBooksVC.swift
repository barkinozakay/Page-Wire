//
//  FavoriteBooksVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 22.04.2021.
//

import UIKit

protocol FavoriteBook: AnyObject {
    func changeFavoriteState(_ favoriteBook: BookModel?)
}

class FavoriteBooksVC: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateView: UIView!
    
    var favoriteBooks: [BookModel] = []
    private var showEmptyState: Bool = false {
        didSet {
            tableView.isHidden = showEmptyState
            emptyStateView.isHidden = !showEmptyState
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BookResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookResultsTableViewCell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoriteBooks = FavoriteBooksManager.shared.getFavorites()
        checkForEmptyState()
    }
}

// MARK: - Functions -
extension FavoriteBooksVC {
    private func checkForEmptyState() {
        if favoriteBooks.isEmpty {
            showEmptyState = true
        } else {
            showEmptyState = false
            tableView.reloadData()
        }
    }
    
    private func goToBookDetail(_ book: BookModel) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        vc.book = book
        vc.isComingFromFavorites = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Table View Delegate, Datasource -
extension FavoriteBooksVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { favoriteBooks.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookResultsTableViewCell", for: indexPath) as? BookResultsTableViewCell else { return UITableViewCell() }
        cell.book = favoriteBooks[indexPath.row]
        cell.setBook()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToBookDetail(favoriteBooks[indexPath.row])
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
            FavoriteBooksManager.shared.removeFromFavorites(favoriteBooks[indexPath.row])
            NotificationCenter.default.post(name: .removeBookFromFavorites, object: nil, userInfo: ["book": favoriteBooks[indexPath.row]])
            favoriteBooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            checkForEmptyState()
        }
    }
    
}
