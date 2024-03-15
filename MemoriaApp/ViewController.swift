//
//  ViewController.swift
//  MemoriaApp
//
//  Created by İbrahim Şahan on 14.03.2024.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var dayWordArray = [String]()
    var contentArray = [String]()
    var idArray = [UUID]()
    var dateArray = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }

    @objc func addButtonClicked() {
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    @objc func getData() {
           
           
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
           
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Daily")
        fetchRequest.returnsObjectsAsFaults = false
           
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let dayWord = result.value(forKey: "dayWord") as? String {
                    self.dayWordArray.append(dayWord)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
                
                if let date = result.value(forKey: "date") as? Date {
                    self.dateArray.append(date)
                }
                
                self.tableView.reloadData()
                
            }
               
               

        } catch {
               print("error")
        }
           
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dayWordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let date = dateArray[indexPath.row]
        let dateString = dateFormatter.string(from: date)
        let cell = UITableViewCell()
        cell.textLabel?.text = dayWordArray[indexPath.row] + " - " + dateString
        return cell
        
    }
}

