//
//  TextFieldTableCell.swift
//  stockApp
//
//  Created by David Sally on 4/24/17.
//  Copyright © 2017 David Sally. All rights reserved.
//

import UIKit

class TextFieldTableCell: UITableViewCell {
	var purchasePrice: Double = 0
	var numShares: Double = 0

	// MARK : - Outlets
	@IBOutlet var textField: UITextField!

	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		/// TODO
		
		let allowedCharacters = NSCharacterSet.decimalDigits
		let decimalSeparator = Locale.current.decimalSeparator
		let isDecimalPresent = checkForDecimalSeparator(textField: textField)
		
		/// only update the text field if it is a number, OR the only decimal selector
		for char in string.unicodeScalars {
			if (allowedCharacters.contains(char) || (string == decimalSeparator && isDecimalPresent == false)) {
//				updateTextFieldValues()
//				print("numShares: \(numShares)")
//				print("purchasePrice: \(purchasePrice)")
				
				return true
			}
				
			else {
				return false
			}
		}
		
		print("Error, weird character detected")
		return true
	}
	
	/// input validation to ignore multiple decimal points
	func checkForDecimalSeparator(textField:UITextField) -> Bool {
		
		let decimalSeparator = Locale.current.decimalSeparator
		
		if let currentText = textField.text {
			for i in currentText.characters.indices[currentText.startIndex..<currentText.endIndex] {
				if String(currentText[i]) == decimalSeparator {
					return true
				}
			}
		}
		
		/// return false if no decimal separator was found
		return false
	}
	
//	func updateTextFieldValues() {
//		print(#function)
//		
//		let indexPath = tableView.indexPathForSelectedRow!
//		let row = indexPath.row
//		
//		let selectedCell = self.createTable.cellForRow(at: indexPath) as! TextFieldTableCell
//		
//		switch row {
//		case 1:
//			numShares = Double(selectedCell.textField.text!)!
//		case 2:
//			purchasePrice = Double(selectedCell.textField.text!)!
//		default:
//			print("ERROR")
//		}
//	}

}
