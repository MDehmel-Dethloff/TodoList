//
//  CreateTodoViewController.swift
//  TodoList
//
//  Created by Marko Dehmel-Dethloff on 12.03.20.
//  Copyright © 2020 Marko Dehmel-Dethloff. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class CreateTodoViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }
    }
    // Action um ein neues Todo anzulegen
    @IBAction func createTodoAction(_ sender: UIButton) {
        
        if nameTextField.text == "" {
            createAlert(title: "Todoerstellung fehlgeschlagen!", message: "Der Name deines Todos muss aus mindestens einem Zeichen bestehen.")
            return
        }
        saveTodo()
        dismiss(animated: true, completion: nil)
        
    }
    // Action um zum Sartbildschirm zurückzukehren
    @IBAction func goBackAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // Speichert das Todo ab
    func saveTodo() {
        
        // Kontext identifizieren
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entityName = "Todo"
        
        // Neuen Datensatz anlegen
        guard let newEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return
        }
        
        let newTodo = NSManagedObject(entity: newEntity, insertInto: context)
        
        
        let name = nameTextField.text!
        let expireDate = myDatePicker.date
        
        newTodo.setValue(name, forKey: "name")
        newTodo.setValue(expireDate, forKey: "expireDate")
        newTodo.setValue(false, forKey: "isSelected")
        
        // Neues Todo speichern
        do {
            print("hat geklappt")
            try context.save()
        } catch {
            print("Ein Error ist aufgetreten!")
        }
        // Ermittle den Tag für die Usernotification
        let date: String = expireDate.description
        let temp = date.prefix(10)
        let temp2 = String(temp.suffix(2))
        let unDay = Int(temp2)! - 1
        // Ermittle die Stunde für die Usernotification
        let temp3 = date.prefix(13)
        let temp4 = String(temp3.suffix(2))
        let unHour = Int(temp4)! + 1
        // Ermittle die Minuten für die Usernotification
        let temp5 = date.prefix(16)
        let temp6 = String(temp5.suffix(2))
        let unMinute = Int(temp6)!
        // Ermittle den Monat für die Usernotification
        let temp7 = date.prefix(7)
        let temp8 = String(temp7.suffix(2))
        let unMonth = Int(temp8)!
        print("minute: \(unMinute) hour: \(unHour) day: \(unDay) month: \(unMonth)")
        // Rufe die Funktion auf, um die Usernotification für dieses Todo zu erstellen
        createUN(minute: unMinute, hour: unHour, day: unDay, month: unMonth, name: name)
    }
    
    // Erstelle die Usernotification für die Todos
    func createUN(minute: Int, hour: Int, day: Int, month: Int, name: String) {
        // Usernotification: Content, Trigger und Request
        let content = UNMutableNotificationContent()
        content.title = "Vergiss nicht dein Todo zu erledigen!"
        content.body = name
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let randomNumber = String(Int.random(in: 0..<999999))
        let identifier = randomNumber + String(dateComponents.day!) + String(dateComponents.hour!)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    // Alert erstellen ohne Action
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.black
    }
    
}
