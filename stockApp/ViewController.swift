//
//  ViewController.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//
//	**********
//	** TODO **
//	**********
//  - general UI improvements
//
//	- PORTFOLIO TABLE [ROOT VIEW]
//      x subtables in portfolio view
//		- "edit trades" after last stock buy
//		- returnButton switches between diffent metrics [return%, return$, dayChange$, dayChange%, holdings%, mktValue]
//		- fix autolayout issues on table cells
//		- move constraint anchor higher when view switches
//
//	- MODEL
//		x get data from web API
//		- get DAILY information from alphavantage API
//		- use daily information to calculate 1 day changes
//		- in Buys(?) class, add a way to track 1 day changes
//      - impliment saving / loading from documents library [or core data?]
//      x add stocks to model
//		- delete stocks from model
//      x better item management in model
//		- parse NYSE stock list
//		x parse stock lists asynchronously when app launches
//
//
//	- TRADE EDITOR VIEW
//      x search bar view to search for stock tickers
//		x search bars is editing when view is loaded
//		- show table of trade history for selected ticker
//
//	- DATE PICKER VIEW
//		x return selected date to TradeView
//		- input validation on date - don't return date that's in the future

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	/// ****************
	/// ** Properties **
	/// ****************
	// MARK: - Properties
		
//	var stockStore: StockStore!
	var stockStore = StockStore.sharedInstance
	var todaysDate: Date = Date()
	
	/// number of rows to display in expandable table
	var visibleRows = 0
	
	func updateVisibleRows() {
		visibleRows = 0
		
		/// add the buys from selected stocks, buys are only displayed when stock is selected
		for stock in stockStore.arrayOfStocks {
			if stock.isSelected {
				visibleRows += stock.buys.count
			}
		}
		
		/// add the number of stocks, these are always displayed
		visibleRows += stockStore.arrayOfStocks.count
		print("visible rows: \(visibleRows + 1)")
	}
	
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
	
	let percentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.maximumFractionDigits = 2
		return formatter
	}()

	/// *****************
	/// **** Outlets ****
	/// *****************
	// MARK: - Outlets
	
	/// LABELS
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var valueLabel: UILabel!
	@IBOutlet var dayChangeLabel: UILabel!
	@IBOutlet var returnLabel: UILabel!

	/// TABLES
	@IBOutlet var todayTable: UITableView!
	
	/// CONTROLS
	@IBOutlet var segControlOutlet: UISegmentedControl!

	/// ***************
	/// **** View ****
	/// ***************
	// MARK: - View
	
	
	// viewDidLoad()
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		stockStore.addNewStock(name: "Google", ticker: "GOOG", numShares: 30, purchasePrice: 30, purchaseDate: nil)
		/// when app starts up, update all the stock prices in the array
		stockStore.fetchAlphaVantage { (stockResult) -> Void in
			
			switch stockResult {
				case let .success(stocks):
					print("successfully made stocks!")
				
					var ticker = ""
					var price:Double = 0
					
					/// get ticker and price
					for i in 0..<stocks.count {
						ticker = stocks[i].ticker
						price = stocks[i].currentPrice
						print("ticker: \(ticker)")
					}
				
					for i in 0..<self.stockStore.arrayOfStocks.count {
						/// check names
						if self.stockStore.arrayOfStocks[i].ticker == ticker {
							print("setting price")
							self.stockStore.arrayOfStocks[i].setCurrentPrice(price: price)
						}
				}
				
				self.todayTable.reloadData()
				
				case let .failure(error):
					print("error making stocks: \(error)")
			}
		}
		
		/// format all the stuff
		
		/// todayTable Outlet
		todayTable.tableFooterView = UIView(frame: .zero)
		todayTable.tableFooterView?.isHidden = true
		todayTable.alpha = 1.0
		
		dayChangeLabel.alpha = 0
		returnLabel.alpha = 0
		
		/// hide day change label
		dayChangeLabel.alpha = 0
		
		/// Format Segmented Controller
		self.segControlOutlet.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
		self.segControlOutlet.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
		
		/// Set Labels
		dateLabel.text = dateFormatter.string(from: todaysDate)
		valueLabel.text = String("\(stockStore.portfolioReturnAsPercent)%")
		
		/// make table lies extend edge to edge
		todayTable.layoutMargins = UIEdgeInsets.zero
		todayTable.separatorInset = UIEdgeInsets.zero
		
	}
	
	
	// view will appear()
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		print(#function)
		
		var numBuys = 0
		for stock in stockStore.arrayOfStocks {
			numBuys += stock.buys.count
		}
		
		/// reload table
		updateVisibleRows()
		todayTable.reloadData()
		
		/// update values
		stockStore.calcPortfolioValue()
	}
	
	// view will dispear
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		/// unexpand all rows
		for stock in stockStore.arrayOfStocks {
			stock.isSelected = false
		}
	}
	/// *****************
	/// **** Actions ****
	/// *****************
	// MARK: - Actions

	///***************************
	// Seg Controller - ViewSelector
	@IBAction func segmentedController(_ sender: UISegmentedControl) {
		
		/// switch views if segment is changed
		switch sender.selectedSegmentIndex {
			
			/// "Today" View
			case 0:
				dateLabel.text = dateFormatter.string(from: todaysDate)
				valueLabel.text = String("\(stockStore.portfolioReturnAsPercent)%")
				dayChangeLabel.alpha = 0
				todayTable.reloadData()

			/// "Portfolio" View
			case 1:
				dateLabel.text = "YOUR PORTFOLIO"
				valueLabel.text = currencyFormatter.string(from: NSNumber(value: stockStore.portfolioValue))
				dayChangeLabel.text = String("\(stockStore.portfolioReturnAsDouble)   (+\(stockStore.portfolioReturnAsPercent)%)")
				todayTable.reloadData()

			default:
				print("Error: segmentedController: \(#function)")
		}
	}
	///***************************

	/// SETTINGS Go to settings Page
	@IBAction func settingsButton(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "settingsSegue", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			
//		case "goToTrades"?:
//			print("go to add trades screen")
//			let newView = segue.destination as! TradeEditorViewViewController
//			newView.stockStore = stockStore
//			newView.arrayOfStocks = stockStore.arrayOfStocks
			
		case "tradesSegue"?:
			print("trades segue")
			
			let newView = segue.destination as! TradesViewer
			let tableRow = self.todayTable.indexPathForSelectedRow?.row
			newView.stock = stockStore.arrayOfStocks[tableRow!]
						
		default:
			print("other segue")
		}
	}
	
	// MARK: - Delegates
	
	/// did select row
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let row = indexPath.row
		
		var cellArray: [String] = []
		
		for stock in stockStore.arrayOfStocks {
			cellArray.append("Stock")
			if stock.isSelected {
				for _ in stock.buys {
					cellArray.append("Buy")
				}
			}
		}
		
		// get current stock
		var stockCounter = 0
		for i in 0..<cellArray.count {
			if i < row {
				if cellArray[i] == "Stock" {
					stockCounter += 1
				}
			}
		}
		
		
		if tableView == todayTable {
			switch segControlOutlet.selectedSegmentIndex {
			case 0:
				print("case 0 tapped")
			default:
				let cell = tableView.cellForRow(at: indexPath)
				
				switch (cell?.reuseIdentifier)! {
				case "addTradesCell":
					performSegue(withIdentifier: "addTradesSegue", sender: nil)

				case "portfolioCell":
					/// when cell is tapped, if it's not expanded, expand it
					if stockStore.arrayOfStocks[stockCounter].isSelected == true {
						stockStore.arrayOfStocks[stockCounter].isSelected = false
						print("isSelected?: \(stockStore.arrayOfStocks[stockCounter].isSelected)")
						updateVisibleRows()
						todayTable.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)

					}
					/// when an expanded cell is tapped, un-expand it
					else {
						stockStore.arrayOfStocks[stockCounter].isSelected = true
						print("isSelected?: \(stockStore.arrayOfStocks[stockCounter].isSelected)")
						updateVisibleRows()
						todayTable.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
					}
					
				default:
					print("default switch statement")
				}
				
			}
		}
	}
	
	/// numberOfRowsInSection
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch segControlOutlet.selectedSegmentIndex {
			/// "today" table
			case 0:
				return stockStore.arrayOfStocks.count
			
			/// "portfolio" table
			default:
				return visibleRows + 1
		}
	}
	
	///***************************
	/// cell for row at
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		
		switch segControlOutlet.selectedSegmentIndex {
			
			/// today view
			case 0:
				/// have to cast the cell as the custom cell type
				let stock = stockStore.arrayOfStocks[row]
				let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! TodayTableCell
				
				/// get values for cell
				let ticker = stock.ticker
				let price = stock.currentPrice
				let stockReturn = String(describing: percentFormatter.string(from: NSNumber(value: stock.returnAsPercent))!)
				
				/// format the table cell
				cell.tickerLabel.text = ticker
				cell.priceLabel.text = currencyFormatter.string(from: NSNumber(value: price!))
				cell.returnOutlet.setTitle(stockReturn, for: .normal)
				cell.layoutMargins = UIEdgeInsets.zero
				
				return cell

			/// portfolio view
			default:
				let numStocks = stockStore.arrayOfStocks.count
				var expandedStocks = 0
				
				for stock in stockStore.arrayOfStocks {
					if stock.isSelected == true {
						expandedStocks += stock.buys.count
					}
				}
				
				if row < numStocks + expandedStocks {
					var cellArray: [String] = []
					
					for stock in stockStore.arrayOfStocks {
						cellArray.append("Stock")
						if stock.isSelected {
							for _ in stock.buys {
								cellArray.append("Buy")
							}
						}
					}
					
					/// for "stocks"
					if cellArray[row] == "Stock" {
						let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as! PortfolioTableCell
						
						// get current stock
						var stockCounter = 0
						for i in 0..<cellArray.count {
							if i < row {
								if cellArray[i] == "Stock" {
									stockCounter += 1
								}
							}
						}

						let stock = stockStore.arrayOfStocks[stockCounter]
						
						let ticker = stock.ticker
						let price = stock.currentPrice
						let numShares = stock.totalShares
						let stockReturn = String(describing: percentFormatter.string(from: NSNumber(value: stock.returnAsPercent))!)
						
						/// format the table cell
						
						cell.tickerLabel.text = ticker
						cell.priceLabel.text = currencyFormatter.string(from: NSNumber(value: price!))
						cell.numSharesLabel.text = "\(numShares) SHARES"
						cell.returnValueOutlet.setTitle(stockReturn, for: .normal)
						cell.layoutMargins = UIEdgeInsets.zero
						
						return cell

					}
					/// for "buys" in a stock
					else if cellArray[row] == "Buy" {
						let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath)
						
						/// get current stock
						var stockCounter = 0
						var buyCounter = 0

						/// loop through array to get the index
						for i in 0..<cellArray.count {
							if i < row {
								if cellArray[i] == "Stock" {
									stockCounter += 1
								}
							}
						}
						
						/// subtract 1 to account for zero indexing
						let thisStock = stockStore.arrayOfStocks[stockCounter - 1]

						
						/// find the index of the buy:
						for i in stockStore.arrayOfStocks {
							/// if the stock isn't the current one, and it is selcted, add all the buys + 1 to get total number of rows used by this stock
							if i.ticker != thisStock.ticker && i.isSelected == true {
								buyCounter += i.buys.count + 1
							}
							
							/// if this isnt the current stock, buy isnt selected, add one to the index to account for the 1 space taken up on the table
							else if i.ticker != thisStock.ticker && i.isSelected == false {
								buyCounter += 1
							}
							
							/// if this is the current stock, add one to account for space on table and break loop
							else if i.ticker == thisStock.ticker {
								buyCounter += 1
								break
							}
						}
						
//						print("stock: \(thisStock.ticker)")
//						print("row: \(row), stockCounter: \(stockCounter), buyCounter: \(buyCounter)")
//						print("trying to index: \(row - buyCounter)")
						let buy = thisStock.buys[row - buyCounter]
						
						cell.textLabel?.text = "\(buy.numShares) SHARES @ \(buy.purchasePrice)"
						
						return cell
					}
					
				}
				
				let cell = tableView.dequeueReusableCell(withIdentifier: "addTradesCell", for: indexPath)
				return cell
		}
	}
	///***************************

}

