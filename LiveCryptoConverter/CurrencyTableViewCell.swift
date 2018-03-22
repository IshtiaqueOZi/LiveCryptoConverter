//
//  CurrencyTableViewCell.swift
//  LiveCryptoConverter
//
//  Created by MacBook on 12/4/1396 AP.
//  Copyright © 1396 MacBook. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    
    
    
    @IBOutlet weak var imageOfCurrency: UIImageView!
    @IBOutlet weak var nameOfCurrency: UILabel!
    
    @IBOutlet weak var IdentifierOfCurrency: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
