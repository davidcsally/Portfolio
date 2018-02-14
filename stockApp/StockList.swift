//
//  StockList.swift
//  stockApp
//
//  Created by David Sally on 4/23/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit


class StockList {
	// ******************
	// MARK: - Properties
	// ******************

	var ticker: String
	var name: String
	
	// ************
	// MARK: - Init
	// ************
	
	init(ticker:String, name:String) {
		self.ticker = ticker
		self.name = name
	}
}
