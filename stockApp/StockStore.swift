//
//  StockModel.swift
//  stockApp
//
//  Created by David Sally on 4/9/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

// enum - to catch bad API calls 
enum dailyStockPriceResult {
	case success([Stock])
	case failure(Error)
}

// enum's for yesterday ticker
enum yesterdaysPriceResult {
	case success([Double?])
	case failure(Error)
}

// enum for Alpha Vantage's new Global Quote method
enum globalQuote {
	case success([String])
	case failure(Error)
}

// delegate to update the table
protocol stockDelegate {
	func updateTable()
}

class StockStore: NSCoding {
		
	// ******************
	// MARK: - Properties
	// ******************
	
	var delegate: stockDelegate?
	
	// Array to hold all stocks
	var arrayOfStocks: [Stock] = []

	// this list of stocks is used when the user wants to enter a new trade
	var validStocks: [StockList] = []
	var hasStockListBeenProcessed = false
	
	// saving / loading from archive
	let itemArchive: URL = {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentDirectory = documentsDirectory.first!
		
		// append the filename to the path - stocks.archive
		return documentDirectory.appendingPathComponent("stocks.archive")
	}()
	

	// MARK: Computed Properties
	
	var portfolioValue: Double {
		var dollars = 0.0
		for stock in arrayOfStocks {
			dollars += stock.totalValue
		}
		
		return dollars
	}
	
	var purchasePrice: Double {
		var dollars = 0.0
		for stock in arrayOfStocks {
			dollars += stock.purchasePrice
		}
		return dollars
	}
	
	var portfolioReturnAsDouble: Double {
		var dollars = 0.0
		
		for stock in arrayOfStocks {
			dollars += stock.returnAsDouble
		}
		return dollars
	}
	
	var portfolioReturnAsPercent: Double {
		return (portfolioValue - purchasePrice) / purchasePrice
	}
	
	var dayChangeDouble: Double {
		var dollars = 0.0
		
		for stock in arrayOfStocks {
			if stock.changeSinceYesterday != nil {
				dollars += stock.changeSinceYesterday! //* stock.totalShares//
			}
		}
		return dollars
	}
	
	var dayChangePercent: Double {
		var change = 0.0
		for stock in arrayOfStocks {
			if stock.prevClose != nil {
				change += stock.totalShares * stock.prevClose!
			}
		}
		let percent = (portfolioValue - change) / portfolioValue
		return percent
	}

	
	// *****************
	// MARK: - API stuff
	// *****************
	
