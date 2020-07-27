//
//  WorkListTableViewController.swift
//  TodoList With CoreData
//
//  Created by sarath kumar on 25/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import CoreData

class WorkListTableViewController: UITableViewController {
    
    var titleArray = [String]()
    var idArray    = [UUID]()
    var selectedTitle: String = ""
    var selectedId: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getWorkData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(getWorkData), name: Notification.Name(rawValue: "NewTask"), object: nil)
    }
    
    //MARK:- CustomMethods
    
    private func setupUI() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskAction))
    }
    
    @objc private func getWorkData() {
        
        self.titleArray.removeAll(keepingCapacity: false)
        self.idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context?.fetch(fetchRequest)
            
            if results != nil {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                }
                self.tableView.reloadData()
            }
            
        } catch  {
            print("Cannot fetch the data")
        }
        
    }
    
   

    // MARK:- Action Methods
    
    @objc func addTaskAction() {
        selectedTitle = ""
        performSegue(withIdentifier: "DetailVCSegue", sender: nil)
    }
    
    //MARK:- TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.titleArray[indexPath.row]
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = self.idArray[indexPath.row]
        selectedTitle = self.titleArray[indexPath.row]
        performSegue(withIdentifier: "DetailVCSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context?.fetch(fetchRequest)
                
                if results != nil {
                    for result in results as! [NSManagedObject] {
                        if idArray[indexPath.row] == result.value(forKey: "id") as? UUID {
                            context?.delete(result)
                            self.titleArray.remove(at: indexPath.row)
                            self.idArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do {
                                try context?.save()
                            } catch {
                                
                            }
                            
                            break
                        }
                    }
                }
            } catch {
                print("Cannot fetch the result for delete")
            }
            
        }
    }
    
    //MARK: - Seque Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailVCSegue" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.workid = selectedId
            destinationVC.workTitle = selectedTitle
        }
    }
   
}
