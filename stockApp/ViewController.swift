//
//  ViewController.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//
// ****************
// ** Change Log **
// ****************
//	6/8/17	- switch to new GLOBAL_QUOTE api call
//			- in tradesviewer, now shows stock high, low, and volume 
//
//	6/17/17 - minor code cleanup on flight back from chicago
//
//
//
//	**********
//	** TODO **
//	**********
//  - general UI improvements
//	x BUGS when showing different labels - ensure they are initialized correctly at first showing
//	x delegate? to update prices when they are retrieved
//	- figure out how to get missing information
//	- add a watch list
//	- show instructions if array is empty
//  x BUG: when all stocks are deleted in the TradesView, and view is popped back to Main, label will say NaN
//
//	- PORTFOLIO TABLE [ROOT VIEW]
//      x subtables in portfolio view
//		x "edit trades" after last stock buy
//		x returnButton switches between diffent metrics [return%, return$]
//		x returnBUtton switches between: dayChange$, dayChange%, mktValue <-- not working yet
//		- return button switches between: holdings%,
//		x fix autolayout issues on table cells
//		x move constraint anchor higher when view switches
//		- in TABLES, make each stock it's own section
//		- when reloading data, only reload the stock being refreshed
//
//	- MODEL
//		x get data from web API
//		x get DAILY information from alphavantage API
//		x use daily information to calculate 1 day changes
//		x in Buys(?) class, add a way to track 1 day changes
//      x impliment saving / loading from documents library [or core data?] <--- docs library
//      x add stocks to model
//		x delete stocks from model
//      x better item management in model
//		x parse NYSE stock list
//		x parse stock lists asynchronously when app launches
//		- add 'holdings%' to show how much of portfolio is in each stock (base this off dollars)
//		x get rid of shared instance!
//
//	- TRADE EDITOR VIEW
//      x search bar view to search for stock tickers
//		x search bars is editing when view is loaded
//		x show table of trade history for selected ticker
//
//	- DATE PICKER VIEW
//		x return selected date to TradeView
//		x input validation on date - don't return date that's in the future

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, stockDelegate {

	// ******************
	// MARK: - Properties
	// ******************
	
	var stockStore: StockStore!

	var cellArray: [String] = []
	var stockCounter = 0
	
	/// TODO: % holdings for each stock
	var portfolioTableLabelValues = ["RETURN (%)", "RETURN ($)", "DAY CHANGE (%)", "DAY CHANGE ($)", "MKT VALUE"]
	var portofolioTableValueIndex = 0
	
	var todayTableLabelValues = ["DAY CHANGE ($)", "DAY CHANGE (%)"]
	var todayTableLabelValueIndex = 0
	
	/// number of rows to display in expandable table, initalize to 0
	var visibleRows = 0
	
	var updateTimer: Timer!

	// MARK: formatters
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

	// ******************
	// MARK: - Outlets
	// ******************
	
	/// LABELS
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var valueLabel: UILabel!
	@IBOutlet var dayChangeLabel: UILabel!
	@IBOutlet var returnLabel: UILabel!

	/// TABLES
	@IBOutlet var todayTable: UITableView!
	
	/// CONTROLS
	@IBOutlet var segControlOutlet: UISegmentedControl!
	
	// ***************
	// MARK: - View
	// ***************
	
	// viewDidLoad()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set the model delegate
		stockStore.delegate = self
		
		// format all the stuff
		
		/// table formatting
		todayTable.rowHeight = UITableViewAutomaticDimension
		todayTable.tableFooterView = UIView(frame: .zero)
		todayTable.tableFooterView?.isHidden = true
		todayTable.alpha = 1.0
		dayChangeLabel.alpha = 0
		
		
		/// hide day change label
		dayChangeLabel.alpha = 0
		
		/// Format Segmented Controller
		self.segControlOutlet.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
		self.segControlOutlet.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
		
		/// Set Labels
		dateLabel.text = "TODAY'S CHANGE"
		returnLabel.text = todayTableLabelValues[todayTableLabelValueIndex]
		
		/// make table lines extend edge to edge
		todayTable.layoutMargins = UIEdgeInsets.zero
		todayTable.separatorInset = UIEdgeInsets.zero

	}
	
	// view will appear()
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// when app starts up, update all the stock prices in the array
		updateAllTheData()
		
		/// timer to update prices every minute
		updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (T) in
			print("IN TIMER")
			self.updateAllTheData()
		}
		
		// set all stocks to un-expanded when view appears
		for stock in stockStore.arrayOfStocks {
			stock.isSelected = false
		}
		
		updateLabels()
		
		// reload table
		updateVisibleRows()
		todayTable.reloadData()
	}
	
	// viewWillDisappear
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// to prevent new timers from being made each time the view loads
		updateTimer.invalidate()
		
		// unexpand all rows
		for stock in stockStore.arrayOfStocks {
			stock.isSelected = false
		}
	}
	// *****************
	// MARK: - Actions
	// *****************
	
	// switch between different metrics on "portfolio" segment
	@IBAction func portfolioReturnButton(_ sender: UIButton) {
		portofolioTableValueIndex += 1
		
		if portofolioTableValueIndex == portfolioTableLabelValues.count {
			portofolioTableValueIndex = 0
		}
		updateLabels()
		todayTable.reloadData()
	}

	// switch between percent and dollars in day change
	@IBAction func todayReturnButton(_ sender: UIButton) {
		todayTableLabelValueIndex += 1
		
		if todayTableLabelValueIndex == todayTableLabelValues.count {
			todayTableLabelValueIndex = 0
		}
		updateLabels()
		todayTable.reloadData()
	}
	
	// Seg Controller - ViewSelector
	@IBAction func segmentedController(_ sender: UISegmentedControl) {
		
		/// switch views if segment is changed
		switch sender.selectedSegmentIndex {
			
			// "Today" View
			case 0:
				UIView.animate(withDuration: 0.25) {
					self.dayChangeLabel.alpha = 0
				}
				
				dateLabel.text = "TODAY"
				updateLabels()
				todayTable.reloadData()

			// "Portfolio" View
			default:
				dateLabel.text = "YOUR PORTFOLIO"
				updateLabels()
				dayChangeLabel.alpha = 1
				todayTable.reloadData()
			
				/// set label color
				if stockStore.portfolioReturnAsDouble >= 0 {
					dayChangeLabel.textColor = UIColor.green
				} else {
					dayChangeLabel.textColor = UIColor.red
				}
		}
	}

