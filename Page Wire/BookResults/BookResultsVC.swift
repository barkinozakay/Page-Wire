//
//  BookResultsVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit
import CenteredCollectionView
import Hero

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
        bookDataViewModel?.getBookArtworkUrl()
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
        vc.isHeroEnabled = true
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .pageIn(direction: .left), dismissing: .pageOut(direction: .right))
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Book Artwork Delegate -
extension BookResultsVC: BookArtworkFromSite {
    func getBookArtworkUrl(_ artwork: String, _ index: Int) {
        books[index].artwork = artwork
        asyncOperation {
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

// MARK: - Collection View Delegate, Datasource
extension BookResultsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookResultsCollectionViewCell", for: indexPath) as? BookResultsCollectionViewCell else { return UICollectionViewCell() }
        cell.book = books[indexPath.item]
        cell.layer.cornerRadius = 8
        cell.setBook()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCenteredPage = centeredCollectionViewFlowLayout.currentCenteredPage
        if currentCenteredPage != indexPath.row {
            centeredCollectionViewFlowLayout.scrollToPage(index: indexPath.row, animated: true)
        } else {
            goToBookDetail(books[indexPath.item])
        }
    }
}
