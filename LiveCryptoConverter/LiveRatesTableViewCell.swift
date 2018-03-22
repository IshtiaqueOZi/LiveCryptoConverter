//
//  LiveRatesTableViewCell.swift
//  LiveCryptoConverter
//
//  Created by MacBook on 12/5/1396 AP.
//  Copyright © 1396 MacBook. All rights reserved.
//

import UIKit

class LiveRatesTableViewCell: UITableViewCell {

    @IBOutlet weak var cryptoName: UILabel!
    @IBOutlet weak var currencyImage: UIImageView!
    @IBOutlet weak var price: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
