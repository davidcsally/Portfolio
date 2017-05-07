//
//  TradesViewerViewController.swift
//  stockApp
//
//  Created by David Sally on 4/14/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class TradesViewer: UIViewController, UITableViewDelegate, UITableViewDataSource  {

	// MARK: - Properties
	var stock: Stock!
	
	/// formatters
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

	
	// Mark: - Outlets
	@IBOutlet var tickerLabel: UILabel!
	@IBOutlet var curValueLabel: UILabel!
	@IBOutlet var changeLabel: UILabel!
	
	@IBOutlet var prevCloseLabel: UILabel!
	@IBOutlet var volumeLabel: UILabel!
	@IBOutlet var mktCapLabel: UILabel!
	@IBOutlet var PELabel: UILabel!
	
	@IBOutlet var openLabel: UILabel!
	@IBOutlet var avgVolLabel: UILabel!
	@IBOutlet var nextEarningsLabel: UILabel!
	@IBOutlet var dividendLabel: UILabel!
	
	@IBOutlet var toolbarTickerLabel: UILabel!
	
	// MARK: - Actions
	@IBAction func backButton(_ sender: UIBarButtonItem) {
		_ = self.navigationController?.popViewController(animated: true)
	}
	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
		
		/// update labels
		tickerLabel.text = stock.ticker
		curValueLabel.text = String(describing: stock.currentPrice!)
		
    }
	
	// MARK: - Table View Delegates

	// numberOfRowsInSection
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		print("num rows: \(stock.buys.count)")
		return stock.buys.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// cellForRowAt
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let row = indexPath.row
		let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath)
		let buy = stock.buys[row]
		let purchasePrice = currencyFormatter.string(from: NSNumber(value: buy.purchasePrice))!
		/// xxx.xx SHARES @ $xxx.xx
		cell.textLabel?.text = "\(buy.numShares) SHARES @ \(purchasePrice)"
		
		/// set purchase date
		if let purchaseDate = buy.purchaseDate {
			cell.detailTextLabel?.text = dateFormatter.string(from: purchaseDate)
		} else {
			cell.detailTextLabel?.text = ""
		}
		
		return cell
	}
	
}
