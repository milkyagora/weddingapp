//
//  AddTableViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 16/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit
import CoreData

class AddTableViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var tableName: UITextField!
    @IBOutlet var capacity: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    let nc = NotificationCenter.default
    var isEdit = false
    var table = NSManagedObject()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        saveBtn.layer.cornerRadius = 5
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        mainView.layer.cornerRadius = 15
        let dismissViewTap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(dismissViewTap)
        
        if isEdit{
            let t = table as! Table
            tableName.text = t.name
            capacity.text = "\(t.capacity)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveTable(_ sender: Any) {
        
        if (tableName.text?.isEmpty)! || (capacity.text?.isEmpty)! {
            showAlert(message: "Incomplete Details")
        } else {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let context = appDelegate.persistentContainer.viewContext
            
            if isEdit{
                table.setValue(tableName.text, forKey: "name")
                table.setValue(Int32(capacity.text!), forKey: "capacity")
            }
            else{
                let table = Table(context: context)
                table.name = tableName.text
                table.capacity = Int32(capacity.text!)!
            }
            do {
                try context.save()
                self.nc.post(name: NSNotification.Name(rawValue: "refreshTable"), object: true)
                dismissView()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        
        
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
