//
//  AddGuestViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 07/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit
import iOSDropDown
import CoreData

class AddGuestViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var guestName: UITextField!
    @IBOutlet var tableDropdown: DropDown!
    @IBOutlet weak var saveBtn: UIButton!
    var tableArray = [NSManagedObject]()
     var dropdownData = [String]()
    var dropdownId = [Int]()
    var selectedTable = Table()
    let nc = NotificationCenter.default
    var isEdit = false
    var guest = NSManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.layer.cornerRadius = 5
//        let dismissViewTap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
//        view.addGestureRecognizer(dismissViewTap)
        
        updateDropdownData()
        tableDropdown.delegate = self
        
        if isEdit{
            let g = guest as! Guest
            guestName.text = g.name
            tableDropdown.text = g.table?.name
            self.selectedTable = g.table!
        }
        
        
        tableDropdown.rowHeight = 35
        tableDropdown.listHeight = 400
        tableDropdown.selectedRowColor = UIColor.lightGray
        tableDropdown.didSelect{(selectedText , index ,id) in
            self.selectedTable = self.tableArray[id] as! Table
            
        }
        

    }
    
    func updateDropdownData(){
        dropdownData.removeAll()
        fetchData()
        for case let i as Table in tableArray{
            dropdownData.append("\(i.name!) - \(i.guests!.count)/\(i.capacity)")
            dropdownId.append(tableArray.index(of: i)!)
        }
        
        tableDropdown.optionArray = dropdownData
        tableDropdown.optionIds = dropdownId
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tableDropdown{
            return false
        }
        else{
            return true
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Table")
        
        do {
            tableArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    @objc private func dismissView() {
        view.endEditing(true)
    }

    func addGuest(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        if isEdit{
            guest.setValue(guestName.text, forKey: "name")
            selectedTable.addToGuests(guest as! Guest)
            
        }
        else{
        
            let guest = Guest(context: context)
            guest.name = guestName.text
            guest.hasArrived = false
            selectedTable.addToGuests(guest)
        }

        do {
            try context.save()
            self.nc.post(name: NSNotification.Name(rawValue: "refreshTable"), object: true)
            if isEdit{
                            _ = navigationController?.popViewController(animated: true)
            }
            else{
                guestName.text = ""
                tableDropdown.text = ""
                updateDropdownData()
            }

            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func saveGuest(_ sender: Any) {
        addGuest()
    }
    
    
}
