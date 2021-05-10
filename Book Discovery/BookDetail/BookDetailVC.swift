//
//  BookDetailVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 10.05.2021.
//

import UIKit

class BookDetailVC: UIViewController {

    // MARK: - Outlets -
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var favoriteButton: UIBarButtonItem!
    
    // MARK: - Variables -
    var book: BookModel?

    // MARK: - LIFECYCLE -
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BookDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailsTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(removeBookFromFavorites(_:)), name: .removeBookFromFavorites, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfBookIsFavorited()
    }

    @IBAction func favoriteAction(_ sender: UIBarButtonItem) {
        checkFavoriteActionForBook()
    }
    
    private func checkFavoriteActionForBook() {
        if favoriteButton.tag == 0 {
            FavoriteBooksCache.addToFavorites(book!)
            book?.isFavorited = true
            favoriteButton.image = UIImage(systemName: "heart.fill")
            favoriteButton.tag = 1
        } else {
            FavoriteBooksCache.removeFromFavorites(book!)
            book?.isFavorited = false
            favoriteButton.image = UIImage(systemName: "heart")
            favoriteButton.tag = 0
        }
    }
    
    private func checkIfBookIsFavorited() {
        guard let isFavorited = book?.isFavorited else { return }
        if isFavorited {
            favoriteButton.image = UIImage(systemName: "heart.fill")
            favoriteButton.tag = 1
        } else {
            favoriteButton.image = UIImage(systemName: "heart")
            favoriteButton.tag = 0
        }
    }
    
    @objc func removeBookFromFavorites(_ notification: Notification) {
        if let removedBook = notification.userInfo!["book"] as? BookModel {
            if removedBook == book {
                book?.isFavorited = false
            }
        }
    }
    
}

// MARK: - Favorite Book Delegate -
extension BookDetailVC: FavoriteBook {
    func changeFavoriteState(_ favoriteBook: BookModel?) {
        guard book != nil else { return }
        guard let favBook = favoriteBook else { return }
        let isFavorited = favBook.isFavorited ?? false
        book?.isFavorited = isFavorited
        if isFavorited {
            FavoriteBooksCache.addToFavorites(book!)
        } else {
            FavoriteBooksCache.removeFromFavorites(book!)
        }
    }
}

// MARK: - Table View Delegate, Datasource -
extension BookDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsTableViewCell", for: indexPath) as? BookDetailsTableViewCell else { return UITableViewCell() }
            cell.book = book
            cell.setBook()
        } else {
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UIScreen.main.bounds.size.height / 2
        } else {
            return UITableView.automaticDimension
        }
    }
}
