//
//  RSVPViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 07/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit

class RSVPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func addGuest(_ sender: Any) {
        self.performSegue(withIdentifier: "addGuest", sender: self)
    }
    
}
