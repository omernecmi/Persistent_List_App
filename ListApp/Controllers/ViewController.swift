//
//  ViewController.swift
//  ListApp
//
//  Created by Ömer Necmi ÜSTEL on 24.11.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController
{
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
        
    }
    
    @IBAction func didRemoveBarButtonTapped(_ sendr: UIBarButtonItem)
    {
        presentAlert(title: "Uyarı",
                     message: "Listedeki bütün öğeleri silmek istediğiinze emin misin?",
                     preferredStyle: UIAlertController.Style.alert,
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: false)
        { _ in
            self.data.removeAll()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem)
    {
        presentAddAlert()
    }
    func presentAddAlert()
    {
        presentAlert(title: "Yeni eleman ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: true)
        { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""
            {
            
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                        in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext!)
                
                listItem.setValue(text, forKey: "title")
                try? managedObjectContext?.save()
                
                self.fetch()
            }
            else
            {
                self.presentWarningAlert()
            }
        }
    }
    func presentWarningAlert()
    {
        presentAlert(title: "Uyarı",
                     message: "Liste elemanı boş olamaz.",
                     cancelButtonTitle: "Tamam")
    }
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHandler: ((UIAlertAction)-> Void)? = nil)
    {
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        if defaultButtonTitle != nil
        {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: "Tamam",
                                         style: UIAlertAction.Style.cancel)
        
        if isTextFieldAvailable
        {
            alertController.addTextField()
        }
        
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    func fetch()
    {
        let appDelagate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelagate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:"defaultCell", for:indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.normal,
                                              title: "Sil")
        { _, _, _ in
            self.data.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
        deleteAction.backgroundColor = .systemRed
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle")
        { _,_,_  in
            self.presentAlert(title: "Elemanı Düzenle",
                              message: nil,
                              defaultButtonTitle: "Düzenle",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvailable: true,
                              defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""
                {
                    //self.data[indexPath.row] = text!
                    self.tableView.reloadData()
                }
                else
                {
                    self.presentWarningAlert()
                }
                
            })
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}
