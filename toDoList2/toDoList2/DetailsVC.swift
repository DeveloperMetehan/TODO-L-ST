//
//  DetailsVC.swift
//  toDoList2
//
//  Created by Gappze on 5.09.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate {
    
    var categoryNames = ["Market", "Office", "Family", "Love", "School"]
    var chosenTitle = ""
    var chosenTitleId : UUID?
    var textForFaceRecognizer : String = ""
    let datePicker = UIDatePicker()
    let categoryPicker  = UIPickerView()
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var timeTextFiel: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        createDatePicker()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        categoryTextField.inputView = categoryPicker
        categoryTextField.textAlignment = .center
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        if chosenTitle != "" {
            //core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pointer")
           
            let idString = chosenTitleId?.uuidString
            
            fetchrequest.predicate = NSPredicate(format: "id = %@", idString!)
            do {
         let results = try  context.fetch(fetchrequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        if let text = result.value(forKey: "text") as? String {
                            textTextField.text = text
                            }
                        if let date = result.value(forKey: "date") as? String {
                            timeTextFiel.text = date
                            }
                        if let title = result.value(forKey: "title") as? String {
                            titleTextField.text = title
                            }
                        if let facereg = result.value(forKey: "face") as? String {
                            textForFaceRecognizer = facereg
                            button.titleLabel?.text = textForFaceRecognizer
                        }
                        if let category = result.value(forKey: "category") as? String {
                            categoryTextField.text = category
                        }
                    }
            }
            }
            catch {
            }
            fetchrequest.returnsObjectsAsFaults = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if titleTextField.text! == "" {
            button.setTitle("+", for: .normal)
        
        } else {
        button.setTitle(textForFaceRecognizer, for: .normal)
    }
}
    @IBAction func buttonClickedForPrivacy(_ sender: UIButton) {
        if button.isTouchInside == true {
            button.setTitle("✓", for: .normal)
        }
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTexting = NSEntityDescription.insertNewObject(forEntityName: "Pointer", into: context)
     
        //Attiributes
        newTexting.setValue(titleTextField.text!, forKey: "title")
        newTexting.setValue(textTextField.text, forKey: "text")
        newTexting.setValue(timeTextFiel.text, forKey: "date")
        newTexting.setValue(button.titleLabel?.text, forKey: "face")
        newTexting.setValue(categoryTextField.text!, forKey: "category")
        newTexting.setValue(UUID(), forKey: "id")
        do {
            try context.save()
            print("SUCCESS")
        }
        catch {
            print("ERROR")
        }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
     func createToolbar() -> UIToolbar {
         let toolbar = UIToolbar()
         toolbar.sizeToFit()
         
         let donebtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
         toolbar.setItems([donebtn], animated: true)
         
         return toolbar
     }
     func createDatePicker() {
         datePicker.preferredDatePickerStyle = .wheels
         datePicker.datePickerMode = .date
         timeTextFiel.textAlignment = .center
         timeTextFiel.inputView = datePicker
         timeTextFiel.inputAccessoryView = createToolbar()
 }
     @objc func donePressed() {
         let dateFormatter = DateFormatter()
         dateFormatter.dateStyle = .medium
         dateFormatter.timeStyle = .none
         
         self.timeTextFiel.text = dateFormatter.string(from: datePicker.date)
         self.view.endEditing(true)
     }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
       }
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return categoryNames.count
       }
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          let row = categoryNames[row]
          return row
       }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryNames[row]
        categoryTextField.resignFirstResponder()
    }
}
    

