//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UITableViewController {
    var data: [Item] = []
    var category: CategoryList?  {
        didSet {
            loadData()
        }
    }
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))

          //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
          //tap.cancelsTouchesInView = false

          view.addGestureRecognizer(tap)
        //navigationController?.navigationBar.prefersLargeTitles = true
        loadData()
        self.refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        }else {
            tableView.addSubview(self.refreshControl!)
        }
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        //        if let typeData = try? Data(contentsOf: dataFilePath!) {
        //            let decoder = PropertyListDecoder()
        //            if let result = try? decoder.decode([Item].self, from: typeData) {
        //                print(result)
        //                data = result
        //            }
        //
        //        }
    }
    
    @objc func refresh(_ sender:AnyObject){
        self.refreshControl?.endRefreshing()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            let item = data[indexPath.row]
            context.delete(item)
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = data[indexPath.row];
        cell.textLabel?.text = item.title
        if item.done == true {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(tableView.cellForRow(at: indexPath)?.textLabel?.text)
        if(data[indexPath.row].done == true) {
            data[indexPath.row].done = false
            data[indexPath.row].setValue(false, forKey: "done")
            //            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else {
            data[indexPath.row].done = true
            data[indexPath.row].setValue(true, forKey: "done")
            //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        let index = IndexPath(row: indexPath.row, section: 0)
        //tableView.reloadData()
        self.saveData()
        tableView.reloadRows(at: [index], with: .right)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        //        let index = IndexPath(row: data.count - 1, section: 0)
        //        tableView.scrollToRow(at: index, at: .bottom, animated: true)
        //        return;
        var textField = UITextField()
        let  alert = UIAlertController(title: "Modal", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "add item", style: .default) { (alertAction) in
            switch alertAction.title {
            case "add item":
                if let title = textField.text, textField.text?.isEmpty == false {
                    let item  = Item(context: self.context)
                    item.title = title
                    item.done = false
                    item.parentCategory = self.category
                    self.data.append(item)
                    self.tableView.reloadData()
                    self.saveData()
                }
                break
            case .none:
                break
            case .some(_):
                break
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "write some text"
            textField = alertTextField
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveData() -> Void {
        //        let encoder = PropertyListEncoder()
        //        do {
        //            let items = try encoder.encode(data)
        //            try items.write(to: dataFilePath!);
        //        }
        //        catch {
        //            print(error)
        //        }
        do {
            try context.save()
        } catch  {
            print("error \(error)")
        }
    }
    
    func loadData() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", category!.name!)
        request.predicate = predicate
        do {
            let result =  try self.context.fetch(request)
            data = result
        }catch  {
            print("error \(error)")
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDescription = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescription]
        do {
            data = try context.fetch(request)
            tableView.reloadData()
        }catch {
            print(error)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            print("reload")
            loadData()
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
}



