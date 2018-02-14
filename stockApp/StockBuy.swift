//
//  StockBuy.swift
//  stockApp
//
//  Created by David Sally on 4/17/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

// This class holds the basic data for each stock purchase, and calculates how much has been made or lost

// TODO - better handling when current price is nil

import Foundation

class StockBuy: NSObject, NSCoding {

	// ******************
	// MARK: - Properties
	// ******************
	
	// Basic Properties for a stock buy
	var ticker: String!
	var numShares: Double!
	var purchasePrice: Double!
	var purchaseDate: Date?
	var currentPrice: Double?
	var holdings: Double?

	// MARK: Computed Properties
	var stockReturnAsDouble: Double {
		return currentValue - purchasePrice * numShares
	}
	
	var stockReturnAsPercent: Double {
		if currentPrice != nil {
			return (currentPrice! - purchasePrice) / purchasePrice
		} else {
			print("error, couldn't calculate currentPrice")
			return -1.1111
		}
	}
	
	var currentValue: Double {
		if currentPrice != nil {
			return numShares * currentPrice!
		} else {
			print("error calculating current value")
			return -1.1111
		}
	}
	

	// ************
	// MARK: - Init
	// ************

	init(ticker: String, numShares: Double, purchasePrice: Double, purchaseDate: Date?) {
		
		super.init()
		
		self.numShares = numShares
		self.purchasePrice = purchasePrice
		self.purchaseDate = purchaseDate
		self.ticker = ticker
	}
	
	// ****************
	// MARK: - NSCoding
	// ****************

	// for NSCoding - encode values to store (saving)
	func encode(with aCoder: NSCoder) {
		print(#function)
		aCoder.encode(ticker, forKey: "ticker")
		aCoder.encode(numShares, forKey: "numShares")
		aCoder.encode(purchasePrice, forKey: "purchasePrice")
		aCoder.encode(currentPrice, forKey: "currentPrice")
		aCoder.encode(purchaseDate, forKey: "purchaseDate")
	}
	
	// NSCoding required init - decodes values (loading)
	required init?(coder aDecoder: NSCoder) {
		ticker = aDecoder.decodeObject(forKey: "ticker") as! String
		numShares = aDecoder.decodeObject(forKey: "numShares") as! Double
		purchasePrice = aDecoder.decodeObject(forKey: "purchasePrice") as! Double
		currentPrice = aDecoder.decodeObject(forKey: "currentPrice") as? Double
		purchaseDate = aDecoder.decodeObject(forKey: "purchaseDate") as? Date
		
		super.init()
	}

}
