//
//  StockBuy.swift
//  stockApp
//
//  Created by David Sally on 4/17/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import Foundation

class StockBuy: NSObject {
	
	/// Basic Properties for a stock buy
	var ticker: String = ""
	var numShares: Double = 0
	var purchasePrice: Double = 0
	var purchaseDate: Date? = nil
	
	/// Computed Properties
	var stockReturnAsDouble: Double = 0
	var stockReturnAsPercent: Double = 0
	var currentValue:Double = 0
	
	/// Fetched Properties
	var currentPrice: Double? {
		didSet {
			currentValue = numShares * currentPrice!
			calcReturn()
		}
	}
	
	/// Initializer
	init(ticker: String, numShares: Double, purchasePrice: Double, purchaseDate: Date?) {
		
		super.init()
		
		self.numShares = numShares
		self.purchasePrice = purchasePrice
		self.purchaseDate = purchaseDate
		self.ticker = ticker
	}
	
	
	/// Funcs
	func calcReturn() {
		print(#function)
		stockReturnAsDouble = currentValue - purchasePrice
		stockReturnAsPercent = (currentValue / purchasePrice) * 100
	}
	
	/// to update the price
	func setPrice(currentPrice: Double) {
		self.currentPrice = currentPrice
	}
	
}
