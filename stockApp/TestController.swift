//
//  FIlterTradesViewController.swift
//  stockApp
//
//  Created by David Sally on 4/23/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class TestController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	
	/// ****************
	/// ** Properties **
	/// ****************
	// MARK: - Properties
	
	let validStocks = StockStore.sharedInstance.validStocks
	
	//	var stockData = [StockList]()
	var filteredData = [StockList]()
	let searchController = UISearchController(searchResultsController: nil)
	
	/// *****************
	/// ***** Funcs *****
	/// *****************
	// MARK: - Funcs
	
	func filterContentForSeachText(searchText: String, scope: String = "All") {
		filteredData = validStocks.filter { stock in
			let categoryMatch = (scope == "All" ? true : (stock.ticker == scope))
			
			/// search for ticker and company name
			let searchValueIsNotEmpty = (categoryMatch && (stock.ticker.lowercased().contains(searchText.lowercased()) || stock.name.lowercased().contains(searchText.lowercased())) )
			
			
			let searchValueIsEmpty = (searchText == "")
			return searchValueIsEmpty ? categoryMatch : searchValueIsNotEmpty
		}
		tableView.reloadData()
	}
	
	/// **************
	/// **** VIEW ****
	/// **************
	// MARK: - View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/// add search bar to navigation bar?
//		self.navigationController?.setNavigationBarHidden(false, animated: false)
//		self.navigationController?.setToolbarHidden(false, animated: false)
		
		
		// format search bar
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.showsCancelButton = false
		searchController.searchBar.becomeFirstResponder()
		
		
		searchController.searchBar.becomeFirstResponder()
	}
	
	/// *****************
	/// *** Delegates ***
	/// *****************
	// MARK: - TableView Delegates
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.isActive && searchController.searchBar.text != "" {
			return filteredData.count
		}
		
		return validStocks.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)
		
		let stock: StockList
		
		if searchController.isActive && searchController.searchBar.text != "" {
			stock = filteredData[row]
		} else {
			stock = validStocks[row]
		}
		
		cell.textLabel?.text = stock.ticker
		cell.detailTextLabel?.text = stock.name
		
		return cell
	}
	
	/// go back when a stock is selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		let ticker = cell?.textLabel?.text
		let name = cell?.detailTextLabel?.text
		print("selecting ticker: \(ticker)")
		
		let previousView = navigationController?.viewControllers[1] as! TradeEditorViewViewController
		
		previousView.name = name?.capitalized
		previousView.ticker = ticker!
		
		/// pop back
		_ = navigationController?.popViewController(animated: true)
	}
	
}

// MARK: - Extensions
/// add ability to do searches
extension TestController: UISearchResultsUpdating {
	public func updateSearchResults(for searchController: UISearchController) {
		filterContentForSeachText(searchText: searchController.searchBar.text!)
	}
}
