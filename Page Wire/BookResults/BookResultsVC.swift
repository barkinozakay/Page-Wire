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
    private var bookDataViewModel: BookDataViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingAnimation()
        bookDataViewModel = BookDataViewModel(books: books)
        bookDataViewModel?.artworkDelegate = self
        //bookDataViewModel?.getBookArtworkUrl()
        hideLoadingAnimaton()
        setFavoritedBooks()
        tableView.register(UINib(nibName: "BookResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookResultsTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(removeBookFromFavorites(_:)), name: .removeBookFromFavorites, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Functions -
extension BookResultsVC {
    private func setFavoritedBooks() {
        let favoriteBooks = FavoriteBooksCache.getFavorites()
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
    
    @objc private func removeBookFromFavorites(_ notification: Notification) {
        if let removedBook = notification.userInfo!["book"] as? BookModel {
            for i in 0..<books.count {
                if removedBook == books[i] {
                    books[i].isFavorited = false
                }
            }
        }
    }
    
    private func goToBookDetail(_ book: BookModel) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        vc.book = book
        vc.favoriteDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Book Artwork Delegate -
extension BookResultsVC: BookArtworkFromSite {
    func getBookArtworkUrl(_ artwork: String, _ index: Int) {
        self.books[index].artwork = artwork
        asyncOperation {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
        }
    }
}

// MARK: - Favorite Book Delegate -
extension BookResultsVC: FavoriteBook {
    func changeFavoriteState(_ favoriteBook: BookModel?) {
        guard let newBook = favoriteBook else { return }
        let isFavorited = newBook.isFavorited ?? false
        var oldBook = newBook
        oldBook.isFavorited = !isFavorited
        guard let index = books.firstIndex(of: oldBook) else { return }
        if isFavorited {
            books[index].isFavorited = true
            FavoriteBooksCache.addToFavorites(newBook)
        } else {
            books[index].isFavorited = false
            FavoriteBooksCache.removeFromFavorites(newBook)
        }
        tableView.reloadData()
    }
}

// MARK: - Table View Delegate, Datasource -
extension BookResultsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookResultsTableViewCell", for: indexPath) as? BookResultsTableViewCell else { return UITableViewCell() }
        cell.book = books[indexPath.row]
        cell.setBook()
        cell.favoriteDelegate = self
        cell.setFavoriteButtonImage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToBookDetail(books[indexPath.row])
    }
}
