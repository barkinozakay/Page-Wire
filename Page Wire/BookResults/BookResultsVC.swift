//
//  BookResultsVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit
import CenteredCollectionView

class BookResultsVC: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    var searchText: String = ""
    var searchType: BookSearchType = .title
    var books: [BookModel] = []
    private var bookDataViewModel: BookDataViewModel?
    
    let cellPercentWidth: CGFloat = 0.7
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        showLoadingAnimation()
        bookDataViewModel = BookDataViewModel(books: books)
        bookDataViewModel?.artworkDelegate = self
        //bookDataViewModel?.getBookArtworkUrl()
        hideLoadingAnimaton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
}

// MARK: - Functions -
extension BookResultsVC {
    private func setUpCollectionView() {
        collectionView.register(UINib(nibName: "BookResultsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookResultsCollectionViewCell")
        centeredCollectionViewFlowLayout = collectionView.collectionViewLayout as? CenteredCollectionViewFlowLayout
        collectionView.decelerationRate = .normal
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: view.bounds.height * cellPercentWidth * cellPercentWidth
        )
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
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
            self.collectionView.reloadItems(at:  [IndexPath(row: index, section: 1)])
        }
    }
}

// MARK: - Collection View Delegate, Datasource
extension BookResultsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? BookResultsCollectionViewCell else { return UICollectionViewCell() }
        cell.book = books[indexPath.item]
        cell.setBook()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goToBookDetail(books[indexPath.item])
    }
}

// MARK: - Table View Delegate, Datasource -
//extension BookResultsVC: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int { 1 }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        books.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookResultsTableViewCell", for: indexPath) as? BookResultsTableViewCell else { return UITableViewCell() }
//        cell.book = books[indexPath.row]
//        cell.setBook()
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        goToBookDetail(books[indexPath.row])
//    }
//}
