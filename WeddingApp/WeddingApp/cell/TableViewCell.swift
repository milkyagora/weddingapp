//
//  TableViewCell.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 16/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var tableName: UILabel!
    @IBOutlet var capacity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
