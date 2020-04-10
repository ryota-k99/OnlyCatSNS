//
//  ViewController.swift
//  OnlyCatSNS
//
//  Created by Kato Ryota  on 5/04/20.
//  Copyright © 2020 Kato Ryota . All rights reserved.
//

import UIKit
import Photos

class LoginViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var UserNameTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var userNameAlertLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization{(status)in
            
            switch(status){
            case .authorized:
                print("authorized")
                
            case .denied:
                print("denied")
                           
            case .notDetermined:
                print("notDetermined")
                           
            case .restricted:
                print("restricted")
                
            }
        }
        
        
        
        enterButton.layer.cornerRadius = 30.0
        profileImage.layer.cornerRadius = 50.0
        
        profileImage.isUserInteractionEnabled = true
        userNameAlertLabel.isHidden = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.set(profileImage.image?.jpegData(compressionQuality: 0.1), forKey: "profileImage")

        if UserDefaults.standard.object(forKey: "userName") != nil{
            performSegue(withIdentifier: "toTimeLine", sender: nil)
        }
        
    }

    @IBAction func profileImageTapped(_ sender: Any) {
        
        let generater = UINotificationFeedbackGenerator()
        generater.notificationOccurred(.success)
        
        showAlert()
        let profileImagedata = UserDefaults.standard.object(forKey: "profileImage") as! Data
        profileImage.image = UIImage(data: profileImagedata)
    }
    
    
    @IBAction func enterButtonPressed(_ sender: Any) {
        
        if UserNameTextField.text != nil {
            UserDefaults.standard.set(UserNameTextField.text, forKey: "userName")
            print(UserDefaults.standard.set(UserNameTextField.text, forKey: "userName"))
            performSegue(withIdentifier: "toTimeLine", sender: nil)
        }else{
            userNameAlertLabel.isHidden = false
        }
        
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "選択", message: "どちらを選択しますか？", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.doCamera()
        }
    
        let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.doAlbum()
        }
            
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
            
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
            
        present(alertController,animated: true,completion: nil)
        print("-------------------------------")
        
    }
    
    
    
    func doCamera(){
              
          let sourceType:UIImagePickerController.SourceType = .camera
          if UIImagePickerController.isSourceTypeAvailable(.camera){
              let cameraPicker = UIImagePickerController()
              cameraPicker.allowsEditing = true
              cameraPicker.sourceType = sourceType
              cameraPicker.delegate = self
              present(cameraPicker,animated: true,completion: nil)
                  
          }
      }
    
    func doAlbum(){
               
           let sourceType:UIImagePickerController.SourceType = .photoLibrary
           if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
               let cameraPicker = UIImagePickerController()
               cameraPicker.allowsEditing = true
               cameraPicker.sourceType = sourceType
               cameraPicker.delegate = self
               present(cameraPicker,animated: true,completion: nil)
                   
           }
       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            let selectedImage = info[.originalImage] as! UIImage
            UserDefaults.standard.set(selectedImage.jpegData(compressionQuality: 0.1), forKey: "profileImage")
            
            profileImage.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
            
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
  
    
    
    

}

