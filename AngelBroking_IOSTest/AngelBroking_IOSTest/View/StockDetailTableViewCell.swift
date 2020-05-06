//
//  StockDetailTableViewCell.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 17/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//

import UIKit

class StockDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var stockImage: UIImageView!
    @IBOutlet weak var stockDisplayName: UILabel!
    @IBOutlet weak var myCheckBox: CheckBox!
    
    @IBOutlet weak var myTableActivity: UIActivityIndicatorView!
    @IBOutlet weak var stockUserName: UILabel!
    
    
    override func awakeFromNib() {
           super.awakeFromNib()
           myTableActivity.hidesWhenStopped = true
           
       }
     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
        myCheckBox.style = .tick
     }

}
