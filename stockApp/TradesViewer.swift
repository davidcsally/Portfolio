//
//  TradesViewerViewController.swift
//  stockApp
//
//  Created by David Sally on 4/14/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class TradesViewer: UIViewController, UITableViewDelegate, UITableViewDataSource  {

	// ******************
	// MARK: - Properties
	// ******************
	
	var stock: Stock!
	var areAnyPropertiesNil:Bool = true;
	
	// MARK: Formatters
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
	
	let percentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.maximumFractionDigits = 2
		return formatter
	}()


	// ***************
	// Mark: - Outlets
	// ***************
	
	// Top Header
	@IBOutlet var tickerLabel: UILabel!
	@IBOutlet var curValueLabel: UILabel!
	@IBOutlet var changeLabel: UILabel!
	
	// In Use
	@IBOutlet var openLabel: UILabel!
	@IBOutlet var prevCloseLabel: UILabel!
	@IBOutlet var volumeLabel: UILabel!
	@IBOutlet var highLabel: UILabel!
	@IBOutlet var lowLabel: UILabel!
	@IBOutlet var mktCapLabel: UILabel!

	// Not In Use (yet...)
	@IBOutlet var PELabel: UILabel!
	@IBOutlet var dividendLabel: UILabel!
	
	// Toolbar
	@IBOutlet var toolbarTickerLabel: UILabel!

	// ***************
	// MARK: - Actions
	// ***************
	
	@IBAction func backButton(_ sender: UIBarButtonItem) {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	
	// ************
	// MARK: - View
	// ************
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		print(#function)
		
		// update labels
		tickerLabel.text = stock.name
		toolbarTickerLabel.text = stock.ticker
		
		// update labels, unwrap safely
		
		if stock.high == nil {
			highLabel.text = "???"
		} else {
			highLabel.text = currencyFormatter.string(from: NSNumber(value: stock.high!))
		}
		
		if (stock.low == nil) {
			lowLabel.text = "???"
		} else {
			lowLabel.text = currencyFormatter.string(from: NSNumber(value: stock.low!))
		}
		
		if stock.volume == nil {
			volumeLabel.text = "???"
		} else {
			volumeLabel.text = stock.volume!
		}
		
		if stock.currentPrice == nil {
			curValueLabel.text = "???"
		} else {
			curValueLabel.text = String(describing: stock.currentPrice!)
		}
		
		if stock.changeSinceYesterdayPercent == nil {
			changeLabel.text = "???"
		} else {
			changeLabel.text = "\(String(describing: currencyFormatter.string(from: NSNumber(value: stock.changeSinceYesterday!))!)) (\(String(describing: percentFormatter.string(from: NSNumber(value: stock.changeSinceYesterdayPercent!))!)))"
		}
		
		if stock.prevClose != nil {
			prevCloseLabel.text = currencyFormatter.string(from: NSNumber(value: stock.prevClose!))
			openLabel.text = currencyFormatter.string(from: NSNumber(value: stock.open!))
		} else {
			print("\(#function): ERROR - \(stock.ticker)'s prev close == nil")
			prevCloseLabel.text = "???"
			openLabel.text = "???"
		}
		
		// set colors
		if stock.changeSinceYesterday! >= 0.0 {
			changeLabel.textColor = UIColor.green
		} else {
			changeLabel.textColor = UIColor.red
		}
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		let previousView = navigationController?.viewControllers[0] as! ViewController
		
		// remove the stock if the user deleted all the buys
		if stock.buys.count == 0 {
			previousView.stockStore.deleteStock(ticker: (stock.ticker))
		}

	}
	
	// ****************************
	// MARK: - Table View Delegates
	// ****************************

	// Num Rows
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stock.buys.count
	}
	
	// Num Sections
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// Cell for row at
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath)
		let buy = stock.buys[row]
		let purchasePrice = currencyFormatter.string(from: NSNumber(value: buy.purchasePrice))!
		
		// format cell
		cell.textLabel?.text = "\(buy.numShares!) SHARES @ \(purchasePrice)"
		
		// display purchase date (if present)
		if let purchaseDate = buy.purchaseDate {
			cell.detailTextLabel?.text = dateFormatter.string(from: purchaseDate)
		} else {
			cell.detailTextLabel?.text = ""
		}
		
		return cell
	}
	
	// allow swipe-to-delete in the table
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
				stock.buys.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
	
	// this is to set up a table header
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44
	}

	// this is to set up the table header
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if stock.buys.count > 0 {
			
			// define the header
			let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
			let view = UIView(frame: rect)
			let label = UILabel()
			
			// setup the label
			label.font = label.font.withSize(12)
			label.textColor = UIColor.white
			
			// add header to view
			view.addSubview(label)
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
			
			// format the header
			label.translatesAutoresizingMaskIntoConstraints = false
			label.heightAnchor.constraint(equalTo: label.superview!.heightAnchor).isActive = true
			label.widthAnchor.constraint(equalTo: label.superview!.widthAnchor).isActive = true
			label.centerYAnchor.constraint(equalTo: label.superview!.centerYAnchor).isActive = true

			// present the header
			label.text = "TRADES (SWIPE TO SELL/DELETE)"
			return view
		} else {
			return nil
		}
	}
	
}
