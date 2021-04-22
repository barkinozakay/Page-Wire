//
//  BookResultsVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit

class BookResultsVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    var searchText: String = ""
    var searchType: BookSearchType = .title
    var books: [BookModel] = []
    private var favoriteBooks: [BookModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SerachTextTableViewCell", bundle: nil), forCellReuseIdentifier: "SerachTextTableViewCell")
        tableView.register(UINib(nibName: "BookResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookResultsTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFavoritedBooks()
        tableView.reloadData()
    }
}

// MARK: - Functions -
extension BookResultsVC {
    private func setFavoritedBooks() {
        favoriteBooks = FavoriteBooksCache.getFavorites()
        for i in 0..<books.count {
            books[i].isFavorited = false
            for j in 0..<favoriteBooks.count {
                if books[i].isbn == favoriteBooks[j].isbn {
                    books[j].isFavorited = true
                    break
                }
            }
        }
    }
}

// MARK: - Favorite Book Delegate -
extension BookResultsVC: FavoriteBook {
    func changeFavoriteState(_ favoriteBook: BookModel?) {
        guard let book = favoriteBook else { return }
        let isFavorited = book.isFavorited ?? false
        var oldBook = book
        oldBook.isFavorited = !isFavorited
        guard let index = books.firstIndex(of: oldBook) else { return }
        if isFavorited {
            books[index].isFavorited = true
            FavoriteBooksCache.addToFavorites(book)
        } else {
            books[index].isFavorited = false
            FavoriteBooksCache.removeFromFavorites(book)
        }
        tableView.reloadData()
    }
}

// MARK: - Table View Delegate, Datasource -
extension BookResultsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTextTableViewCell", for: indexPath) as? SearchResultTextTableViewCell else { return UITableViewCell() }
            cell.searchTextLabel.text = "Showing \(searchType.rawValue) results for \"\(searchText)\""
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookResultsTableViewCell", for: indexPath) as? BookResultsTableViewCell else { return UITableViewCell() }
            cell.book = books[indexPath.row]
            cell.setBook()
            cell.favoriteDelegate = self
            cell.setFavoriteButtonImage()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
}
