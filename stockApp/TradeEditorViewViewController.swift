//
//  TradeEditorViewViewController.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class TradeEditorViewViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

	/// ****************
	/// ** Properties **
	/// ****************
	// MARK: - Properties
	
	/// stockData will hold information for trades for a specific stock that user is adding more to
//	var stockStore = StockStore.sharedInstance
	var stockHolder: Stock?
	var stockArray = StockStore.sharedInstance.arrayOfStocks
	
	/// get this from data table view
	var name: String? = nil
	var ticker: String? = nil
	var date: Date? = nil
	var currentPrice: Double? = nil
	
	/// formatters
	let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
	
	
	/// **************
	/// *** Oulets ***
	/// **************
	// MARK: - Outlets
	
	@IBOutlet var tickerTextField: UITextField!
	@IBOutlet var sharesTextField: UITextField!
	@IBOutlet var purchasePriceTextField: UITextField!
	@IBOutlet var purchaseDateTextField: UITextField!
	@IBOutlet var createButtonOutlet: UIButton!
	
	@IBOutlet var stockTable: UITableView!
	
	/// ******************
	/// ****** VIEW ******
	/// ******************
	// MARK: - View Life Cycle
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		print("\(#function) - num stocks in model: \(stockArray.count)")
		
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		
		/// if name and ticker have values, set the textfield to the ticker
		if ticker != nil && name != nil {
			tickerTextField.text = ticker
			
			/// search array of stocks to see if this one exists in the array
			for stock in stockArray {
				print("\(ticker) ?? \(stock.ticker)")
				if stock.ticker == ticker {
					stockHolder = stock
					print("reload the table NOW")
					stockTable.reloadData()
				}
			}
			
		}
		
		if date != nil {
			purchaseDateTextField.text = dateFormatter.string(from: date!)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		view.endEditing(true)
	}
	
	
	/// viewDidLoad()
	override func viewDidLoad() {
		super.viewDidLoad()
		print(#function)

		/// format create button
		let cornerRadius : CGFloat = 7.0
		createButtonOutlet.layer.cornerRadius = cornerRadius
		createButtonOutlet.layer.borderColor = UIColor.green.cgColor
		createButtonOutlet.layer.borderWidth = 2
	}

	
	/// **************
	/// ** ACTIONS ***
	/// **************
	// MARK: - Actions

	
	@IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
		print("tap detected")
		self.view.endEditing(true)
	}
	
	/// Add a new stock to the portfolio
	/// Check if 4 required fields are filled in
	/// If true, add stock and pop view back, else, button does nothing
	@IBAction func createButton(_ sender: UIButton) {

		/// ensure required fields are filled in
		if sharesTextField.text?.isEmpty == false &&
		   purchasePriceTextField.text?.isEmpty == false &&
		   tickerTextField.text?.isEmpty == false {
			let price = Double(purchasePriceTextField.text!)!
			let shares = Double(sharesTextField.text!)!
			
			/// variable to hold previous view
			let previousView = navigationController?.viewControllers[0] as! ViewController
			
			/// add new stock to the PREVIOUS view's stock store
//			previousView.stockStore.addNewStock(name: name!, ticker: ticker!, numShares: shares, purchasePrice: price, purchaseDate: date, currentValue: currentPrice!)

			print("***ticker: \(ticker)")
			previousView.stockStore.addNewStock(name: name!, ticker: ticker!, numShares: shares, purchasePrice: price, purchaseDate: date)

			
			/// pop back to previous view
			_ = navigationController?.popViewController(animated: true)

			
		}
		else {
			print("Not all fields filled in!")
		}
	}
	
	/// Cancel button, pops view back
	@IBAction func cancelButton(_ sender: Any) {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	/// **************
	/// * DELEGATES **
	/// **************
	// MARK: - Text Field Delegates
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch textField {
			
			case tickerTextField:
				/// prevent keyboard from popping up
				textField.inputView = UIView()
				
				/// segue to stocks table, end editing so it doesnt automatically go back to table when view is popped from view
				print("go to Stocks Table")
				view.endEditing(true)
				performSegue(withIdentifier: "goToTrades", sender: nil)
			
			case purchaseDateTextField:
				
				/// prevent keyboard from popping up
				textField.inputView = UIView()
				
				/// segue to Date Picker
				performSegue(withIdentifier: "dateSegue", sender: nil)
			
			default:
				print("don't need to do anything")
		}
	}
	
	/// input validation
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

		/// TODO
		
		switch textField {
			
			/// NUMBER OF SHARES TEXT FIELD
			case sharesTextField:
				/// define the allowed characters
				let allowedCharacters = NSCharacterSet.decimalDigits
				let decimalSeparator = Locale.current.decimalSeparator
				let isDecimalPresent = checkForDecimalSeparator(textField: textField)
				
				/// only update the text field if it is a number, OR the only decimal selector
				for char in string.unicodeScalars {
					if (allowedCharacters.contains(char) || (string == decimalSeparator && isDecimalPresent == false)){
						return true
					} else {
						return false
					}
			}
			
			/// NUMBER OF SHARES TEXT FIELD
			case purchasePriceTextField:
				/// define the allowed characters
				let allowedCharacters = NSCharacterSet.decimalDigits
				let decimalSeparator = Locale.current.decimalSeparator
				let isDecimalPresent = checkForDecimalSeparator(textField: textField)
				
				/// only update the text field if it is a number, OR the only decimal selector
				for char in string.unicodeScalars {
					if (allowedCharacters.contains(char) || (string == decimalSeparator && isDecimalPresent == false)){
						return true
					} else {
						return false
					}
				}
			
			/// PURCHASE DATE
			case purchaseDateTextField:
				print("Segue to Date Picker")
				return false
				
			default:
				print("Error!")
		}
		
		
		return true
	}
	
	// MARK: - UITableView Delegates
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print(#function)
		if stockHolder != nil {
			print(stockHolder?.buys.count)
			return (stockHolder?.buys.count)!
		} else {
			print("no buys detected")
			return 0
		}
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell")
		
		if let buy = stockHolder?.buys[row] {
			cell?.textLabel?.text = "\(buy.numShares) SHARES @ \(buy.purchasePrice)"
		}
		
		return cell!
	}
	
	/// **************
	/// *** Funcs ****
	/// **************
	// MARK: - Funcs
	
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
}
