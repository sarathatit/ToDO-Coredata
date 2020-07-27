//
//  DetailViewController.swift
//  TodoList With CoreData
//
//  Created by sarath kumar on 25/07/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextFiels: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    var workTitle: String = ""
    var workid: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        showDetail()
    }
    
    //Methods:- Custom Methods
    
    private func setupUI(){
        
        navigationItem.largeTitleDisplayMode = .never
        let imageGester = UITapGestureRecognizer(target: self, action: #selector(imageSelectAction))
        imageView.addGestureRecognizer(imageGester)
        imageView.isUserInteractionEnabled = true
        let gesterRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        self.view.addGestureRecognizer(gesterRecognizer)
    }
    
    private func showDetail() {
        
        if workTitle != "" {
            
            self.title = "Work Detail"
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Work")
            let idString = workid?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context?.fetch(fetchRequest)
                
                if results != nil {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            self.titleTextField.text = title
                        }
                        
                        if let author = result.value(forKey: "author") as? String {
                            self.authorTextFiels.text = author
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }
                    }
                }
            } catch {
                print("cannot fetch data")
            }
        } else {
            self.title = "Add Task"
            saveButton.isEnabled = false
            saveButton.isHidden = false
            titleTextField.text = ""
            authorTextFiels.text = ""
        }
    }
    
    @objc func hideKeyBoard(){
           self.view.endEditing(true)
       }

   //MARK:- Action Methods
    
    @IBAction func SaveButtonAction(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newWork = NSEntityDescription.insertNewObject(forEntityName: "Work", into: context)
        
        newWork.setValue(titleTextField.text!, forKey: "title")
        newWork.setValue(authorTextFiels.text!, forKey: "author")
        newWork.setValue(UUID(), forKey: "id")
        let imageData = imageView.image!.jpegData(compressionQuality: 0.5)
        newWork.setValue(imageData, forKey: "image")
        
        do {
            try context.save()
            print("Task saved successfully")
        } catch  {
            print("Task is not saved")
        }
        
        NotificationCenter.default.post(name: Notification.Name("NewTask"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func imageSelectAction() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }

    // MARK:- ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
}
