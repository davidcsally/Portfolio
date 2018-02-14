//
//  Stock.swift
//  stockApp
//
//  Created by David Sally on 4/14/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

// enums's for currentPriceForTicker
enum currentPriceResult {
	case success(Double)
	case failure(Error)
}

class Stock: NSObject, NSCoding {

	// ******************
	// MARK: - Properties
	// ******************
	
	var buys: [StockBuy] = [] {
		// after every buy, the current price is updated; probably a better way to do this
		didSet {
			for buy in buys {
				buy.currentPrice = currentPrice
			}
		}
	}
	
	var delegate: stockDelegate?
	
	// Basic Properties
	var name: String?
	var ticker: String
	
	// Fetched Properties
	var open: Double?
	var prevClose: Double?
	var high: Double?
	var low: Double?
	var volume: String?
	
	var holdings: Double?

	// for table view
	var isSelected = false
	
	// MARK: Computed Properties
	
	var totalShares: Double {
		var totShares = 0.0
		for buy in buys {
			totShares += buy.numShares
		}
		return totShares
	}
	
	var purchasePrice: Double {
		var purPrice = 0.0
		for buy in buys {
			purPrice += (buy.purchasePrice * buy.numShares)
		}
		return purPrice
	}
	
	var totalValue: Double {
		return totalShares * currentPrice
	}

	var returnAsDouble: Double {
		return totalValue - purchasePrice
	}
	
	var returnAsPercent: Double {
		return (totalValue - purchasePrice) / purchasePrice
	}

	// passed in
	var currentPrice: Double! {
		
		// when current price is updated, update the value in the buy array as well, this is for calculating the return of the buy
		didSet {
			for buy in buys {
				buy.currentPrice = currentPrice
			}
		}
	}
	
	
	// 1 day changes
	var changeSinceYesterday: Double? {
		if prevClose != nil {
			return (currentPrice - prevClose!) * totalShares
		} else {
			print("\(ticker): Error giving day change price")
			return 0
		}
	}
	
	var changeSinceYesterdayPercent: Double? {
		if prevClose != nil {
			return (totalValue - totalShares*prevClose!) / totalValue
		} else {
			print("\(ticker): Error giving day change price as percent")
			return 0
		}
	}

	// MARK: Properties not implimented
	// stock properties in Detail Trades View; not implimented
	var mktCap: Double = 0
	var PE: Double = 0
	var avgVol: Double = 0
	var nextEarnings: Double = 0
	var dividend: Double? = 0
	
	// *************
	// MARK: - Inits
	// *************
	
	init(ticker: String) {
		self.ticker = ticker
		self.currentPrice = 0
		super.init()
	}
	
	convenience init(ticker: String, currentPrice: Double) {
		self.init(ticker: ticker)
		self.currentPrice = currentPrice
	}
	
	
	// *************
	// MARK: - Funcs
	// *************
	
	func updateData(stockData: [String]) {
		
		self.currentPrice = Double(stockData[1])
		self.open = Double(stockData[2])
		self.high = Double(stockData[3])
		self.low = Double(stockData[4])
		self.prevClose = Double(stockData[5])
		self.volume = stockData[6]

//		// debug - print
//		print(stockData)
	}
	
	// buy a stock
	func appendNewPurchase(newStock: StockBuy) {
		buys.append(newStock)
	}
	
	// set current price
	func setCurrentPrice(price: Double) {
		currentPrice = price
	}

	// ****************
	// MARK: - NSCoding
	// ****************
	
	// for NSCoding - encode values to store
	func encode(with aCoder: NSCoder) {
		aCoder.encode(buys, forKey: "buys")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(ticker, forKey: "ticker")
		aCoder.encode(isSelected, forKey: "isSelected")
		aCoder.encode(currentPrice, forKey: "currentPrice")
		aCoder.encode(prevClose, forKey: "prevClose")
	}
	
	// NSCoding required init - decodes values when they are loaded
	required init?(coder aDecoder: NSCoder) {
		buys = aDecoder.decodeObject(forKey: "buys") as! [StockBuy]
		name = aDecoder.decodeObject(forKey: "name") as? String
		ticker = aDecoder.decodeObject(forKey: "ticker") as! String
		isSelected = aDecoder.decodeBool(forKey: "isSelected")
		currentPrice = aDecoder.decodeObject(forKey: "currentPrice") as! Double
		prevClose = aDecoder.decodeObject(forKey: "prevClose") as? Double
		
		super.init()
	}

}


// Mark: - Old Code

// [Step 1]: get the current price, when a new stock is created
//	func getCurrentPrice(completion: @escaping (currentPriceResult) -> Void) {
//		let url = AlphaVantageAPI.alphaVantageURL(function: .timeSeriesIntraDay, ticker: self.ticker)
//		let session = URLSession.shared
//
//		let task = session.dataTask(with: url) {
//			(data: Data?, response: URLResponse?, error: Error?) -> Void in
//
//			let result = self.processJSON(data: data, error: error)
//
//			OperationQueue.main.addOperation {
//				self.delegate?.updateTable()
//				completion(result)
//			}
//		}
//		task.resume()
//	}

// [Step 2]: ensure JSON data is valid
//	private func processJSON(data: Data?, error: Error?) -> currentPriceResult {
//		guard let jsonData = data else {
//			return .failure(error!)
//		}
//
//		return AlphaVantageAPI.currentPrice(fromJSON: jsonData)
//	}
