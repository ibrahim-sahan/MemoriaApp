//
//  ViewController.swift
//  MemoriaApp
//
//  Created by İbrahim Şahan on 14.03.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dayWordArray = [String]()
    var contentArray = [String]()
    var idArray = [UUID]()
    var calendarArray = [Date]()
    var selectedDaily = ""
    var selectedDailyId : UUID?

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
        
        selectedDaily = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    @objc func getData() {
           
        dayWordArray.removeAll(keepingCapacity: false)
        calendarArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
           
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Daily")
        fetchRequest.returnsObjectsAsFaults = false
           
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let dayWord = result.value(forKey: "dayWordData") as? String {
                        self.dayWordArray.append(dayWord)
                    }
                    
                    if let id = result.value(forKey: "idData") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    if let date = result.value(forKey: "calendarData") as? Date {
                        self.calendarArray.append(date)
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            }
            
        } catch {
               print("error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailsVC" {
            
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenDaily = selectedDaily
            destinationVC.chosenDailyId = selectedDailyId
            
        }
        
    }
    
}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "dd.MM.yyyy"
         let date = calendarArray[indexPath.row]
         let dateString = dateFormatter.string(from: date)
         
         let cell = UITableViewCell()
         cell.textLabel?.text = dayWordArray[indexPath.row] + " - " + dateString
         return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Daily")
            
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "idData = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "idData") as? UUID {
                            
                            
                            if id == idArray[indexPath.row] {
                                
                                context.delete(result)
                                dayWordArray.remove(at: indexPath.row)
                                calendarArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    
                                    try context.save()
                                    
                                } catch {
                                    print("error")
                                }
                                
                                break
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } catch {
                
            }
            
        }
        
    }
    
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedDaily = dayWordArray[indexPath.row]
        selectedDailyId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
}


