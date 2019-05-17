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
    var filteredTableData = [Table]()
    var totalCount = Int()
    var guestCount = Int()
    let nc = NotificationCenter.default
    var counterBtn = UIButton()
    
    @IBOutlet var tableView: ExpyTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            return controller
        })()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nc.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        fetchData()
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        tableView.deselectRow(at: indexPath, animated: false)
      
        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")
    
        if indexPath.row > 0{
            let guest = (tableArray[indexPath.section] as! Table).guests![indexPath.row-1] as! Guest
            if !guest.hasArrived{
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let context = appDelegate.persistentContainer.viewContext
           
            let alert = UIAlertController(title: "Check-in Guest", message: "Do you want to check-in the guest?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                switch action.style{
                case .default:
                   guest.setValue(true, forKey: "hasArrived")
                   do {
                    try context.save()
                    self.fetchData()
                    tableView.reloadData()
                    self.updateCounter()
                   } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
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
            return (filteredTableData[section].guests?.count)! + 1
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
        }
        
        cell.guestLabel.text = guest.name
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.hideSeparator()
        return cell
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
    }
    
    
    
    
}

extension RSVPViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        var filteredArray = [Table]()
      
        
//        filteredTableData = filteredArray.filter {
//            $0.rangeOfString(resultSearchController.searchBar.t, options: .CaseInsensitiveSearch) != nil
//        }

        for case let i as Table in tableArray{
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let context = appDelegate.persistentContainer.viewContext
            var newTable = Table(context: context)
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
        
        self.tableView.reloadData()
    }
}




