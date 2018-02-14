// Doesn't do anything, maybe in the future i will get this to work

////
////  GoogleFinanceAPI.swift
////  stockApp
////
////  Created by David Sally on 4/18/17.
////  Copyright © 2017 David Sally. All rights reserved.
////
//
//import Foundation
//
////
////  AlphaVantageAPI.swift
////  stockApp
////
////  Created by David Sally on 4/18/17.
////  Copyright © 2017 David Sally. All rights reserved.
////
//
//import Foundation
//
//enum Market: String {
//	case NSE = "NSE:"
//	case NASDAQ = "NASDAQ:"
//}
//
//enum GoogleFinanceError: Error {
//	case invalidJSONData
//}
//
//struct GoogleFinanceAPI {
//	
//	/// Alpha Vantage
//	private static let baseURLString = "http://finance.google.com/finance/info?client=ig&q="
//	
//	static var googleFinanceStocksURL: URL {
//		print(#function)
//		
//		
//		
////		var components = URLComponents(string: baseURLString)
//		
//		var myURL = baseURLString
//		myURL.append("NSE:BIO")
//		
//		let components = URLComponents(string: myURL)
//		return components!.url!
//
//	}
//	
//	static func stocks(fromJSON data: Data?) -> StocksResult {
//		print(#function)
//	
//		let portfolio = [Stock]()
//
//
//		do {
//			
//			let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
//			
//			if let ticker = json["t"] as? [String] {
//				print("the string is: \(ticker)")
//			}
//			
//			return StocksResult.success(portfolio)
//			
//		} catch let error {
//			return StocksResult.failure(error)
////			return portfolio
//		}
//		
////		return portfolio
//		
////		do {
////			let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [])
////			
////			print("~~test~~")
////
//////			guard
//////				let jsonDictionary = jsonObject as? [AnyHashable: Any],
//////				let stocks = jsonDictionary[""] as? [String: Any] else {
//////					print("*returning nil")
//////					return .failure(GoogleFinanceError.invalidJSONData)
//////			}
//////			
////			return .success(portfolio)
////		} catch let error {
////			print("return failure")
////			return .failure(error)
////		}
//	}
//	
//	private static func stock(fromJSON json: [String: Any]) -> Stock? {
//		guard
//			let ticker = json["t"] as? String,
//			let curVal = json["l"] as? Double else {
//				print("returning nil")
//				return nil
//		}
//		
//		print("ticker: \(ticker)")
//		print("current price: \(curVal)")
//
//		return Stock(ticker: ticker)
////		return Stock(name: "Bio-Rad", ticker: ticker)
////		return Stock(name: "Bio-Rad", ticker: ticker, currentValue: curVal)
//	}
//	
//	private static func googleFinanceURL() -> URL {
////	private static func alphaVantageURL(function: Function, parameters: [String: String]?) -> URL {
//		print(#function)
//		let components = URLComponents(string: baseURLString)!
////		var queryItems = [URLQueryItem]()
//		
////		let baseParams = [
////			"function": function.rawValue,
////			"symbol": "BIO",
////			"interval": "1min",
////			"outputsize": "compact",
////			"apikey": alphaVantageAPIKey
////		]
//		
////		for (key, value) in baseParams {
////			let item = URLQueryItem(name: key, value: value)
////			queryItems.append(item)
////		}
//		
////		if let additionalParams = parameters {
////			for (key, value) in additionalParams {
////				let item = URLQueryItem(name: key, value: value)
////				queryItems.append(item)
////			}
////		}
//		
////		components.queryItems = queryItems
//		
//		return components.url!
//		
//	}
//	
//	
//}
