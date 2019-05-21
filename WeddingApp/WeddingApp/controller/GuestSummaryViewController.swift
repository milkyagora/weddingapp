//
//  GuestSummaryViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 17/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit
import CoreData

class GuestSummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var guestArray = [NSManagedObject]()
    var arrivedGuestArray = [Guest]()
    var pendingGuestArray = [Guest]()
    var selectedGuest = NSManagedObject()
    var isEdit = false
    let nc = NotificationCenter.default

    @IBOutlet var segmentedController: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var isArrived = true
   
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        updateCounter()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.reloadData()
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
         nc.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        fetchData()
        updateCounter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshTable(notification:NSNotification) {
        fetchData()
        updateCounter()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell") as! GuestTableViewCell
        
        if isArrived{
            cell.guestName.text = arrivedGuestArray[indexPath.row].name
            cell.tableNo.text = arrivedGuestArray[indexPath.row].table?.name
        }
        else{
            cell.guestName.text = pendingGuestArray[indexPath.row].name
            cell.tableNo.text = pendingGuestArray[indexPath.row].table?.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isArrived{
            return arrivedGuestArray.count
        }
        else{
            return pendingGuestArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.deleteData(row: indexPath.row)
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.isEdit = true
            if self.isArrived{
                 self.selectedGuest = self.arrivedGuestArray[indexPath.row]
            }
            else{
                 self.selectedGuest = self.pendingGuestArray[indexPath.row]
            }
           
            self.performSegue(withIdentifier: "editGuest", sender: self)
        }
        edit.backgroundColor = UIColor.lightGray
        
        return [delete, edit]
    }
    
    func deleteData(row: Int){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        if isArrived{
             context.delete(self.arrivedGuestArray[row])
        }
        
        else{
            context.delete(self.pendingGuestArray[row])
        }
       
        do {
            try context.save()
            self.fetchData()
            updateCounter()
            self.nc.post(name: NSNotification.Name(rawValue: "refreshTable"), object: true)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func changeSegment(_ sender: Any) {
        switch segmentedController.selectedSegmentIndex
        {
        case 0:
            isArrived = true
            tableView.reloadData()
            updateCounter()
        case 1:
           isArrived = false
            tableView.reloadData()
            updateCounter()
        default:
            break;
        }
    }
    
    func updateCounter(){
        if isArrived{
            self.title = "\(arrivedGuestArray.count)/\(guestArray.count)"
        }
        else{
             self.title = "\(pendingGuestArray.count)/\(guestArray.count)"
        }
    }
    
    func fetchData(){
        arrivedGuestArray.removeAll()
        pendingGuestArray.removeAll()
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
       
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Guest")
        
        do {
            guestArray = try managedContext.fetch(fetchRequest)
            
            for case let i as Guest in guestArray{
                if (i.hasArrived){
                    arrivedGuestArray.append(i)
                }
                else{
                    pendingGuestArray.append(i)
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "editGuest"{
            let vc = segue.destination as? AddGuestViewController
            vc?.isEdit = isEdit
            vc?.guest = selectedGuest
        }
    }
    
}
