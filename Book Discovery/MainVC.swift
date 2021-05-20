//
//  MainVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit
import Lottie
import BarcodeScanner

class MainVC: UIViewController {

    // MARK: - Outlets -
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var barcodeButton: UIButton!
    
    // MARK: - Variables -
    private lazy var books: [BookModel] = []
    private lazy var searchBarText: String = ""
    private weak var barcodeScanner: BarcodeScannerViewController?
    
    // MARK: - LIFECYCLE -
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        parseBookList()
    }
}

// MARK: - IBActions-
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

// MARK: - Functions -
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
        showLoadingAnimation()
        // TODO: - Remove Delay -
        delayOperation(delayTime: 0.25) {
            self.filterBooks()
        }
    }
    
    private func parseBookList() {
        DispatchQueue.main.async {
            if let response = DecoderHelper.decode(resourcePath: "books", BookList.self) {
                self.books = response.books
            }
        }
    }
    
    private func filterBooks() {
        segmentedControl.selectedSegmentIndex == 0 ? filterBookNames() : filterBookAuthors()
    }
    
    private func filterBookNames() {
        let filteredBookNames = books.filter { $0.name.lowercased().contains(searchBarText.lowercased()) }
        guard !filteredBookNames.isEmpty else { return showSearchNotFoundError() }
        goToBookResults(filteredBookNames)
    }
    
    private func filterBookAuthors() {
        let filteredBookAuthors = books.filter { $0.author.lowercased().contains(searchBarText.lowercased()) }
        guard !filteredBookAuthors.isEmpty else { return showSearchNotFoundError() }
        goToBookResults(filteredBookAuthors)
    }
    
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
        guard let index = books.firstIndex(where: { "\($0.isbn)" == isbn}) else {
            return scanner.resetWithError(message: "Book not found.")
        }
        let book = books[index]
        scanner.dismiss(animated: true, completion: nil)
        goToBookDetail(book)
    }
}

// MARK: - Navigation Functions -
extension MainVC {
    private func goToBookResults(_ books: [BookModel]) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookResultsVC") as! BookResultsVC
        vc.searchText = searchBarText
        vc.searchType = segmentedControl.selectedSegmentIndex == 0 ? .title : .author
        vc.books = books
        hideLoadingAnimaton()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToBookDetail(_ book: BookModel) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookDetailVC") as! BookDetailVC
        vc.book = book
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Search Bar Delegates -
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

// MARK: - Barcode Scanner Delegates -
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
