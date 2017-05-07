//
//  SettingsViewController.swift
//  stockApp
//
//  Created by David Sally on 4/10/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

	// MARK: - Funcs
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Actions
	
	/// erase all data from model
	@IBAction func clearButton(_ sender: UIButton) {
		print("clearing all data")
		let mainView = navigationController?.topViewController as? ViewController
		mainView?.stockStore = StockStore()
	}
	
	
	@IBAction func backButton(_ sender: UIBarButtonItem) {
		_ = self.navigationController?.popViewController(animated: true)
//		performSegue(withIdentifier: "settingsToMainSegue", sender: nil)
	}

}
