//
//  DateEditorView.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class DateEditorView: UIViewController {

	// ****************
	// MARK: - Outlets
	// ****************
	@IBOutlet var datePickerOutlet: UIDatePicker!
	
	// ***********************
	// MARK: - View Life Cycle
	// ***********************
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// format the date picker
		datePickerOutlet.setValue(UIColor.white, forKey: "textColor")
    }

	// ***************
	// MARK: - Actions
	// ***************
	
	// set the date and go back
	@IBAction func setDateButton(_ sender: UIBarButtonItem) {
		
		var selectedDate = datePickerOutlet.date
		let todaysDate = Date()
		
		// if user selects a date in the future, do nothing
		if selectedDate > todaysDate {
			selectedDate = todaysDate
			return
		}
		
		// if valid date, set date and pop back
		else {
			// set date variable in previous view
			let previousView = navigationController?.viewControllers[1] as! TradeEditorViewViewController
			previousView.date = selectedDate
			
			// pop back to previous view
			_ = self.navigationController?.popViewController(animated: true)
		}
	}
	
	// cancel button, pop view back
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		print("Cancel: Popping back to --> TradesEditor")
		_ = self.navigationController?.popViewController(animated: true)
	}
}
