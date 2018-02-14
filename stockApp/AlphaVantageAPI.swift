//
//  AlphaVantageAPI.swift
//  stockApp
//
//  Created by David Sally on 4/18/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import Foundation


// MARK: - ENUM
// API method to call
enum Function: String {
	case timeSeriesIntraDay = "TIME_SERIES_INTRADAY"
	case timeSeriesDaily = "TIME_SERIES_DAILY"
	case globalQuote = "GLOBAL_QUOTE"
}

struct AlphaVantageAPI {
	
	// MARK: - Properties q
	private static let baseURLString = "http://www.alphavantage.co/query?"
	private static let alphaVantageAPIKey = "QYHT"
	
	// MARK: - Funcs
	static func stockData(fromJSON data: Data) -> globalQuote {
    print("global: \(data)")
		do {
			let json = try JSON(data: data)
      print("JSON: \(json)")
			var dataArr: [String] = []
			print(dataArr)
			dataArr.append(json["Realtime Global Securities Quote"]["01. Symbol"].string!)
			dataArr.append(json["Realtime Global Securities Quote"]["03. Latest Price"].string!)
			dataArr.append(json["Realtime Global Securities Quote"]["04. Open (Current Trading Day)"].string!)
			dataArr.append(json["Realtime Global Securities Quote"]["05. High (Current Trading Day)"].string!)
			dataArr.append(json["Realtime Global Securities Quote"]["06. Low (Current Trading Day)"].string!)
			dataArr.append(json["Realtime Global Securities Quote"]["07. Close (Previous Trading Day)"].string!)
			dataArr.append(json["Realtime Global Securities Quote"]["10. Volume (Current Trading Day)"].string!)
			
			return .success(dataArr)
			
		} catch let error {
			print("Error: \(error)")
			return .failure(error)
		}
		
	}
	
	// Call this to get the API URL
		
	// return the URL with the custom calls
	static func alphaVantageURL(function: Function, ticker: String) -> URL {
		print(#function)
		
		// base string
		var components = URLComponents(string: baseURLString)!
		
		// an array of strings to append to the string
		var queryItems = [URLQueryItem]()
		
		// things to add to the API call
		let baseParams = [
			"function": function.rawValue,
			"symbol": ticker,
			"interval": "1min",
			"outputsize": "compact",
			"apikey": alphaVantageAPIKey
		]
		
		// add the parameters to the API call
		for (key, value) in baseParams {
			let item = URLQueryItem(name: key, value: value)
			queryItems.append(item)
		}
				
		components.queryItems = queryItems
    print("URL: \(components.url!)")
		return components.url!
	}
	
}

// MARK: Old Code

//	private static func stock(fromJSON json: JSON) -> Stock? {
//		print(#function)
//
//		/// get the time series data
//		let timeSeries = json["Time Series (1min)"]
//
//		// sort the time series
//		let array = timeSeries.sorted(by: {$0 > $1} )
//
//
//		/// get most recent from time series as a JSON file
//		var currentData = array[0].1
//
//		/// print most recent
//		print("cur: \(currentData)")
//		let ticker = json["Meta Data"]["2. Symbol"].string!
//
//		let close = currentData["4. close"].string!
//
//		print("price: \(close)")
//
//		return Stock(ticker: ticker, currentPrice: Double(close)!)
//	}


//	// this func processes a json file, it assumes a valid json will be passed
//	static func yesterdaysPrice(fromJSON data: Data) -> yesterdaysPriceResult {
//		print(#function)
//
//		do {
//			let json = try JSON(data: data)
//
//			// split the json into a sub-json of Time Series data
//			let timeSeries = json["Time Series (Daily)"]
//
//			// turn the JSON into an array, sorted by newest data to oldest
//			let sortedTimeSeriesArray = timeSeries.sorted(by: {$0 > $1})
//
//			// parse out yesterday's information, and today's information, AS mini JSON files
//			let yesterday = sortedTimeSeriesArray[1].1
//			let today = sortedTimeSeriesArray[0].1
//
//			// get the data from the mini JSON files
//			let openingPrice = today["1. open"].string!
//			let volume = today["5. volume"].string!
//			let closingPrice = yesterday["4. close"].string!
//
//			// return a success message, with the three doubles
//			return .success([Double(openingPrice), Double(volume), Double(closingPrice)])
//
//		}
//
//		// if something went wrong, return an error message
//		catch let error {
//			print("Error: \(error)")
//			return .failure(error)
//		}
//	}

// [step 3] process the data
//	static func currentPrice(fromJSON data: Data) -> currentPriceResult {
//		print(#function)
//
//		do {
//			let json = try JSON(data: data)
//
//			// get the time series data
//			let timeSeries = json["Time Series (1min)"]
//
//			// sort the time series, to get most recent
//			let array = timeSeries.sorted(by: {$0 > $1} )
//
//			var currentData = array[0].1
//			let close = Double(currentData["4. close"].string!)
//
//			// print most recent
////			print("cur: \(currentData)")
////			print("price: \(close)")
//
//			return .success(close!)
//
//		} catch let error {
//			print("Error: \(error)")
//			return .failure(error)
//		}
//	}
//
//	// For getting the daily results, returns either "Error" or "[Stock]"
//	static func stocks(fromJSON data: Data) -> dailyStockPriceResult {
//		print(#function)
//
//		do {
//			let json = try JSON(data: data)
//
//			var finalStocks = [Stock]()
//
//			if let stock = stock(fromJSON: json) {
//				print("appending: |\(stock.ticker)| to stock array!")
//				finalStocks.append(stock)
//			}
//
//			return .success(finalStocks)
//
//		} catch let error {
//			print("Error: \(error)")
//			return .failure(error)
//		}
//	}
