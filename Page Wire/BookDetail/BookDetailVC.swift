//
//  BookDetailVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 10.05.2021.
//

import UIKit

class BookDetailVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Variables
    var book: BookModel?
    private var bookDataViewModel: BookDataViewModel?
    private var favoriteButton: UIBarButtonItem!
    var isComingFromFavorites: Bool = false
    weak var favoriteDelegate: FavoriteBook?
    
    lazy var pickerView: CustomPickerView = {
        let picker = CustomPickerView()
        return picker
    }()
    private var pickerOpened: Bool = false
    
    private var publisherList: [String] = []
    private var currentPublisher: String = ""
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingAnimation()
        loadOtherPublishers()
        bookDataViewModel = BookDataViewModel(book: book!)
        bookDataViewModel?.siteDataDelegate = self
        bookDataViewModel?.getBookDataForSites()
        tableView.register(UINib(nibName: "BookDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailsTableViewCell")
        tableView.register(UINib(nibName: "BookPricesTableViewCell", bundle: nil), forCellReuseIdentifier: "BookPricesTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(removeBookFromFavorites(_:)), name: .removeBookFromFavorites, object: nil)
        changeFavoriteButtonVisibility()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePicker)))
        addPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isComingFromFavorites { checkIfBookIsFavorited() }
    }
}

// MARK: - Book Data From Site
extension BookDetailVC: BookDataFromSite {
    func getBookDataForSites(_ book: BookModel?, _ isFinished: Bool) {
        self.book = book
        if isFinished {
            // Sort books on viewModel for lowest price ascending
            //self.book?.siteData?.sort(by: { $0.site!.rawValue > $1.site!.rawValue})
            asyncOperation {
                self.tableView.reloadData()
                if !self.isComingFromFavorites {
                    self.favoriteButton.isEnabled = true
                }
                self.hideLoadingAnimaton()
            }
        }
    }
}

// MARK: - Other Publishers
extension BookDetailVC {
    private func loadOtherPublishers() {
        book?.otherPublishers = []
        for item in BookManager.shared.bookList {
            if book?.name == item.name, book?.author == item.author {
                let otherPublisher = [item.publisher: item.pages]
                book?.otherPublishers?.append(otherPublisher)
                publisherList.append(item.publisher)
            }
        }
    }
}

// MARK: - Favorite Book Functions
extension BookDetailVC {
    private func changeFavoriteButtonVisibility() {
        if isComingFromFavorites {
            navigationItem.rightBarButtonItems = []
        } else {
            favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favoriteAction))
            favoriteButton.tintColor = #colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1)
            favoriteButton.isEnabled = false
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
        pickerView.changeSelectedItem(item)
        book?.publisher = item
        changePageLabel(publisher: item)
    }
    
    private func changePageLabel(publisher: String) {
        guard let otherPublishers = book?.otherPublishers else { return }
        for item in otherPublishers {
            if let pageNumber = item["\(publisher)"] {
                book?.pages = pageNumber
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                break
            }
        }
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
            currentPublisher = cell.publisherLabel.text ?? ""
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
