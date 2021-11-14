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
        tableView.register(UINib(nibName: "BookResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookResultsTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Functions -
extension BookResultsVC {
    private func goToBookDetail(_ book: BookModel) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        vc.book = book
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToBookDetail(books[indexPath.row])
    }
}