//	/// SETTINGS Go to settings Page
//	@IBAction func settingsButton(_ sender: UIBarButtonItem) {
//		performSegue(withIdentifier: "settingsSegue", sender: nil)
//	}

	// prepare for segue: send data the child views
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
			
		case "addTradesSegue"?:
			print("Going to --> Trades Editor")
			
			let newView = segue.destination as! TradeEditorViewViewController
			newView.stockArray = stockStore.arrayOfStocks
			newView.validStocks = stockStore.validStocks
			
			
		case "tradesSegue"?:
			print("Going to --> Trades Viewer")
			
			let tableRow = self.todayTable.indexPathForSelectedRow?.row
			let stockToSend = stockStore.arrayOfStocks[tableRow!]
			let newView = segue.destination as! TradesViewer
			newView.stock = stockToSend
			
		case "editTradesToAddTrade"?:
			print("Going to --> Trades Editor")

			let newView = segue.destination as! TradeEditorViewViewController
			
			// gotta subtract one to account for array indexing
			let stock = stockStore.arrayOfStocks[stockCounter - 1]
			newView.stockArray = stockStore.arrayOfStocks
			newView.stockHolder = stock
			newView.validStocks = stockStore.validStocks

			
		default:
			print("other segue")
		}
	}
	
	// *****************
	// MARK: - Funcs
	// *****************
	
	/// used to set a button to red or green, based on whether value is positive or negative
	func setColor(value: Double) -> UIColor {
		if value >= 0 {
			return UIColor.green
		} else {
			return UIColor.red
		}
	}
	
	/// update a bunch of labels when data changes
	func updateLabels() {
		
		let selectedSegmentIndex = segControlOutlet.selectedSegmentIndex
		let percentChange = percentFormatter.string(from: NSNumber(value: stockStore.portfolioReturnAsPercent))!
		let dollarChange = currencyFormatter.string(from: NSNumber(value: stockStore.portfolioReturnAsDouble))!

		if percentChange == "NaN" {
			dayChangeLabel.text = "(\(dollarChange))"
		} else {
			dayChangeLabel.text = "\(percentChange) (\(dollarChange))"
			dayChangeLabel.textColor = setColor(value: stockStore.portfolioReturnAsDouble)
		}
		
		// today view
		if selectedSegmentIndex == 0 {
			switch todayTableLabelValues[todayTableLabelValueIndex] {
			case "DAY CHANGE ($)":
				valueLabel.text = currencyFormatter.string(from: NSNumber(value: stockStore.dayChangeDouble))!
			default:
				valueLabel.text = percentFormatter.string(from: NSNumber(value: stockStore.dayChangePercent))!
			}
			returnLabel.text = todayTableLabelValues[todayTableLabelValueIndex]
			
		}
		
		// portfolio view
		else {
			valueLabel.text = currencyFormatter.string(from: NSNumber(value: stockStore.portfolioValue))!
			returnLabel.text = portfolioTableLabelValues[portofolioTableValueIndex]
		}
	}

	// this calculates the number of rows shown in the table
	func updateVisibleRows() {
		visibleRows = 0
		
		// add the number of stocks, these are always displayed
		visibleRows += stockStore.arrayOfStocks.count
		
		// add the buys from selected stocks, buys are only displayed when stock is selected
		for stock in stockStore.arrayOfStocks {
			if stock.isSelected {
				// +1 for the stock, + 2 for the "edit trades" cell
				visibleRows += stock.buys.count + 1
			}
		}
	}
	
	// this is used to calculate which 'buy' to show in cellForRowAt
	func getBuyCounter(stock: Stock) -> Int {
		var counter = 0
		
		// find the index of the buy:
		for i in stockStore.arrayOfStocks {
			// if the stock isn't the current one, and it is selcted, add all the buys + 1 to get total number of rows used by this stock
			if i.ticker != stock.ticker && i.isSelected == true {
				counter += i.buys.count + 2
			}
				
			// if this isnt the current stock, buy isnt selected, add one to the index to account for the 1 space taken up on the table
			else if i.ticker != stock.ticker && i.isSelected == false {
				counter += 1
			}
				
			// if this is the current stock, add one to account for space on table and break loop
			else if i.ticker == stock.ticker {
				counter += 1
				break

			}
		}
		return counter
		
	}
	
	// counts the number of expanded stocks, used to determine how many cells to show
	func getExpandedStocks() -> Int {
		var counter = 0
		for stock in stockStore.arrayOfStocks {
			if stock.isSelected == true {
				counter += stock.buys.count + 1
			}
		}
		return counter
	}
	
	// counts the number of "Stock"s in the array, used to determine which stock to get data from in cellForRowAt
	func getCounter(row: Int, arr: [String]) -> Int {
		// get current stock
		var counter = 0
		for i in 0..<arr.count {
			if i < row {
				if arr[i] == "Stock" {
					counter += 1
				}
			}
		}
		return counter
	}
	
	// updates the cell array, which is used to keep track of what type of cell should be deque'd in cellForRowAt
	func updateCellArray() {
		cellArray = []
		for stock in stockStore.arrayOfStocks {
			cellArray.append("Stock")
			if stock.isSelected {
				for _ in stock.buys {
					cellArray.append("Buy")
				}
				cellArray.append("Edit")
			}
		}
	}
	
	// this fetchs data from the internet to update all the stock metrics
	func updateAllTheData() {
		
		for stock in stockStore.arrayOfStocks {
			
			stockStore.fetchGlobalQuote(ticker: stock.ticker, completion: { (globalQuoteResult) -> Void in
				
				switch globalQuoteResult {
				case let .success(stockDataPackage):
					print("success!")
					
					stock.updateData(stockData: stockDataPackage)
					self.todayTable.reloadData()
					
				case let .failure(error):
					print("Error: \(error) making stocks")
					
				}
				
			})

		}
	}

	// *****************
	// MARK: - Delegates
	// *****************
	
	func updateTable() {
		print("\(#function): Reloading Data")
		
		print("### updating table")
		
		// update the holdings
		stockStore.updateHoldings()
		
		// update the table
		self.updateVisibleRows()
		self.updateLabels()
		self.todayTable.reloadData()
		
	}
	
	/// did select row
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let row = indexPath.row
		stockCounter = getCounter(row: row, arr: cellArray)
		
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
						updateVisibleRows()
						todayTable.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)

					}
					/// when an expanded cell is tapped, un-expand it
					else {
						stockStore.arrayOfStocks[stockCounter].isSelected = true
						updateVisibleRows()
						todayTable.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
					}
				
				case "tradeCell":
					print("stock Counter: \(stockCounter)")
					
					if stockStore.arrayOfStocks[stockCounter - 1].isSelected == true {
						stockStore.arrayOfStocks[stockCounter - 1].isSelected = false
					}
					updateVisibleRows()
					todayTable.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
					
				case "editTradesCell":
					performSegue(withIdentifier: "editTradesToAddTrade", sender: nil)
					
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
	
	// ***************************
	// cell for row at
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		
		switch segControlOutlet.selectedSegmentIndex {
			
			/// today view
			case 0:
				/// have to cast the cell as the custom cell type
				let stock = stockStore.arrayOfStocks[row]
				let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! TodayTableCell
				cell.layoutMargins = UIEdgeInsets.zero

				/// get values for cell
				let ticker = stock.ticker
				let price = stock.currentPrice
				let dayChange = currencyFormatter.string(from: NSNumber(value: stock.changeSinceYesterday!))
				let stockReturn = percentFormatter.string(from: NSNumber(value: stock.returnAsPercent))
				
				/// format the table cell
				cell.tickerLabel.text = ticker
				
				if price != nil {
					cell.priceLabel.text = currencyFormatter.string(from: NSNumber(value: price!))
				} else {
					cell.priceLabel.text = "error"
				}
				
				if dayChange != nil && stockReturn != nil {
					
					/// set color to green or red
					if stock.changeSinceYesterday! >= 0 {
						cell.returnOutlet.titleLabel?.textColor = UIColor.green
					} else {
						cell.returnOutlet.titleLabel?.textColor = UIColor.red
					}
					
					switch todayTableLabelValues[todayTableLabelValueIndex] {
						case "DAY CHANGE ($)":
							cell.returnOutlet.setTitle(currencyFormatter.string(from: NSNumber(value: stock.changeSinceYesterday!)), for: .normal)
							
						case "DAY CHANGE (%)":
							cell.returnOutlet.setTitle(percentFormatter.string(from: NSNumber(value: stock.changeSinceYesterdayPercent!)), for: .normal)
							
						default:
							print("\(#function) error")
					}
				}
				
				return cell

			/// portfolio view
			default:
				let numStocks = stockStore.arrayOfStocks.count
				let expandedStocks = getExpandedStocks()

				/// update the array of cells, this array determines cell types
				if row < numStocks + expandedStocks {
					updateCellArray()
				
					/// for "stock" cells
					if cellArray[row] == "Stock" {
						let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as! PortfolioTableCell
						cell.layoutMargins = UIEdgeInsets.zero

						// get current stock
						stockCounter = getCounter(row: row, arr: cellArray)
						
						let stock = stockStore.arrayOfStocks[stockCounter]
						let ticker = stock.ticker
						let price = stock.currentPrice
						let numShares = stock.totalShares
						let stockReturnPercent = percentFormatter.string(from: NSNumber(value: stock.returnAsPercent))
						let stockReturnDouble = currencyFormatter.string(from: NSNumber(value: stock.returnAsDouble))
						
						/// make sure the triangle is rotated correctly
						if stock.isSelected {
							/// animate to point down
							UIView.animate(withDuration: 0.25, animations: {
								cell.triangleMarker.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
							})
						} else {
							/// animate to point right
							UIView.animate(withDuration: 0.25, animations: {
								cell.triangleMarker.transform = CGAffineTransform(rotationAngle: 2 * CGFloat.pi)
							})
						}
						
						/// format the table cell
						cell.tickerLabel.text = ticker
						if price != nil {
							cell.priceLabel.text = currencyFormatter.string(from: NSNumber(value: price!))
						} else {
							cell.priceLabel.text = "error"

						}
						cell.numSharesLabel.text = "\(numShares) SHARES"
						
						/// set return outlet based on array values
						switch portfolioTableLabelValues[portofolioTableValueIndex] {
						case "RETURN ($)":
							cell.returnValueOutlet.setTitle(stockReturnDouble, for: .normal)
							cell.returnValueOutlet.setTitleColor(setColor(value: stock.returnAsDouble), for: .normal)

						case "RETURN (%)":
							cell.returnValueOutlet.setTitle(stockReturnPercent, for: .normal)
							cell.returnValueOutlet.setTitleColor(setColor(value: stock.returnAsPercent), for: .normal)

							/// need an optional check here
						case "DAY CHANGE ($)":
							if stock.changeSinceYesterday != nil {
								let dayChangeDouble = currencyFormatter.string(from: NSNumber(value: stock.changeSinceYesterday!))
								cell.returnValueOutlet.setTitle(dayChangeDouble, for: .normal)
								cell.returnValueOutlet.setTitleColor(setColor(value: stock.changeSinceYesterday!), for: .normal)

							} else {
								cell.returnValueOutlet.setTitle("???", for: .normal)
								cell.returnValueOutlet.setTitleColor(UIColor.yellow, for: .normal)
							}
							
						case "DAY CHANGE (%)":
							if stock.changeSinceYesterdayPercent != nil {
								let dayChangePercent = percentFormatter.string(from: NSNumber(value: stock.changeSinceYesterdayPercent!))
								cell.returnValueOutlet.setTitle(dayChangePercent, for: .normal)
								cell.returnValueOutlet.setTitleColor(setColor(value: stock.changeSinceYesterdayPercent!), for: .normal)

							} else {
								cell.returnValueOutlet.titleLabel?.textColor = UIColor.yellow
								cell.returnValueOutlet.setTitleColor(UIColor.yellow, for: .normal)
							}
						
						case "MKT VALUE":
							let mktValue = currencyFormatter.string(from: NSNumber(value: stock.totalValue))
							cell.returnValueOutlet.setTitle(mktValue, for: .normal)
							cell.returnValueOutlet.setTitleColor(setColor(value: stock.totalValue), for: .normal)

						default:
							print("\(#function): Error")
						}
						
						return cell

					}
					/// for "buys" in a stock
					else if cellArray[row] == "Buy" {
						let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath)
						
						/// get current stock
						stockCounter = getCounter(row: row, arr: cellArray)
						/// subtract 1 to account for zero indexing
						let thisStock = stockStore.arrayOfStocks[stockCounter - 1]
						let buyCounter = getBuyCounter(stock: thisStock)

						let buy = thisStock.buys[row - buyCounter]
						cell.textLabel?.text = "\(buy.numShares!) SHARES @ \(String(describing: currencyFormatter.string(from: NSNumber(value: buy.purchasePrice))!))"
						
						
						switch portfolioTableLabelValues[portofolioTableValueIndex] {
						case "RETURN (%)":
							cell.detailTextLabel?.text = percentFormatter.string(from: NSNumber(value: buy.stockReturnAsPercent))
							cell.detailTextLabel?.textColor = setColor(value: buy.stockReturnAsPercent)

						case "RETURN ($)":
							cell.detailTextLabel?.text = currencyFormatter.string(from: NSNumber(value: buy.stockReturnAsDouble))
							cell.detailTextLabel?.textColor = setColor(value: buy.stockReturnAsDouble)

						case "DAY CHANGE (%)":
							if (thisStock.changeSinceYesterdayPercent != nil) {
								cell.detailTextLabel?.text = percentFormatter.string(from: NSNumber(value: thisStock.changeSinceYesterdayPercent!))
								cell.detailTextLabel?.textColor = setColor(value: thisStock.changeSinceYesterdayPercent!)
							} else {
								cell.detailTextLabel?.textColor = UIColor.yellow
								cell.detailTextLabel?.text = "???"
							}
							
						case "DAY CHANGE ($)":
							if (thisStock.prevClose != nil) {
								let value = (thisStock.currentPrice - thisStock.prevClose!) * buy.numShares
								cell.detailTextLabel?.text = currencyFormatter.string(from: NSNumber(value: (value) ))
								cell.detailTextLabel?.textColor = setColor(value: value)

							} else {
								cell.detailTextLabel?.textColor = UIColor.yellow
								cell.detailTextLabel?.text = "???"
							}
							
						case "MKT VALUE":
							let mktValue = currencyFormatter.string(from: NSNumber(value: Double(thisStock.currentPrice) * buy.numShares))
							cell.detailTextLabel?.text = mktValue
							cell.detailTextLabel?.textColor = setColor(value: thisStock.totalValue)

						default:
							print("\(#function): ERROR")
						}
						
						return cell
					}
					
					else if cellArray[row] == "Edit" {
						
						/// loop through array to get the index
						stockCounter = getCounter(row: row, arr: cellArray)
						
						let stock = stockStore.arrayOfStocks[stockCounter - 1]
						let ticker = stock.ticker
						let cell = tableView.dequeueReusableCell(withIdentifier: "editTradesCell", for: indexPath)
						cell.textLabel?.text = "EDIT TRADES FOR \(ticker)"
						return cell
					}
					
				}
				
				/// this should always be the last cell in the table
				let cell = tableView.dequeueReusableCell(withIdentifier: "addTradesCell", for: indexPath)
				return cell
		}
	}
	///***************************
	
}
