//
//  CustomPickerView.swift
//  Kariyer.net
//
//  Created by Cemal Bayrı on 25.11.2019.
//  Copyright © 2019 Kariyer.net. All rights reserved.
//

import UIKit

protocol ApplyPickerItemProtocol: AnyObject {
    func apply(for item: String)
}

class CustomPickerView: UIView {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerActionButton: UIButton!
    
    weak var applyDelegate: ApplyPickerItemProtocol!

    var dataSource: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }

    private var selectedItem: String = "-"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    fileprivate func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        setUI()
    }

    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    func setUI() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func changeSelectedItem(_ item: String) {
        selectedItem = item
    }

    @IBAction func applyAction(_ sender: Any) {
        applyDelegate.apply(for: selectedItem)
    }
}

extension CustomPickerView: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = dataSource[row]
    }
}
