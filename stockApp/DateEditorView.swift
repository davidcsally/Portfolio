//
//  DateEditorView.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class DateEditorView: UIViewController {

	// MARK: - Properties
	
	// MARK: - Outlets
	
	@IBOutlet var datePickerOutlet: UIDatePicker!
	
	
	// MARK: - Funcs
	
	/// viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

		datePickerOutlet.setValue(UIColor.white, forKey: "textColor")
		
    }

	
	// MARK: - Actions
	
	/// set the date and go back
	@IBAction func setDateButton(_ sender: UIBarButtonItem) {
		
		/// TODO date input validation
		
		let date = datePickerOutlet.date

		/// set date variable in previous view
		let previousView = navigationController?.viewControllers[1] as! TradeEditorViewViewController
		previousView.date = date
		
		/// pop back to previous view
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	
	/// cancel button
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		print("button pressed")
		_ = self.navigationController?.popViewController(animated: true)
	}
}