	private func processGlobalQuote(data: Data?, error: Error?) -> globalQuote {
		print(#function)
		guard let jsonData = data else {
			return .failure(error!)
		}
		
		return AlphaVantageAPI.stockData(fromJSON: jsonData)
	}
	
	func fetchGlobalQuote(ticker: String, completion: @escaping (globalQuote) -> Void) {
		print(#function)

		let url = AlphaVantageAPI.alphaVantageURL(function: .globalQuote, ticker: ticker)

		let session = URLSession.shared

		let task = session.dataTask(with: url) {
			(data: Data?, response: URLResponse?, error: Error?) -> Void in

			let result = self.processGlobalQuote(data: data, error: error)

			OperationQueue.main.addOperation {
				self.delegate?.updateTable()
				
				// wrap the results in the completion variable, this basically is returned to the caller in the view controller
				completion(result)
			}
		}
		task.resume()
	}
	
	// ************
	// MARK: - Init
	// ************
	
	init() {
		print(#function)
		
		// if the stock list hasn't been processed (ie first launch)
		if hasStockListBeenProcessed == false {
			print("parsing list of valid stocks")
			
			// process NASDAQ list
			if let nasdaqFile = self.readDataFromFile(file: "NASDAQ") {
				self.convertCSV(file: nasdaqFile)
			}
			
			// process NYSE list
			if let nyseFile = self.readDataFromFile(file: "NYSE") {
				self.convertCSV(file: nyseFile)
			}
			
			hasStockListBeenProcessed = true
		}
		
		/// check if saved stocks exists, if yes, load them
		if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: itemArchive.path) as? [Stock] {
			print("\(#function): Loading Saved Data")
			
			/// set stock array equal to all the items that were stored in the array
			arrayOfStocks = archivedItems
		}
		
	}
	
	// *************
	// MARK: - Funcs
	// *************
	
	// save changes -> return true if successful, return false if bad;
	// this is done in AppDelegate when App enters background
	func saveChanges() -> Bool {
		print("saving items to: \(itemArchive)")
		return NSKeyedArchiver.archiveRootObject(arrayOfStocks, toFile: itemArchive.path)
	}
 
	// remove a stock from the store
	func deleteStock(ticker: String) {
		// find the index for a given ticker
		if let i = arrayOfStocks.index(where: { $0.ticker == ticker }) {
			if arrayOfStocks[i].buys.count == 0 {
				print("\(ticker): Removing \(arrayOfStocks[i].ticker) from store; buys = \(arrayOfStocks[i].buys.count)")
				arrayOfStocks.remove(at: i)
				print("arrOfStocks Size: \(arrayOfStocks.count)")
			}
		}
	}
	
	// add a new stock to the store
	func addNewStock(name: String, ticker: String, numShares: Double, purchasePrice: Double, purchaseDate: Date?) {

		// make a new buy
		let newBuy = StockBuy(ticker: ticker, numShares: numShares, purchasePrice: purchasePrice, purchaseDate: purchaseDate)
//		print("newBuy: tick: \(ticker), numShares: \(numShares), purPrice: \(purchasePrice), date: \(String(describing: purchaseDate))")
		
		// fetch the price for the new buy
		fetchGlobalQuote(ticker: ticker) { (globalQuoteResult) -> Void in
			switch (globalQuoteResult) {
			case let .success(results):
				if let indexToUpdate = self.arrayOfStocks.index(where: {$0.ticker == ticker}) {
					self.arrayOfStocks[indexToUpdate].updateData(stockData: results)
				}
				
			case let .failure(error):
				print("Error: \(error)")
			}
		}
		
		
		// append a stock to an empty stock store
		if arrayOfStocks.isEmpty {
//			print("[Empty]: Appending \(newBuy.ticker) to store")

			let newStock = Stock(ticker: ticker)
			newStock.name = name
			newStock.appendNewPurchase(newStock: newBuy)
			arrayOfStocks.append(newStock)
			
		} else {
			// check if new stock is unique
			if let stockIndex = arrayOfStocks.index(where: {$0.ticker == ticker}) {
//				print("\(ticker): Exists in stock store")
//				print("\(ticker): Appending buy")
				arrayOfStocks[stockIndex].appendNewPurchase(newStock: newBuy)
				
			}
			
			// if stock is new, add to array and append new buy to that stock
			else {
//				print("\(ticker): Does not exist in store")
				let newStock = Stock(ticker: ticker)
				newStock.name = name
				newStock.appendNewPurchase(newStock: newBuy)
				arrayOfStocks.append(newStock)
			}
		}
	}
	
	func updateHoldings() {
		
		// update each stock
		for stock in arrayOfStocks {
			stock.holdings = stock.totalValue / portfolioValue
			
			// update buys in the stock
			for buy in stock.buys {
				buy.holdings = buy.currentValue / portfolioValue
			}
		}
	}

	
	// ************************************
	// MARK: - Funcs for parsing text files
	// ************************************
	
	private func readDataFromFile(file: String) -> String? {

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
	
	private func cleanRows(file:String)->String{

		var cleanFile = file
		cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
		cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
		return cleanFile
	}
	
	private func convertCSV(file:String){

		/// convert csv file into an array of lines
		let rows = cleanRows(file: file).components(separatedBy: "\n")
		
		if rows.count > 0 {
			
			/// parse each line
			for row in rows {
				
				let components = row.components(separatedBy: "\",")
				
				if components.count >= 2 {
					var ticker:String = components[0]
					ticker.remove(at: ticker.startIndex)
					var name:String = components[1]
					name.remove(at: name.startIndex)
					
					// to catch the end of the file
					if ticker != "Symbol" {
						let newStock = StockList(ticker: ticker.uppercased(), name: name)
						validStocks.append(newStock)
					}
				}
			}
		}
	}
	
	// ****************
	// MARK: - NSCoding
	// ****************
	
	required init?(coder aDecoder: NSCoder) {
		validStocks = aDecoder.decodeObject(forKey: "validStocks") as! [StockList]
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(validStocks, forKey: "validStocks")
	}

}

// old code
// turn the recieved data into a JSON object
//	private func processStockRequest(data: Data?, error: Error?) -> dailyStockPriceResult {
//		print(#function)
//		guard let jsonData = data else {
//			return .failure(error!)
//		}
//		return AlphaVantageAPI.stocks(fromJSON: jsonData)
//	}

// try to fetch the data
//	func fetchAlphaVantage(completion: @escaping (dailyStockPriceResult) -> Void) {
//		print(#function)
//		// loop through stocks array to get quotes for each ticker
//		for i in 0..<arrayOfStocks.count {
//			let url = AlphaVantageAPI.alphaVantageURL(function: .timeSeriesIntraDay, ticker: arrayOfStocks[i].ticker)
//
//			print(url)
//
//			let session = URLSession.shared
//
//			let task = session.dataTask(with: url) {
//				(data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//				let result = self.processStockRequest(data: data, error: error)
//
//				OperationQueue.main.addOperation {
//					self.delegate?.updateTable()
//					completion(result)
//				}
//			}
//			task.resume()
//		}
//	}

//	private func processYesterdaysDataRequest(data: Data?, error: Error?) -> yesterdaysPriceResult {
//		print(#function)
//		guard let jsonData = data else {
//			return .failure(error!)
//		}
//		return AlphaVantageAPI.yesterdaysPrice(fromJSON: jsonData)
//	}

//	func fetchYesterdaysPrice(ticker: String, completion: @escaping (yesterdaysPriceResult) -> Void) {
//		print(#function)
//
//		let url = AlphaVantageAPI.alphaVantageURL(function: .timeSeriesDaily, ticker: ticker)
//		let session = URLSession.shared
//
//		let task = session.dataTask(with: url) {
//			(data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//			let result = self.processYesterdaysDataRequest(data: data, error: error)
//
//			OperationQueue.main.addOperation {
//				self.delegate?.updateTable()
//				completion(result)
//			}
//		}
//		task.resume()
//	}


// API request for all data
//	func fetchGlobalQuote(completion: @escaping (globalQuote) -> Void) {
//		print(#function)
//
//		// loop through stocks to get info for all tickers
//
//		for stock in arrayOfStocks {
//			let url = AlphaVantageAPI.alphaVantageURL(function: .globalQuote, ticker: stock.ticker)
//
////			print('url: \(url)')
//
//			let session = URLSession.shared
//
//			let task = session.dataTask(with: url) {
//				(data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//				let result = self.processGlobalQuote(data: data, error: error)
//
//				OperationQueue.main.addOperation {
//					self.delegate?.updateTable()
//					// wrap the results in the completion variable, this basically is returned to the caller in the view controller
//					completion(result)
//				}
//			}
//			task.resume()
//		}
//	}



/// update the prev close when adding to the store
//		fetchYesterdaysPrice(ticker: ticker) { (result) -> Void in
//
//				switch result {
//				case let .success(results):
//					if let indexToUpdate = self.arrayOfStocks.index(where: {$0.ticker == ticker}) {
//						self.arrayOfStocks[indexToUpdate].prevClose = results[0]
//						self.arrayOfStocks[indexToUpdate].open = results[1]
//						self.arrayOfStocks[indexToUpdate].volume = results[2]!
//						self.delegate?.updateTable()
//					}
//
//				case let .failure(error):
//					print("error making stocks: \(error)")
//				}
//		}

