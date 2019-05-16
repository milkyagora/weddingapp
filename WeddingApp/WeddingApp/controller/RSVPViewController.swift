//
//  RSVPViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 07/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit
import ExpyTableView
import CoreData

class RSVPViewController:  UIViewController, ExpyTableViewDelegate {
    
    var resultSearchController = UISearchController()
    var tableArray = [NSManagedObject]()
    var filteredTableData = [String]()
    
    @IBOutlet var tableView: ExpyTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Table")
        
        //3
        do {
            tableArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    
    func save(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        let table1 = Table(context: context)
        table1.name = "Table 1"
        table1.capacity = 10
        
        let guest1 = Guest(context: context)
        guest1.name = "Milky Joy Agora"
        guest1.hasArrived = false
        guest1.table = table1
        table1.addToGuests(guest1)
        
        let guest2 = Guest(context: context)
        guest2.name = "Shakira"
        guest2.hasArrived = true
        table1.addToGuests(guest2)
        
        do {
            try context.save()
            //            tableArray.append(table)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addGuest(_ sender: Any) {
        self.performSegue(withIdentifier: "addGuest", sender: self)
    }
    
}

//MARK: ExpyTableViewDataSourceMethods
extension RSVPViewController: ExpyTableViewDataSource {
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! RSVPHeaderTableViewCell
        cell.tableLabel.text = tableArray[section].value(forKeyPath: "name") as? String
        cell.tableCounter.text = "0/\(tableArray[section].value(forKeyPath: "capacity")!)"
        cell.layoutMargins = UIEdgeInsets.zero
        cell.showSeparator()
        return cell
    }
    
}

extension RSVPViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
      
        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")
        
        if indexPath.row > 0{
            let alert = UIAlertController(title: "Check-in Guest", message: "Do you want to check-in the guest?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//MARK: UITableView Data Source Methods
extension RSVPViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        }
        else{
            return ((tableArray[section] as! Table).guests?.count)! + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell") as! RSVPTableViewCell
        let table = tableArray[indexPath.section] as! Table
        let guests = table.guests?.array as! NSArray
        let guest = guests[indexPath.row - 1] as! Guest
        
        if guest.hasArrived{
            cell.guestStatus.text = "Arrived"
        }
        else{
            cell.guestStatus.text = "Pending"
        }
        
        cell.guestLabel.text = guest.name
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.hideSeparator()
        return cell
    }
    
}

extension RSVPViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}



