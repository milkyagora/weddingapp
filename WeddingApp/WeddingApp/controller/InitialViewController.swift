//
//  InitialViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 07/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    
    @IBOutlet weak var rsvpBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var manageTablesBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        rsvpBtn.layer.cornerRadius = 5
        addBtn.layer.cornerRadius = 5
        manageTablesBtn.layer.cornerRadius = 5
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //(UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.reset()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func rsvp(_ sender: Any) {
        self.performSegue(withIdentifier: "goToRSVP", sender: self)
    }
    
    @IBAction func addTable(_ sender: Any) {
        self.performSegue(withIdentifier: "manageTables", sender: self)
    }
    
    @IBAction func addGuest(_ sender: Any) {
        self.performSegue(withIdentifier: "goToAddGuest", sender: self)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

