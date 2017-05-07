//
//  StockModel.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

/// enum
enum StocksResult {
	case success([Stock])
	case failure(Error)
}

class StockStore {
	
	/// ******************
	/// *** Properties ***
	/// ******************
	// MARK: - Properties
	
	/// Array to hold all stocks
	var arrayOfStocks: [Stock] = []

	/// this list of stocks is used when the user wants to enter a new trade
	var validStocks: [StockList] = []
	
	/// saving / loading from archive
	let itemArchive: URL = {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentDirectory = documentsDirectory.first!
		
		/// append the filename to the path - stocks.archive
		return documentDirectory.appendingPathComponent("stocks.archive")
	}()
	
	/// shared instance
	static let sharedInstance = StockStore()

	/// Calculated Properties
	var purchasePrice: Double = 0
	var portfolioValue: Double = 0
	var portfolioReturnAsDouble: Double = 0
	var portfolioReturnAsPercent: Double = 0
	
	
	/// *****************
	/// *** API Calls ***
	/// *****************
	// MARK: - API stuff
	
	/// turn the recieved data into a JSON object
	private func processStockRequest(data: Data?, error: Error?) -> StocksResult {
		print(#function)
		guard let jsonData = data else {
			return .failure(error!)
		}
		return AlphaVantageAPI.stocks(fromJSON: jsonData)
	}
	
	/// try to fetch the data
	func fetchAlphaVantage(completion: @escaping (StocksResult) -> Void) {

		/// loop through stocks array to get quotes for each ticker
		for i in 0..<arrayOfStocks.count {
			let url = AlphaVantageAPI.alphaVantageURL(function: .timeSeriesIntraDay, ticker: arrayOfStocks[i].ticker)
			
			print(url)
			
			let session = URLSession.shared
			
			let task = session.dataTask(with: url) {
				(data: Data?, response: URLResponse?, error: Error?) -> Void in
				
				let result = self.processStockRequest(data: data, error: error)
				
				OperationQueue.main.addOperation {
					completion(result)
				}
			}
			task.resume()

		}
	}
	
	func getPriceForTicker(ticker: String, completion: ((_ result:Double?) -> Void)!) {
		
		let url = AlphaVantageAPI.alphaVantageURL(function: .timeSeriesIntraDay, ticker: ticker)
		
		let session = URLSession.shared
		
		let task = session.dataTask(with: url) {
			(data: Data?, response: URLResponse?, error: Error?) -> Void in
			
			do {
				let json = try JSON(data: data!)
				
				/// get the time series data
				let timeSeries = json["Time Series (1min)"]
				
				// sort the time series
				let array = timeSeries.sorted(by: {$0 > $1} )
				
				/// get most recent from time series as a JSON file
				var currentData = array[0].1
				
				/// print most recent
				print("cur: \(currentData)")
				
				let close = currentData["4. close"].string!
				
				print("price: \(close)")
				
				OperationQueue.main.addOperation {
					let currentPrice = Double(close)
					completion(currentPrice)
				}
				
				
			} catch let error {
				print("Error: \(error)")
			}

			
		}
		task.resume()
		
		print("returning...")
	}
	
	
	// MARK: - Init()
	
	init() {
		print(#function)
		
		DispatchQueue.global().async {
			if let file = self.readDataFromFile(file: "NASDAQ") {
				self.convertCSV(file: file)
			}
		}
		
		/// check if saved stocks exists, if so load them
		if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: itemArchive.path) as? [Stock] {
			
			/// set stock array equal to all the items that were stored in the array
			arrayOfStocks = archivedItems
		}
		
	}
	
	// MARK: - Funcs
	
	/// save changes
	func saveChanges() -> Bool {
		print("saving items to: \(itemArchive)")
		return NSKeyedArchiver.archiveRootObject(arrayOfStocks, toFile: itemArchive.path)
	}
 
	// add a new stock to the store
	func addNewStock(name: String, ticker: String, numShares: Double, purchasePrice: Double, purchaseDate: Date?) {
		var isStockNew: Bool = true
		var index: Int = 0
		
		let newBuy = StockBuy(ticker: ticker, numShares: numShares, purchasePrice: purchasePrice, purchaseDate: purchaseDate)
		
		if arrayOfStocks.isEmpty {
			print("newBuy: \(newBuy.ticker)")

			let newStock = Stock(ticker: ticker)
			newStock.appendNewPurchase(newStock: newBuy)
			arrayOfStocks.append(newStock)
			return
		}
		
		/// check if new stock is unique
		for i in 0..<arrayOfStocks.count {
			if String(arrayOfStocks[i].ticker) == String(newBuy.ticker) {
				print("stock is not new: \(newBuy.ticker) == \(arrayOfStocks[i].ticker)")
				isStockNew = false
				index = i
			}
		}
		
		/// if stock is new, add to array and append new buy to that stock
		if isStockNew {
			print("creating new stock & buy: \(ticker)")
			
			let newStock = Stock(ticker: ticker)
			newStock.appendNewPurchase(newStock: newBuy)
			arrayOfStocks.append(newStock)
			print("numStocks: \(arrayOfStocks.count)")
		}
		
		/// if stock ticker is already in array, add a new buy to it
		else if arrayOfStocks.count > 0 {
			print("appending buy to: \(ticker)")
			arrayOfStocks[index].appendNewPurchase(newStock: newBuy)
		}
		
		/// update these values, after something has been added
		calcPortfolioValue()
		updateReturn()
	}
	
	// calc portfolio value
	func calcPortfolioValue() {
		portfolioValue = 0
		
		/// add up the value of all the shares
		for stock in arrayOfStocks {
			for buy in stock.buys {
				
				/// have to update curent price of the buy
				buy.currentPrice = stock.currentPrice
				print(buy.currentValue)
				portfolioValue += buy.currentValue
			}
		}
				
		updateReturn()
	}
	
	/// func calc purchase price
	func updatePurchasePrice() {
		purchasePrice = 0
		for purchase in arrayOfStocks {
			purchasePrice += purchase.purchasePrice
		}
	}
	
	func updateReturn() {
		portfolioReturnAsDouble = portfolioValue - purchasePrice
		portfolioReturnAsPercent = (portfolioValue - purchasePrice) / 100
	}
	
	func updateValidStocks() {
		
	}
	
	// MARK: - Funcs for parsing text files
	
	func readDataFromFile(file: String) -> String? {
		print(#function)

		guard let filePath = Bundle.main.path(forResource: file, ofType: "txt")
			else {
				print("guard error!")
				return nil
		}

		do {
			let contents = try String(contentsOfFile: filePath)
			print("found file")
			return contents
		} catch {
			print ("File Read Error")
			return nil
		}

		
	}
	
	func cleanRows(file:String)->String{
		print(#function)

		var cleanFile = file
		cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
		cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
		return cleanFile
	}
	
	func convertCSV(file:String){
		print(#function)
		/// convert csv file into an array of lines
		let rows = cleanRows(file: file).components(separatedBy: "\n")
		
		/// parse each line
		if rows.count > 0 {
			
			for row in rows{
				
				let components = row.components(separatedBy: "\",")
				
				if components.count >= 2 {
					var ticker:String = components[0]
					ticker.remove(at: ticker.startIndex)
					var name:String = components[1]
					name.remove(at: name.startIndex)
					let market: market = .NASDAQ
					
//					print("adding: \(ticker) | \(name))")
					
					if ticker != "Symbol" {
						let newStock = StockList(ticker: ticker.uppercased(), name: name, market: market)
						validStocks.append(newStock)
					}
				}
			}
		}
	}
}
