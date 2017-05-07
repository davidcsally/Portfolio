//
//  AlphaVantageAPI.swift
//  stockApp
//
//  Created by David Sally on 4/18/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import Foundation

/// API method to call
enum Function: String {
	case timeSeriesIntraDay = "TIME_SERIES_INTRADAY"
	case timeSeriesDaily = "TIME_SERIES_DAILY"
}

enum AlphaVantageError: Error {
	case invalidJSONData
}

struct AlphaVantageAPI {
	
	/// Alpha Vantage
	private static let baseURLString = "http://www.alphavantage.co/query?"
	private static let alphaVantageAPIKey = "QYHT"

	
	///
	static func stocks(fromJSON data: Data) -> StocksResult {
		print(#function)
		
		do {
			let json = try JSON(data: data)

			var finalStocks = [Stock]()

			if let stock = stock(fromJSON: json) {
				print("appending: |\(stock.ticker)| to stock array!")
				finalStocks.append(stock)
			}
			
			return .success(finalStocks)

		} catch let error {
			print("Error: \(error)")
			return .failure(error)
		}
	}
	
	private static func stock(fromJSON json: JSON) -> Stock? {
		print(#function)
		
		/// get the time series data
		let timeSeries = json["Time Series (1min)"]
		
		// sort the time series
		let array = timeSeries.sorted(by: {$0 > $1} )
		
		
		/// get most recent from time series as a JSON file
		var currentData = array[0].1
		
		/// print most recent
		print("cur: \(currentData)")
		let ticker = json["Meta Data"]["2. Symbol"].string!

		let open = currentData["1. open"]
		let close = currentData["4. close"].string!
		
		print("price: \(close)")
		print("open: \(open)")

		return Stock(ticker: ticker)
//		return Stock(name: "Bio-Rad", ticker: ticker)
//		return Stock(name: "Bio-Rad", ticker: ticker, currentValue: Double(close)!)
	}
	
	/// Call this to get the API URL
	/// this is good, don't change
	
	/// return the URL with the custom calls
	static func alphaVantageURL(function: Function, ticker: String) -> URL {
		print(#function)
		
		/// base string
		var components = URLComponents(string: baseURLString)!
		
		/// an array of strings to append to the string
		var queryItems = [URLQueryItem]()
		
		/// things to add to the API call
		let baseParams = [
			"function": function.rawValue,
			"symbol": ticker,
			"interval": "1min",
			"outputsize": "compact",
			"apikey": alphaVantageAPIKey
		]
		
		/// add the parameters to the API call
		for (key, value) in baseParams {
			let item = URLQueryItem(name: key, value: value)
			queryItems.append(item)
		}
				
		components.queryItems = queryItems
		
		return components.url!
		
	}
	
}
