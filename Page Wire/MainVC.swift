//
//  MainVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit
import GoogleSignIn
import Lottie
import BarcodeScanner
import FirebaseDatabase

class MainVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var barcodeButton: UIButton!
    
    // MARK: - Variables
    private lazy var books: [BookModel] = []
    private var bookDataViewModel: BookDataViewModel?
    private var searchBarText: String = ""
    private weak var barcodeScanner: BarcodeScannerViewController?
    private var scannedBook: BookModel?
    
    private let realtimeDatabase = Database.database().reference()
    
    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bookDataViewModel = BookDataViewModel()
        parseBookList()
    }
}

// MARK: - IBActions
extension MainVC {
    @IBAction func searchButtonAction(_ sender: Any) {
        searchBooks()
    }
    
    @IBAction func scanBarcodeAction(_ sender: Any) {
        let barcodeScanner = makeBarcodeScannerVC()
        barcodeScanner.title = "Barcode Scanner"
        present(barcodeScanner, animated: true, completion: nil)
    }
}

// MARK: - Functions
extension MainVC {
    private func setUI() {
        searchBar.delegate = self
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.label], for: UIControl.State.selected)
        hideKeyboardWhenTappedAround()
    }
    
    private func searchBooks() {
        guard !searchBarText.isEmpty else {
            return showAlert(title: "", message: "Search Text can not be empty!", okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        }
        self.filterBooks()
    }
    
    private func parseBookList() {
        // TODO: Calculate time.
        DispatchQueue.main.async {
            if let response = DecoderHelper.decode(resourcePath: "books", BookList.self) {
                BookManager.shared.bookList = response.books
                self.books = response.books.unique { $0.name }
            }
        }
    }
    
    private enum FilterType: String {
        case name = "name"
        case author = "author"
    }
    
    private func filterBooks() {
        showLoadingAnimation()
        if segmentedControl.selectedSegmentIndex == 0 {
            filterBookNames(filterType: .name) { filteredBookNames in
                self.hideLoadingAnimaton()
                self.goToBookResults(filteredBookNames)
            }
        } else {
            filterBookNames(filterType: .author) { filteredBookAuthors in
                self.hideLoadingAnimaton()
                self.goToBookResults(filteredBookAuthors)
            }
        }
    }
    
    private func filterBookNames(filterType: FilterType, _ completion: @escaping ([BookModel]) -> Void) {
        realtimeDatabase.child("Books").queryOrdered(byChild: filterType.rawValue).queryStarting(atValue: searchBarText).queryEnding(atValue: searchBarText + "\u{f8ff}").observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.exists() != false else {
                print("Snapshot does not exists.")
                return completion([])
            }
            
            guard let filteredBooks = snapshot.value as? [String: Any] else {
                return completion([])
            }
            
            var book = BookModel()
            var books: [BookModel] = []
            
            for filteredBook in filteredBooks.values {
                book.name = (filteredBook as? [String: Any])!["name"] as? String
                book.author = (filteredBook as? [String: Any])!["author"] as? String
                book.publisher = (filteredBook as? [String: Any])!["publisher"] as? String
                book.genre = (filteredBook as? [String: Any])!["genre"] as? String
                book.pages = (filteredBook as? [String: Any])!["pages"] as? Int
                book.isbn = (filteredBook as? [String: Any])!["isbn"] as? Int
                book.isFavorited = (filteredBook as? [String: Any])!["isFavorited"] as? Bool
                book.siteData = (filteredBook as? [String: Any])!["siteData"] as? [BookSiteData]
                book.artwork = (filteredBook as? [String: Any])!["artwork"] as? String
                book.info = (filteredBook as? [String: Any])!["info"] as? String
                book.otherPublishers = (filteredBook as? [String: Any])!["otherPublishers"] as? [String: Int]
                book.isScanned = (filteredBook as? [String: Any])!["isScanned"] as? Bool
                books.append(book)
            }
            completion(books)
        })
    }
    
    // MARK: Old filtering methods.
//    private func filterBookNames() {
//        let filteredBookNames = books.filter { ($0.name ?? "").lowercased().contains(searchBarText.lowercased()) }
//        guard !filteredBookNames.isEmpty else { return showSearchNotFoundError() }
//        goToBookResults(filteredBookNames)
//    }
    
//    private func filterBookAuthors() {
//        let filteredBookAuthors = books.filter { ($0.author ?? "").lowercased().contains(searchBarText.lowercased()) }
//        guard !filteredBookAuthors.isEmpty else { return showSearchNotFoundError() }
//        goToBookResults(filteredBookAuthors)
//    }
    
    private func showSearchNotFoundError() {
        showAlert(title: "", message: "Book not found.", okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
    }
    
    private func makeBarcodeScannerVC() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        return viewController
    }
    
    private func findBookWithISBN(_ isbn: String) {
        guard let scanner = barcodeScanner else { return }
        if let index = books.firstIndex(where: { "\($0.isbn)" == isbn}) {
            let book = books[index]
            scanner.dismiss(animated: true, completion: nil)
            goToBookDetail(book)
        } else {
            scannedBook = BookModel()
            scannedBook?.isbn = Int(isbn)
            scannedBook?.isScanned = true
            bookDataViewModel?.book = scannedBook
            bookDataViewModel?.siteDataDelegate = self
            bookDataViewModel?.getBookDataForSites()
        }
    }
}

// MARK: - Book Data From Site
extension MainVC: BookDataFromSite {
    func getBookDataForSites(_ book: BookModel?, _ isFinished: Bool) {
        scannedBook = book
        if let scanned = scannedBook, isFinished {
            self.scannedBook?.siteData?.sort(by: { $0.price! < $1.price! })
            asyncOperation {
                self.barcodeScanner?.dismiss(animated: true, completion: nil)
                self.goToBookDetail(scanned)
            }
        }
    }
}

// MARK: - Navigation Functions
extension MainVC {
    private func goToBookResults(_ books: [BookModel]) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookResultsVC") as! BookResultsVC
        vc.searchText = searchBarText
        vc.searchType = segmentedControl.selectedSegmentIndex == 0 ? .title : .author
        vc.books = books
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToBookDetail(_ book: BookModel) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        vc.book = book
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Search Bar Delegates
extension MainVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.isAlphaNumeric else { return false }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        searchBarText = text
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBooks()
    }
}

// MARK: - Barcode Scanner Delegates
extension MainVC: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        delayOperation(delayTime: 2.0) {
            self.barcodeScanner = controller
            print(code)
            self.findBookWithISBN(code)
        }
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
