//
//  BookDetailVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 10.05.2021.
//

import UIKit
import Hero

class BookDetailVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Variables
    var book: BookModel?
    var isBookScanned: Bool = false
    private var bookDataViewModel: BookDataViewModel?
    private var favoriteButton: UIBarButtonItem!
    var isComingFromFavorites: Bool = false
    
    lazy var pickerView: CustomPickerView = {
        let picker = CustomPickerView()
        return picker
    }()
    private var pickerOpened: Bool = false
    
    private var publisherList: [String] = []
    private var currentPublisher: String = ""
    
    private var isbnList: [String: Int] = [:]
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        bookDataViewModel = BookDataViewModel()
        bookDataViewModel?.book = book
        bookDataViewModel?.siteDataDelegate = self
        decideToGetBookData()
        addFavoriteButton()
        checkIfBookIsFavorited()
        loadOtherPublishers()
        currentPublisher = book?.publisher ?? "-"
        tableView.register(UINib(nibName: "BookDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailsTableViewCell")
        tableView.register(UINib(nibName: "BookPricesTableViewCell", bundle: nil), forCellReuseIdentifier: "BookPricesTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(removeBookFromFavorites(_:)), name: .removeBookFromFavorites, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePicker)))
        addPickerView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Book Data From Site
extension BookDetailVC: BookDataFromSite {
    func getBookDataForSites(_ book: BookModel?, _ isFinished: Bool) {
        self.book = book
        if isFinished {
            asyncOperation {
                self.checkIfBookIsFavorited()
                self.tableView.reloadData()
                self.hideLoadingAnimaton()
            }
        }
    }
    
    private func decideToGetBookData() {
        let isScanned = book?.isScanned ?? false
        if !isScanned {
            showLoadingAnimation()
            bookDataViewModel?.getBookDataForSites()
        }
    }
}

// MARK: - Other Publishers
extension BookDetailVC {
    private func loadOtherPublishers() {
        guard !isBookScanned else { return }
        book?.otherPublishers = [:]
        for item in BookManager.shared.bookList {
            if book?.name == item.name, book?.author == item.author {
                guard let publisher = item.publisher else { continue }
                book?.otherPublishers?[publisher] = item.pages
                publisherList.append(publisher)
                isbnList[publisher] = item.isbn
            }
        }
    }
}

// MARK: - Favorite Book Functions
extension BookDetailVC {
    private func checkIfBookIsFavorited() {
        guard !isComingFromFavorites else {
            isComingFromFavorites = false
            return setFavoriteButtonStatus(true)
        }
        FavoriteBooksManager.shared.checkForFavoritedBook(book) { isFavorited in
            self.setFavoriteButtonStatus(isFavorited)
        }
    }
    
    private func setFavoriteButtonStatus(_ isFavorited: Bool) {
        self.favoriteButton.image = isFavorited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        self.favoriteButton.tag = isFavorited ? 1 : 0
    }
    
    private func addFavoriteButton() {
        favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favoriteAction))
        favoriteButton.tintColor = #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1)
        favoriteButton.isEnabled = true
        navigationItem.rightBarButtonItems = [favoriteButton]
    }
    
    @objc private func favoriteAction() {
        checkFavoriteActionForBook()
    }
    
    private func checkFavoriteActionForBook() {
        guard var detailBook = book else { return }
        favoriteButton.isEnabled = false
        if favoriteButton.tag == 0 {
            detailBook.isFavorited = true
            FavoriteBooksManager.shared.addBookToFavorites(detailBook) { isSuccess in
                if isSuccess {
                    self.book?.isFavorited = true
                    self.setFavoriteButtonStatus(true)
                    NotificationCenter.default.post(name: .changeBookFavoriteStateFromDetail, object: nil, userInfo: ["book": detailBook, "action": FavoriteBookAction.add])
                } else {
                    self.showErrorAlert()
                }
                self.favoriteButton.isEnabled = true
            }
        } else {
            detailBook.isFavorited = false
            FavoriteBooksManager.shared.removeBookFromFavorites(detailBook) { isSuccess in
                if isSuccess {
                    self.book?.isFavorited = false
                    self.setFavoriteButtonStatus(false)
                    NotificationCenter.default.post(name: .changeBookFavoriteStateFromDetail, object: nil, userInfo: ["book": detailBook, "action": FavoriteBookAction.remove])
                } else {
                    self.showErrorAlert()
                }
                self.favoriteButton.isEnabled = true
            }
        }
    }
    
    @objc func removeBookFromFavorites(_ notification: Notification) {
        if let removedBook = notification.userInfo!["book"] as? BookModel {
            if removedBook.isbn == book?.isbn {
                book?.isFavorited = false
                setFavoriteButtonStatus(false)
            }
        }
    }
}

