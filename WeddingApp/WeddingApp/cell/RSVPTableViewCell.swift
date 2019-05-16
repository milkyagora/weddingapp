//
//  RSVPTableViewCell.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 15/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit

class RSVPTableViewCell: UITableViewCell {

    @IBOutlet var guestLabel: UILabel!
    @IBOutlet var guestStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UITableViewCell {
    
    func showSeparator() {
        DispatchQueue.main.async {
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func hideSeparator() {
        DispatchQueue.main.async {
            self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
        }
    }
}
