//
//  ViewController.swift
//  toDoList2
//
//  Created by Gappze on 5.09.2022.
//

import UIKit
import CoreData
import LocalAuthentication

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var control: UISegmentedControl!
    var forwardedTextToFaceRec: String = ""
    var dataArray : [[String]] = []
    var titleArray = [String]()
    var dateArray = [String]()
    var textArray = [String]()
    var faceRecArray = [String]()
    var idArray = [UUID]()
    var categoryArray = [String]()
    var selectedTitle = ""
    var selectedTitleId : UUID?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        control.backgroundColor = .orange
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "TO DO LIST"
       
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()
    }
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        getData()
    }
        @objc func getData() {
        
            titleArray.removeAll(keepingCapacity: false)
            idArray.removeAll(keepingCapacity: false)
            dateArray.removeAll(keepingCapacity: false)
            faceRecArray.removeAll(keepingCapacity: false)
            textArray.removeAll(keepingCapacity: false)
            categoryArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pointer")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                   
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let date = result.value(forKey: "date") as? String {
                        self.dateArray.append(date)
                    }
                    if let text = result.value(forKey: "text") as? String {
                        self.textArray.append(text)
                    }
                    if let faceRecognizer = result.value(forKey: "face") as? String {
                        self.faceRecArray.append(faceRecognizer)
                    }
                    if let category = result.value(forKey: "category") as? String {
                        self.categoryArray.append(category)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                                self.tableView.reloadData()
                            }
            }
                    } catch {
            print("error")
        }
    }
        @objc func addButtonClicked(){
                selectedTitle = ""
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCocoCell", for: indexPath)
           
            cell.textLabel!.font = UIFont(name: "Arial-BoldMT", size: 17)
            cell.textLabel?.text = titleArray[indexPath.row]
            cell.detailTextLabel!.text = dateArray[indexPath.row]
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenTitle = selectedTitle
            destinationVC.chosenTitleId = selectedTitleId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTitle = titleArray[indexPath.row]
        selectedTitleId = idArray[indexPath.row]
        
        if faceRecArray[indexPath.row] != "+" {
            let authContext = LAContext()
            
            var error: NSError?
            
            if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Is it you?") { (success, error) in
                    if success == true {
                        //successful auth
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
                        }
                    } else {
                        print("error")
                    }
                }
            }
        } else {
            self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pointer")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                textArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                faceRecArray.remove(at: indexPath.row)
                                dateArray.remove(at: indexPath.row)
                                categoryArray.remove(at: indexPath.row)
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
                print("error")
            }
        }
    }
}

