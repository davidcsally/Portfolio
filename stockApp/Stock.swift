//
//  Stock.swift
//  stockApp
//
//  Created by David Sally on 4/14/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

/// TODO - subclass NSCoding
class Stock: NSObject, NSCoding {

	/// Array of StockBuys
	var buys: [StockBuy] = []
	
	/// Basic Stock Properties
	var name: String?
	var ticker: String
	
	/// for table view
	var isSelected: Bool = false
	
	/// Calculated Properties
	var totalShares: Double {
		var counter:Double = 0
		for buy in buys {
			counter += buy.numShares
		}
		return counter
	}
	
	var returnAsPercent: Double {
		return purchasePrice / currentPrice
	}
	
	var purchasePrice: Double {
		var counter: Double = 0
		for buy in buys {
			counter += buy.purchasePrice
		}
//		print("purchasePrice: \(counter)")
		return counter
	}
	
	var totalValue: Double {
		var counter: Double = 0
		for buy in buys {
			counter += buy.numShares
		}
		print("total value: \(counter * currentPrice)")
		return counter * currentPrice
	}

	var returnAsDouble: Double {
		
		var counter: Double = 0
		for buy in buys {
			counter += buy.stockReturnAsDouble
		}
		print("return as double = ")
		return counter - totalValue
	}
	
	/// passed in
	var currentPrice: Double! {
		didSet {
			for buy in buys {
				buy.currentPrice = currentPrice
			}
			print("cur price: \(currentPrice), purPrice: \(purchasePrice), return: \(returnAsPercent)")
		}
	}
	
	/// stock properties in Detail Trades View
	var prevClose: Double = 0
	var volume: Double = 0
	var mktCap: Double = 0
	var PE: Double = 0
	var open: Double = 0
	var avgVol: Double = 0
	var nextEarnings: Double = 0
	var dividend: Double? = 0
	
	/// Init
	init(ticker: String) {
	
		self.ticker = ticker
		self.currentPrice = 0
		
		super.init()

		/// have to do this if check, otherwise this would run for string "" when the array is initialized in the stockStore
		if ticker != "" {
			getPriceForTicker(ticker: ticker) { (result) -> Void in
				if let price = result {
					self.currentPrice = price
					print("~~~STOCK ~~~~ ticker: \(self.ticker), price: \(self.currentPrice)")
				} else {
					print("error getting price for: \(self.ticker)")
				}
			}
		}
		
	}

	
	/// Funcs
	
	/// buy a stock
	func appendNewPurchase(newStock: StockBuy) {
		buys.append(newStock)
	}
	
	
	/// set current price
	func setCurrentPrice(price: Double) {
		currentPrice = price
	}
	
	/// get the current price, when a new stock is created
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
				
				if array.isEmpty == false {
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

				} else {
					print("HUGE ERROR")
				}
				
				
				
			} catch let error {
				print("Error: \(error)")
			}
			
			
		}
		task.resume()
		
		print("returning...")
	}

	/// for NSCoding - encode values to store
	func encode(with aCoder: NSCoder) {
		aCoder.encode(buys, forKey: "buys")
		aCoder.encode(name, forKey: "name")
		aCoder.encode(ticker, forKey: "ticker")
	}
	
	/// NSCoding required init - decodes values when they are loaded
	required init?(coder aDecoder: NSCoder) {
		buys = aDecoder.decodeObject(forKey: "buys") as! [StockBuy]
		name = aDecoder.decodeObject(forKey: "name") as? String
		ticker = aDecoder.decodeObject(forKey: "ticker") as! String
		
		super.init()
	}

}
