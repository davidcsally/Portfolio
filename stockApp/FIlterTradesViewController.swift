//
//  FIlterTradesViewController.swift
//  stockApp
//
//  Created by David Sally on 4/23/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class FilterTradesViewController: UITableViewController, UISearchBarDelegate {
	
	/// ****************
	/// ** Properties **
	/// ****************
	// MARK: - Properties
	
	let validStocks = StockStore.sharedInstance.validStocks
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
			let searchValueIsNotEmpty = (categoryMatch && (stock.ticker.uppercased().contains(searchText.uppercased()) || stock.name.uppercased().contains(searchText.uppercased())) )
			
			
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
		
		navigationController?.setNavigationBarHidden(true, animated: true)
		
		// format search bar
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		
		/// anchor the search bar to the top of the table
		tableView.tableHeaderView = searchController.searchBar
		
		/// this prevents the navigation controller from showing up!!
		searchController.hidesNavigationBarDuringPresentation = false
		
		///
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.showsCancelButton = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		/// do all the set up in a separate thread
		DispatchQueue.main.async {
			self.searchController.searchBar.becomeFirstResponder()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		view.endEditing(true)
		
		navigationController?.setNavigationBarHidden(true, animated: true)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	/// *****************
	/// *** Delegates ***
	/// *****************
	// MARK: - TableView Delegates
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.isActive && searchController.searchBar.text != "" {
			return filteredData.count
		}
		
		return 0
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		let ticker = cell?.textLabel?.text
		let name = cell?.detailTextLabel?.text
		print("selecting ticker: \(ticker!)")
		
		let previousView = navigationController?.viewControllers[1] as! TradeEditorViewViewController
		previousView.name = name
		previousView.ticker = ticker!
		previousView.navigationController?.setNavigationBarHidden(true, animated: false)

		/// pop back
		_ = navigationController?.popViewController(animated: true)
	}
	

}

// MARK: - Extensions
/// add ability to do searches
extension FilterTradesViewController: UISearchResultsUpdating {
	public func updateSearchResults(for searchController: UISearchController) {
		filterContentForSeachText(searchText: searchController.searchBar.text!)
	}
}
