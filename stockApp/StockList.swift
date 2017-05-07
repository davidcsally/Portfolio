//
//  StockList.swift
//  stockApp
//
//  Created by David Sally on 4/23/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

/// used for google finance API
enum market:String {
	case NASDAQ = "NASDAQ"
	case NYSE = "NYSE"
}

class StockList {

	var ticker: String
	var name: String
	var market: market
	
	init(ticker:String, name:String, market:market) {
		self.ticker = ticker
		self.name = name
		self.market = market
	}
	
}
