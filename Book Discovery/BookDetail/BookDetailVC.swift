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
    
    // MARK: - Variables -
    var book: BookModel?
    private var bookDataViewModel: BookDataViewModel?
    private var favoriteButton: UIBarButtonItem!
    lazy var isComingFromFavorites: Bool = false
    weak var favoriteDelegate: FavoriteBook?
    
    // MARK: - LIFECYCLE -
    override func viewDidLoad() {
        super.viewDidLoad()
        bookDataViewModel = BookDataViewModel(book: book!)
        setBookData()
        tableView.register(UINib(nibName: "BookDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailsTableViewCell")
        tableView.register(UINib(nibName: "BookPricesTableViewCell", bundle: nil), forCellReuseIdentifier: "BookPricesTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(removeBookFromFavorites(_:)), name: .removeBookFromFavorites, object: nil)
        changeFavoriteButtonVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isComingFromFavorites { checkIfBookIsFavorited() }
    }
    
    private func setBookData() {
        book?.sites = bookDataViewModel?.getBookDataForSites()
        // TODO: prices, discount ...
    }
}

// MARK: - Favorite Book Functions -
extension BookDetailVC {
    private func changeFavoriteButtonVisibility() {
        if isComingFromFavorites {
            navigationItem.rightBarButtonItems = []
        } else {
            favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favoriteAction))
            favoriteButton.tintColor = #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1)
            navigationItem.rightBarButtonItems = [favoriteButton]
        }
    }
    
    @objc private func favoriteAction() {
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
        favoriteDelegate?.changeFavoriteState(book)
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

extension BookDetailVC: NavigateToSite {
    func navigateToSite(index: Int) {
        guard let urlString = book?.sites?[index].url, !urlString.isEmpty, let url = URL(string: urlString) else { return }
        presentSafariViewController(with: url)
    }
}

// MARK: - Table View Delegate, Datasource -
extension BookDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : (book?.sites?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsTableViewCell", for: indexPath) as? BookDetailsTableViewCell else { return UITableViewCell() }
            cell.book = book
            cell.setBook()
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookPricesTableViewCell", for: indexPath) as? BookPricesTableViewCell else { return UITableViewCell() }
            cell.book = book
            cell.index = indexPath.row
            cell.setBookPricesCell()
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
