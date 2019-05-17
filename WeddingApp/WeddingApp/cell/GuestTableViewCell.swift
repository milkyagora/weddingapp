//
//  GuestTableViewCell.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 17/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit

class GuestTableViewCell: UITableViewCell {

    @IBOutlet var tableNo: UILabel!
    @IBOutlet var guestName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