// MARK: - BookDetailsTableViewCellDelegate
extension BookDetailVC: BookDetailsTableViewCellDelegate {
    func selectPublisher() {
        pickerOpened ? closePicker() : openPicker()
    }
    
    func showBookInfo() {
        guard let book = book else { return }
        let infoVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookInfoVC") as! BookInfoVC
        infoVC.book = book
        navigationController?.present(infoVC, animated: true, completion: nil)
    }
    
    func onArtworkTapped(_ image: UIImage?) {
        let artworkVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookArtwork") as! BookArtworkVC
        let navigationVC = UINavigationController(rootViewController: artworkVC)
        navigationVC.isHeroEnabled = true
        artworkVC.isHeroEnabled = true
        artworkVC.artworkImage = image
        navigationVC.modalTransitionStyle = .crossDissolve
        navigationVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(navigationVC, animated: true)
    }
}

// MARK: - Custom Picker
extension BookDetailVC: ApplyPickerItemProtocol {
    func addPickerView() {
        pickerView = CustomPickerView()
        let scrHeight = UIScreen.main.bounds.height
        let scrWidth = UIScreen.main.bounds.width
        pickerView.applyDelegate = self
        pickerView.dataSource = publisherList
        pickerView.frame = CGRect(x: 0, y: scrHeight, width: scrWidth, height: 300)
        view.addSubview(pickerView)
    }
    
    @objc func openPicker() {
        guard !pickerOpened else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerView.layer.position.y -= 300
            if let selectedIndex = self.pickerView.dataSource.firstIndex(of: self.currentPublisher) {
                self.pickerView.pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
                self.pickerOpened = true
            }
        }) { (_) in
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func closePicker() {
        guard pickerOpened else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerView.layer.position.y += 300
            self.pickerOpened = false
        }) { (_) in
            self.view.layoutIfNeeded()
        }
    }
    
    func apply(for item: String) {
        closePicker()
        showLoadingAnimation()
        pickerView.changeSelectedItem(item)
        book?.publisher = item
        currentPublisher = item
        changeIsbn(publisher: item)
        changePageNumber(publisher: item)
        bookDataViewModel?.book = book
        bookDataViewModel?.getBookDataForSites()
    }
    
    private func changePageNumber(publisher: String) {
        guard let pageNumber = book?.otherPublishers?[publisher] else { return }
        book?.pages = pageNumber
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    private func changeIsbn(publisher: String) {
        guard let isbn = isbnList[publisher] else { return }
        book?.isbn = isbn
    }
    
    func calculateLabelSize(text: String, fontSize: Int) -> CGSize {
        return (text as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular)])
    }
}

extension BookDetailVC: NavigateToSite {
    func navigateToSite(index: Int) {
        guard let urlString = book?.siteData?[index].url, !urlString.isEmpty, let url = URL(string: urlString) else { return }
        presentSafariViewController(with: url)
    }
}

// MARK: - Table View Delegate, Datasource
extension BookDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : (book?.siteData?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailsTableViewCell", for: indexPath) as? BookDetailsTableViewCell else { return UITableViewCell() }
            cell.book = book
            cell.delegate = self
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
