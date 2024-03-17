//
//  DetailsVC.swift
//  MemoriaApp
//
//  Created by İbrahim Şahan on 14.03.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var daywordText: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenDaily = ""
    var chosenDailyId : UUID?
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.cornerRadius = 5.0
        textView.textColor = UIColor.lightGray
        
        textView.delegate = self
        
        if chosenDaily != "" {
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Daily")
            
            let idString = chosenDailyId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "idData = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let dayWord = result.value(forKey: "dayWordData") as? String {
                            daywordText.text = dayWord
                        }
                        
                        if let content = result.value(forKey: "contentData") as? String {
                            textView.textColor = UIColor.black
                            textView.isEditable = false
                            textView.text = content
                        }
                        
                        if let date = result.value(forKey: "calendarData") as? Date {
                            dateFormatter.dateFormat = "dd.MM.yyyy"
                            let dateString = dateFormatter.string(from: date)
                            dateText.text = dateString
                        }
                        
                        if let imageData = result.value(forKey: "imageData") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                
                print("error")
                
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.backgroundColor = UIColor.lightGray
            saveButton.isEnabled = false
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newDaily = NSEntityDescription.insertNewObject(forEntityName: "Daily", into: context)
                
        newDaily.setValue(daywordText.text!, forKey: "dayWordData")
        newDaily.setValue(textView.text!, forKey: "contentData")
        newDaily.setValue(UUID(), forKey: "idData")
       
        if let dateString = dateText.text, let date = dateFormatter.date(from: dateString) {
            newDaily.setValue(date, forKey: "calendarData")

        } else {
            let alert = UIAlertController(title: "Error", message: "Please enter the date in 'dd.MM.yyyy' format.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
   
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newDaily.setValue(data, forKey: "imageData")
                
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
            
        if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
        }
    }
}
