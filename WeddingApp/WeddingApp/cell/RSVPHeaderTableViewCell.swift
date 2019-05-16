//
//  RSVPHeaderTableViewCell.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 15/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit
import ExpyTableView

class RSVPHeaderTableViewCell: UITableViewCell, ExpyTableViewHeaderCell {
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        
        switch state {
        case .willExpand:
            hideSeparator()
            arrowUp(animated: !cellReuse)
            
        case .willCollapse:
            arrowDown(animated: !cellReuse)
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            showSeparator()
            print("DID COLLAPSE")
        }
    }
    
    private func arrowDown(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) {
            self.arrowImg.image = #imageLiteral(resourceName: "arrowDownIcon")
        }
    }
    
    private func arrowUp(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) {
            self.arrowImg.image = #imageLiteral(resourceName: "arrowUpIcon")
        }
    }
    

    @IBOutlet var tableCounter: UILabel!
    @IBOutlet var arrowImg: UIImageView!
    @IBOutlet var tableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
