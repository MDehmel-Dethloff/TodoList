//
//  ViewController.swift
//  TodoList
//
//  Created by Marko Dehmel-Dethloff on 12.03.20.
//  Copyright © 2020 Marko Dehmel-Dethloff. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, cellButtonDelegate {
    
    struct Todo {
        var name: String
        var expireDate: Date
        var isChecked: Bool
    }
    
    var todoArray: [Todo] = []
    var index: Int = 0
    @IBOutlet weak var todoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
        loadTodos()
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTodos()
        todoTableView.reloadData()
    }
    
    // Lädt die gespeicherten Todos in das todoArray
    func loadTodos() {
        
        // Kontext idtentifizieren
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entityName = "Todo"
        
        // Request für Todos stellen
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // Sort the todos by their expiredates
        let sort = NSSortDescriptor(key: "expireDate", ascending: true)
        request.sortDescriptors = [sort]
        // perform a requst
        do {
            let todos = try context.fetch(request)
            
            todoArray.removeAll()
            // lädt die gespeicherten Todos in das todoArray
            for t in todos {
                
                if let todo = t as? NSManagedObject {
                    var loadedTodo: Todo = Todo(name: "", expireDate: Date(), isChecked: false)
                    loadedTodo.name = todo.value(forKey: "name") as! String
                    loadedTodo.expireDate = todo.value(forKey: "expireDate") as! Date
                    loadedTodo.isChecked = todo.value(forKey: "isSelected") as! Bool
                    guard loadedTodo.name == todo.value(forKey: "name") as! String && loadedTodo.expireDate == todo.value(forKey: "expireDate") as! Date else {
                        return
                    }
                    todoArray.append(loadedTodo)
                }
            }
        } catch {
            print("Error ist aufgetreten!")
        }
    }
    // Returns the number of rows for the tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        index = 0
        return todoArray.count
    }
    // returns the content of the rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = todoTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoTableViewCell
        cell.selectionStyle = .none
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = CGColor.init(srgbRed: 0.36, green: 0.28, blue: 0.55, alpha: 1)
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        //cell.nameLabelForCell.text = "\(todoArray[index].name)"
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(todoArray[indexPath.row].name)")
        
        // if Todo is selected
        if todoArray[indexPath.row].isChecked == true {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            cell.nameLabelForCell.attributedText = attributeString
            cell.checkmarkLabel.isSelected = true
        // if Todo is not selected
        } else {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            cell.nameLabelForCell.attributedText = attributeString
            cell.checkmarkLabel.isSelected = false
            
            
        }
        // set the correct image for the cell
        var tempDate = todoArray[indexPath.row].expireDate.distance(to: Date())
        
        if tempDate < 0 {
            tempDate = tempDate * -1
        }
        if tempDate > 172800 {
            cell.imageForCell.image = UIImage(named: "urgent1")
        } else if tempDate > 86400{
            cell.imageForCell.image = UIImage(named: "urgent2")
        } else {
            cell.imageForCell.image = UIImage(named: "urgent3")
        }
        
        index += 1
        return cell
    }
    // returns the hight of the cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            // Kontext idtentifizieren
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let entityName = "Todo"
            
            // Request für Todos stellen
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            do {
                let todos = try context.fetch(request)
                
                // löscht das ausgewählte Todo aus dem Speicher
                var index = 0
                for t in todos {
                    if let todo = t as? NSManagedObject {
                        if todo.value(forKey: "name") as! String == todoArray[indexPath.row].name {
                            print("\(indexPath.row)")
                            context.delete(todo)
                            try context.save()
                        }
                    }
                    index += 1
                }
            } catch {
                print("Error ist aufgetreten!")
            }
            todoArray.remove(at: indexPath.row)
            todoTableView.deleteRows(at: [indexPath], with: .fade)
            viewWillAppear(true)
        }
    }
    // Removes the selected todo
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Kontext idtentifizieren
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entityName = "Todo"
        
        // Request für Todos stellen
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let todos = try context.fetch(request)
            
            // löscht das ausgewählte Todo aus dem Speicher
            var index = 0
            for t in todos {
                if let todo = t as? NSManagedObject {
                    if todo.value(forKey: "name") as! String == todoArray[indexPath.row].name {
                        print("\(todo.value(forKey: "name") as! String) ++ \(todoArray[indexPath.row].name)")
                        context.delete(todo)
                        try context.save()
                    }
                }
                index += 1
            }
        } catch {
            print("Error ist aufgetreten!")
        }
    }*/
    // Changes the image if the todo is selected
    @IBAction func checkAction(_ sender: UIButton) {
    }
    
    // Performs a segue to the create-Todo-Screen
    @IBAction func addNewTodoAxction(_ sender: UIButton) {
        performSegue(withIdentifier: "segue", sender: self)
    }
    // add sender to function-parameter
    func checkTodoAction(at index: IndexPath, _ sender: UIButton) {
        //print(index[1])
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        
        let temp: Int = index[1]
        let boolTemp: Bool = !todoArray[temp].isChecked
        // Kontext identifizieren
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entityName = "Todo"
        
        // Request für Todos stellen
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let todos = try context.fetch(request)
            
            // updatet das ausgewählte Todo aus dem Speicher
            var index = 0
            for t in todos {
                if let todo = t as? NSManagedObject {
                    if todo.value(forKey: "name") as! String == todoArray[temp].name {
                        print(todoArray[temp].name)
                        todo.setValue(boolTemp, forKey: "isSelected")
                        do {
                            try context.save()
                        } catch {
                            print("ein Error ist aufgetreten")
                        }
                    }
                }
                index += 1
            }
        } catch {
            print("Error ist aufgetreten!")
        }
        viewWillAppear(true)
        
    }
}

