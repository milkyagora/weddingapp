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

class RSVPViewController:  UIViewController, ExpyTableViewDelegate, UISearchControllerDelegate {
    
    var resultSearchController = UISearchController()
    var tableArray = [NSManagedObject]()
    var filteredTableData = [NSManagedObject]()
    var totalCount = Int()
    var guestCount = Int()
    let nc = NotificationCenter.default
    var counterBtn = UIButton()
    var isSearchBarUsed = false
    
    
    @IBOutlet var tableView: ExpyTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        fetchData()
        
        
        counterBtn =  UIButton(type: .custom)
        counterBtn.setTitleColor(UIColor.black, for: .normal )
        counterBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        counterBtn.addTarget(self, action: #selector(clickCounterButton), for: .touchUpInside)
        navigationItem.titleView = counterBtn
        updateCounter()
        
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            controller.delegate = self
            
            return controller
        })()
        resultSearchController.delegate = self
        tableView.reloadData()
        
        
        if self.tableView.numberOfSections > 0 {
            
            for i in 0...self.tableView.numberOfSections-1{
                self.tableView.expand(i)
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nc.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        //        fetchData()
        //        tableView.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        context?.reset()
        self.fetchData()
        updateCounter()
    }
    
    
    
    @IBAction func addGuest(_ sender: Any) {
        self.performSegue(withIdentifier: "addGuest", sender: self)
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

//MARK: ExpyTableViewDataSourceMethods
extension RSVPViewController: ExpyTableViewDataSource {
    
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! RSVPHeaderTableViewCell
        var rowTable = Table()
        if(resultSearchController.isActive){
            rowTable = filteredTableData[section] as! Table
        }
        else{
            rowTable = tableArray[section] as! Table
        }
        
        cell.tableLabel.text = rowTable.name
        cell.tableCounter.text = "\(rowTable.guests!.count)/\(rowTable.capacity)"
        cell.layoutMargins = UIEdgeInsets.zero
        cell.showSeparator()
        return cell
    }
    
}

extension RSVPViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        
        var context =
            appDelegate?.persistentContainer.viewContext
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")
        
        if indexPath.row > 0{
            var guest = Guest()
            let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            childContext.parent = context
            var guestCopy = Guest(context: childContext)
            if resultSearchController.isActive{
                guest = (filteredTableData[indexPath.section] as! Table).guests![indexPath.row-1] as! Guest
            }
            else{
                guest = (tableArray[indexPath.section] as! Table).guests![indexPath.row-1] as! Guest
            }
            
            if !guest.hasArrived{
                
                let alert = UIAlertController(title: "Check-in Guest", message: "Do you want to check-in the guest?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        if self.resultSearchController.isActive{
                            
                            guestCopy.setValue(guest.name, forKey: "name")
                            guestCopy.setValue(true, forKey: "hasArrived")
                            guestCopy.table = childContext.object(with: (guest.table?.objectID)!) as? Table
                            context?.reset()
                            
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Guest")
                            var resultsArr:[Guest] = []
                            do {
                                resultsArr = try (context!.fetch(fetchRequest) as! [Guest])
                            } catch {
                                let fetchError = error as NSError
                                print(fetchError)
                            }
                            
                            if resultsArr.count > 0 {
                                for x in resultsArr {
                                    if x.name == guestCopy.name &&  x.table?.name == guestCopy.table?.name{
                                        context?.delete(x)
                                    }
                                }
                            }
                            

                            
                            
                            
                        }
                        else{
                            guest.setValue(true, forKey: "hasArrived")
                        }
                        
                        
                        
                            do {
                                if self.resultSearchController.isActive{
                                    //context?.delete((context?.object(with: guestCopy.objectID))!)
                                   
                                    try childContext.save()
                                    try context?.save()
                                    
                                }
                                else{
                                    try context?.save()
                                }
                                
                                
                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                            }
                           
                        
                        
                       
                            if self.resultSearchController.isActive{
                                self.fetchData()
                                self.updateSearchResults(for: self.resultSearchController)
                            }
                            else{
                                
                                self.fetchData()
                                tableView.reloadData()
                                self.updateCounter()
                            }
                        
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//MARK: UITableView Data Source Methods
extension RSVPViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        }
        else{
            return tableArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return ((filteredTableData[section] as! Table).guests?.count)! + 1
        }
        else{
            return ((tableArray[section] as! Table).guests?.count)! + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell") as! RSVPTableViewCell
        var table = Table()
        if resultSearchController.isActive{
            table = filteredTableData[indexPath.section] as! Table
        }
        else{
            table = tableArray[indexPath.section] as! Table
        }
        
        let guests = table.guests?.array as! NSArray
        let guest = guests[indexPath.row - 1] as! Guest
        
        if guest.hasArrived{
            cell.guestStatus.text = "Arrived"
            cell.guestStatus.textColor = hexStringToUIColor(hex: "77dd90")
        }
        else{
            cell.guestStatus.text = "Pending"
            cell.guestStatus.textColor = UIColor.black
        }
        
        cell.guestLabel.text = guest.name
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.hideSeparator()
        return cell
    }
    
    func fetchData(){
        tableArray = [NSManagedObject]()
        var appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        
        var context =
            appDelegate?.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Table")
        
        do {
            tableArray = (try context?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc func refreshTable(notification:NSNotification) {
        fetchData()
        tableView.reloadData()
        updateCounter()
    }
    
    @objc func clickCounterButton() {
        self.performSegue(withIdentifier: "guestSummary", sender: self)
    }
    
    func updateCounter(){
        totalCount = 0
        guestCount = 0
        for case let i as Table in tableArray{
            totalCount += (i.guests?.count)!
            
            for case let j as Guest in i.guests!{
                if (j.hasArrived){
                    guestCount += 1
                }
            }
        }
        
        counterBtn.setTitle("\(guestCount)/\(totalCount)", for: .normal)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "addGuest"{
            if isSearchBarUsed{
                //(UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext.reset()
            }
        }
    }
    
    
    
    
}

extension RSVPViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        isSearchBarUsed = true
        filteredTableData.removeAll(keepingCapacity: false)
        var appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        
        var context =
            appDelegate?.persistentContainer.viewContext
        
        var copy = [NSManagedObject]()
        for i in tableArray{
            copy.append(i.clone(in: context, exludeEntities: nil)!)
        }
        
        
        for case let i as Table in copy{
            
            let newTable = Table(context: context!)
            newTable.setValue(i.name, forKeyPath: "name")
            newTable.setValue(i.capacity, forKeyPath: "capacity")
            for case let g as Guest in i.guests!{
                if (g.name?.range(of: resultSearchController.searchBar.text!, options: .caseInsensitive) != nil){
                    newTable.addToGuests(g)
                }
                
            }
            if (newTable.guests?.count)! > 0{
                filteredTableData.append(newTable)
            }
        
            
        }
        
        
        
        
        
        
        
        if resultSearchController.searchBar.text == ""{
            filteredTableData = tableArray
        }
        
        
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.tableView.numberOfSections > 0{
                for i in 0...self.tableView.numberOfSections-1{
                    self.tableView.expand(i)
                }
            }
            group.leave()
        }
        
        // does not wait. But the code in notify() gets run
        // after enter() and leave() calls are balanced
        
        group.notify(queue: .main) {
            
        }
        //        DispatchQueue.main.async {
        //            if (context?.hasChanges)!{
        //              context?.reset()
        //                self.fetchData()
        //            }
        //            else{
        //                print("wala")
        //            }
        //        }
        
        
    }
    
    
}

extension UIViewController {
    
    func showAlert(message: String){
        
        // create the alert
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension NSManagedObject {
    func clone(in context: NSManagedObjectContext?, exludeEntities namesOfEntitiesToExclude: [Any]?) -> NSManagedObject? {
        return clone(in: context, withCopiedCache: [:], exludeEntities: namesOfEntitiesToExclude)
    }
    
    
    func clone(in context: NSManagedObjectContext?, withCopiedCache alreadyCopied: [AnyHashable : Any]?, exludeEntities namesOfEntitiesToExclude: [Any]?) -> NSManagedObject? {
        var alreadyCopied = alreadyCopied
        let entityName = entity.name
        
        if (namesOfEntitiesToExclude as NSArray?)?.contains(entityName ?? "") ?? false {
            return nil
        }
        
        var cloned = alreadyCopied?[objectID] as? NSManagedObject
        if cloned != nil {
            return cloned
        }
        
        //create new object in data store
        cloned = NSEntityDescription.insertNewObject(forEntityName: entityName!, into: context!)
        alreadyCopied![objectID] = cloned
        
        //loop through all attributes and assign then to the clone
        let attributes = NSEntityDescription.entity(forEntityName: entityName!, in: context!)?.attributesByName
        
        for attr in attributes ?? [:] {
            cloned?.setValue(self.value(forKey: attr.key), forKey: attr.key)
        }
        
        //Loop through all relationships, and clone them.
        var relationships = NSEntityDescription.entity(forEntityName: entityName!, in: context!)?.relationshipsByName
        
        for relName in (relationships?.keys)! {
            
            let rel = relationships?[relName]
            if (rel?.isToMany)! {
                //get a set of all objects in the relationship
                if (rel?.isOrdered)!{
                    let sourceArray = Array(mutableOrderedSetValue(forKey: relName))
                    let clonedSet = cloned?.mutableOrderedSetValue(forKey: relName)
                    for relatedObject in sourceArray as? [NSManagedObject] ?? [] {
                        let clonedRelatedObject: NSManagedObject? = relatedObject.clone(in: context, withCopiedCache: alreadyCopied, exludeEntities: namesOfEntitiesToExclude)
                        clonedSet?.add(clonedRelatedObject)
                    }
                }
                else{
                    let sourceArray = Array(mutableSetValue(forKey: relName))
                    let clonedSet = cloned?.mutableSetValue(forKey: relName)
                    for relatedObject in sourceArray as? [NSManagedObject] ?? [] {
                        let clonedRelatedObject: NSManagedObject? = relatedObject.clone(in: context, withCopiedCache: alreadyCopied, exludeEntities: namesOfEntitiesToExclude)
                        clonedSet?.add(clonedRelatedObject)
                    }
                }
                
                
                
            } else {
                cloned?.setValue(self.value(forKey: relName), forKeyPath: relName)
                //cloned![relName] = self[relName]
            }
        }
        return cloned
    }
}




