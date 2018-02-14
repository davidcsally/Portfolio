//
//  TradeEditorViewViewController.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class TradeEditorViewViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

	// ******************
	// MARK: - Properties
	// ******************
	
	// stockData will hold information for trades for a specific stock that user is working with
	var stockHolder: Stock? {
		didSet {
			ticker = stockHolder?.ticker
			name = stockHolder?.name
		}
	}
	
	var stockArray: [Stock]!
	var validStocks: [StockList]!
	
	// these values are passed to this view from other views
	var name: String?
	var ticker: String?
	var date: Date?
	
	// MARK: - Formatters
	
	let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
	
	let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.maximumFractionDigits = 2
		return formatter
	}()

	// ***************
	// MARK: - Outlets
	// ***************
	
	@IBOutlet var tickerTextField: UITextField!
	@IBOutlet var sharesTextField: UITextField!
	@IBOutlet var purchasePriceTextField: UITextField!
	@IBOutlet var purchaseDateTextField: UITextField!
	@IBOutlet var createButtonOutlet: UIButton!
	@IBOutlet var stockTable: UITableView!
	
	// ***********************
	// MARK: - View Life Cycle
	// ***********************
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// formatting
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		
		// format create button
		let cornerRadius : CGFloat = 7.0
		createButtonOutlet.layer.cornerRadius = cornerRadius
		createButtonOutlet.layer.borderColor = UIColor.green.cgColor
		createButtonOutlet.layer.borderWidth = 2
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// if name and ticker have values, set the textfield to the ticker
		if ticker != nil && name != nil {
			tickerTextField.text = ticker
			
			// search array of stocks to see if this one exists in the array
			if let i = stockArray.index(where: { $0.ticker == ticker}) {
				stockHolder = stockArray[i]
				stockTable.reloadData()
			}
		}
		
		// set date
		if date != nil {
			purchaseDateTextField.text = dateFormatter.string(from: date!)
		}
		
		// reload the table to keep the table in sync when this view recieves data from child views
		stockTable.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// MUST do this so that text field is not focused when popping back from child views
		view.endEditing(true) // <--- don't think this is necessary
		
		let previousView = navigationController?.viewControllers[0] as! ViewController
		
		// remove the stock if the user deleted all the buys
		if stockHolder?.buys.count == 0 {
			previousView.stockStore.deleteStock(ticker: (stockHolder?.ticker)!)
		}
	}
	
	
	// ***************
	// MARK: - Actions
	// ***************

	// background tap to hide keyboard
	@IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	// Add a new stock to the portfolio
	// Check if 4 required fields are filled in
	// If true, add stock and pop view back, else, button does nothing
	@IBAction func createButton(_ sender: UIButton) {

		// ensure required fields are filled in
		if sharesTextField.text?.isEmpty == false &&
		   purchasePriceTextField.text?.isEmpty == false &&
		   tickerTextField.text?.isEmpty == false {
			
			let price = Double(purchasePriceTextField.text!)!
			let shares = Double(sharesTextField.text!)!
			
			// variable to hold previous view
			let previousView = navigationController?.viewControllers[0] as! ViewController
			
			// add new stock to the PREVIOUS view's stock store
			previousView.stockStore.addNewStock(name: name!, ticker: ticker!, numShares: shares, purchasePrice: price, purchaseDate: date)
			
			// pop back to previous view
			_ = navigationController?.popViewController(animated: true)
		}
	}
	
	// Cancel button
	@IBAction func cancelButton(_ sender: Any) {
		// pop view back
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// push the validStocks array to the view to choose stock ticker
		if segue.identifier == "goToTrades" {
			let newView = segue.destination as! FilterTradesViewController
			newView.validStocks = validStocks
		}
	}
	
	// *****************************
	// MARK: - Text Field Delegates
	// *****************************
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch textField {
			
			// when the ticker field is selected
			case tickerTextField:
				// prevent keyboard from popping up
				textField.inputView = UIView()
				
				// segue to stocks table, end editing so it doesnt automatically go back to table when view is popped from view
				print("Going to --> Stock Picker")
				//view.endEditing(true)
				performSegue(withIdentifier: "goToTrades", sender: nil)
			
			// when the data field is selected
			case purchaseDateTextField:
				
				/// prevent keyboard from popping up
				textField.inputView = UIView()
				
				// segue to Date Picker
				print("Going to --> Date Picker")
				performSegue(withIdentifier: "dateSegue", sender: nil)
			
			// default -> don't do anything
			default:
				return
		}
	}
	
	// input validation
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		switch textField {
			
			// NUMBER OF SHARES TEXT FIELD
			case sharesTextField:
				// define the allowed characters
				let allowedCharacters = NSCharacterSet.decimalDigits
				let decimalSeparator = Locale.current.decimalSeparator
				let isDecimalPresent = checkForDecimalSeparator(textField: textField)
				
				// only update the text field if it is a number, OR the only decimal selector
				for char in string.unicodeScalars {
					if (allowedCharacters.contains(char) || (string == decimalSeparator && isDecimalPresent == false)){
						return true
					} else {
						return false
					}
				}
			
			// NUMBER OF SHARES TEXT FIELD
			case purchasePriceTextField:
				// define the allowed characters
				let allowedCharacters = NSCharacterSet.decimalDigits
				let decimalSeparator = Locale.current.decimalSeparator
				let isDecimalPresent = checkForDecimalSeparator(textField: textField)
				
				// only update the text field if it is a number, OR the only decimal selector
				for char in string.unicodeScalars {
					if (allowedCharacters.contains(char) || (string == decimalSeparator && isDecimalPresent == false)){
						return true
					} else {
						return false
					}
				}
			
			// PURCHASE DATE
			case purchaseDateTextField:
				print("Going to --> Date Picker")
				return false
			
			// default - Error if code reaches this point
			default:
				print("\(#function) Error!")
		}
		
		return true
	}
	
	// *****************************
	// MARK: - UITableView Delegates
	// *****************************

	// this is to set up a table header
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if stockHolder != nil {
			if (stockHolder?.buys.count)! > 0 {
				return 44
			}
		}
		return 0
	}
	
	// this is to set up the table header
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if stockHolder != nil {
			if (stockHolder?.buys.count)! > 0 {
				
				// define the header
				let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
				let view = UIView(frame: rect)
				let label = UILabel()
				
				// format the label
				label.font = label.font.withSize(12)
				label.textColor = UIColor.white
				label.text = "TRADES (SWIPE TO SELL/DELETE)"

				// add label to view
				view.addSubview(label)
				
				// format the header
				label.translatesAutoresizingMaskIntoConstraints = false
				label.heightAnchor.constraint(equalTo: label.superview!.heightAnchor).isActive = true
				label.widthAnchor.constraint(equalTo: label.superview!.widthAnchor).isActive = true
				label.centerYAnchor.constraint(equalTo: label.superview!.centerYAnchor).isActive = true

				return view
			}
		}
		
		return nil
	}
	
	// set number of sections to 1
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// set the number rows
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if stockHolder != nil {
			return (stockHolder?.buys.count)!
		} else {
			return 0
		}
		
	}
	
	// set each cell in the table equal to the buys in the "buys" array
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell")
		
		// check if buy exists (safely unwrap)
		if let buy = stockHolder?.buys[row] {
			
			// set the num shares and purchase price
			cell?.textLabel?.text = "\(buy.numShares!) SHARES @ \(String(describing: currencyFormatter.string(from: NSNumber(value: buy.purchasePrice))!))"
			
			// if a date is present, set the date, otherwise make blank
			if buy.purchaseDate != nil {
				cell?.detailTextLabel?.text = dateFormatter.string(from: buy.purchaseDate!)
			} else {
				cell?.detailTextLabel?.text = ""
			}
		}
		
		return cell!
	}
	
	// allow swipe-to-delete in the table
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if stockHolder != nil {				
				stockHolder?.buys.remove(at: indexPath.row)
				stockTable.deleteRows(at: [indexPath], with: .automatic)
			}
		}
	}
	
	// *************
	// MARK: - Funcs
	// *************
	
	// input validation to ignore multiple decimal points
	func checkForDecimalSeparator(textField:UITextField) -> Bool {
		
		let decimalSeparator = Locale.current.decimalSeparator
		
		if let currentText = textField.text {
			for i in currentText.characters.indices[currentText.startIndex..<currentText.endIndex] {
				if String(currentText[i]) == decimalSeparator {
					return true
				}
			}
		}
		
		// return false if no decimal separator was found
		return false
	}	
}
