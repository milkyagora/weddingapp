//
//  ManageTablesViewController.swift
//  WeddingApp
//
//  Created by Milky Joy Agora on 16/05/2019.
//  Copyright © 2019 Milky Joy Agora. All rights reserved.
//

import UIKit
import CoreData

class ManageTablesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    let nc = NotificationCenter.default
    var tableArray = [NSManagedObject]()
    var selectedTable = NSManagedObject()
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nc.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        fetchData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! TableViewCell
        cell.tableName.text = tableArray[indexPath.row].value(forKeyPath: "name") as? String
        cell.capacity.text = "Capacity: \(tableArray[indexPath.row].value(forKeyPath: "capacity")!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.deleteData(row: indexPath.row)
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            self.isEdit = true
            self.selectedTable = self.tableArray[indexPath.row]
            self.performSegue(withIdentifier: "addTable", sender: self)
        }
        edit.backgroundColor = UIColor.lightGray
        
        return [delete, edit]
    }
    
    
    @objc func refreshTable(notification:NSNotification) {
       fetchData()
    }
    
    @IBAction func addTable(_ sender: Any) {
        self.performSegue(withIdentifier: "addTable", sender: self)
    }
    
    func deleteData(row: Int){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(self.tableArray[row])
        do {
            try context.save()
            self.fetchData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTable"{
            let vc = segue.destination as? AddTableViewController
            vc?.isEdit = isEdit
            isEdit = false
            vc?.table = selectedTable
        }
    }
}
