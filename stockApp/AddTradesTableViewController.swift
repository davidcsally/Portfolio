//
//  AddTradesTableViewController.swift
//  stockApp
//
//  Created by David Sally on 4/23/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class AddTradesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

	// MARK: - Properties
	
	var ticker: String = ""
	var purchasePrice: Double = 0
	var numShares: Double = 0

	// MARK: - Outlets
	@IBOutlet var createTable: UITableView!
	
	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	// MARK:  - Funcs
	
	/// input validation to ignore multiple decimal points
	func checkForDecimalSeparator(textField:UITextField) -> Bool {
		
		let decimalSeparator = Locale.current.decimalSeparator
		
		if let currentText = textField.text {
			for i in currentText.characters.indices[currentText.startIndex..<currentText.endIndex] {
				if String(currentText[i]) == decimalSeparator {
					return true
				}
			}
		}
		
		/// return false if no decimal separator was found
		return false
	}

	// MARK: - Actions
	
	/// to buy a stock
	@IBAction func createButton(_ sender: UIButton) {
		
		/// TODO
//		var numShares: Double
//		var purchasePrice: Double
//		let date: Date? = nil
//		
//		if numSharesOutlet.text != "" {
//			numShares = Double(numSharesOutlet.text!)!
//		} else {
//			return
//		}
//		
//		if purchasePriceOutlet.text != "" {
//			purchasePrice = Double(purchasePriceOutlet.text!)!
//		} else {
//			return
//		}
		
		
//		let newStock = StockBuy(ticker: ticker, numShares: numShares, purchasePrice: purchasePrice, purchaseDate: date)
		
	}
	
	@IBAction func backButton(_ sender: UIBarButtonItem) {
		_ = navigationController?.popViewController(animated: true)
	}
	
    // MARK: - Table view data source

	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	
		let row = indexPath.row

		print("Row: \(row)")
		
		switch row {
			case 0:
				tableView.cellForRow(at: indexPath)?.isSelected = false
				performSegue(withIdentifier: "filterTrades", sender: nil)
		
			
			case 4:
				tableView.cellForRow(at: indexPath)?.isSelected = false
				performSegue(withIdentifier: "toDatePicker", sender: nil)
				
			default:
				print("hello, default")
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		switch row {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "tickerCell", for: indexPath)
				return cell
				
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "numSharesCell", for: indexPath)
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: "purchasePriceCell", for: indexPath)
				
				return cell

			case 3:
				let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
				return cell

			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: "createCell", for: indexPath)
				return cell
			
		}
	}

	// MARK: - Text Field Delegates
	
	
	/// input validation
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		/// TODO
		
		let allowedCharacters = NSCharacterSet.decimalDigits
		let decimalSeparator = Locale.current.decimalSeparator
		let isDecimalPresent = checkForDecimalSeparator(textField: textField)
		
		/// only update the text field if it is a number, OR the only decimal selector
		for char in string.unicodeScalars {
			if (allowedCharacters.contains(char) || (string == decimalSeparator && isDecimalPresent == false)) {
				updateTextFieldValues()
				print("numShares: \(numShares)")
				print("purchasePrice: \(purchasePrice)")
				
				return true
			}
			
			else {
				return false
			}
		}
		
		print("Error, weird character detected")
		return true
	}

	func updateTextFieldValues() {
		print(#function)
		let indexPath = self.createTable.indexPathForSelectedRow!
		let row = indexPath.row
		
		let selectedCell = self.createTable.cellForRow(at: indexPath) as! TextFieldTableCell
		
		switch row {
		case 1:
			numShares = Double(selectedCell.textField.text!)!
		case 2:
			purchasePrice = Double(selectedCell.textField.text!)!
		default:
			print("ERROR")
		}
	}

}
