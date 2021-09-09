//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by thinh on 12/2/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import  CoreData
class CategoryViewControllerTableViewController: UITableViewController {
    var dataCategory: [CategoryList] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.navigationBar.prefersLargeTitles = true
        loadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataCategory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let item = dataCategory[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ViewController {
            if let index = tableView.indexPathForSelectedRow {
                destinationVC.category = dataCategory[index.row]
            }
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func addButtonPressed(_ sender: Any) {
        //let textField = UITextField()
        //var field = UITextField()
        let alert = UIAlertController(title: "Add catogry", message: "type category", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if action.title == "Add Category" {
                let field = alert.textFields?.first!
                if let text = field?.text, field?.text?.isEmpty == false {
                    let category = CategoryList(context: self.context)
                    category.name = text
                    self.dataCategory.append(category)
                    self.tableView.reloadData()
                    self.saveData()
                }
                //print(alert.textFields?.first?.text)
                //                print(field.text)
            }
        }
        alert.addAction(action)
        alert.addTextField(configurationHandler: nil)
        //        alert.addTextField { textField in
        //            //field = textField
        //            //print(textField.text)
        //        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadData() {
        let request: NSFetchRequest<CategoryList> = CategoryList.fetchRequest()
        do {
            dataCategory = try context.fetch(request)
        } catch {
            print("error \(error)")
        }
    }
    
    func  saveData() {
        do {
            try context.save()
        } catch {
            print("save error \(error)")
        }
    }
}
