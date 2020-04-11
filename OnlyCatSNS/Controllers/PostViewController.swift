//
//  PostViewController.swift
//  OnlyCatSNS
//
//  Created by Kato Ryota  on 8/04/20.
//  Copyright © 2020 Kato Ryota . All rights reserved.
//

import UIKit
import Firebase
import EMAlertController
import VisualRecognition

class PostViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var userNameString = String()
    var profileImageData = Data()
    
    var contentsArray = [ContentsData]()
    
    let visualRecognition = VisualRecognition(version: "2020-04-04", authenticator: WatsonIAMAuthenticator(apiKey: "LfnpGue2rs9EDYEe3g6-RMaRpKgUMYspfpySTm06kHUn"))

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameString = UserDefaults.standard.object(forKey: "userName") as! String
        profileImageData = UserDefaults.standard.object(forKey: "profileImage") as! Data
        userNameLabel.text = userNameString
        profileImage.image = UIImage(data: profileImageData)
        
        visualRecognition.serviceURL = "https://api.kr-seo.visual-recognition.watson.cloud.ibm.com/instances/012b267b-e2da-4ec9-b040-1b5051fdad0e"
    }
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        print("pushButton!!!!!!!!!!!!!!!!!!!!")
        if contentImage.image == nil{
            DispatchQueue.main.async {
                self.emptyAlert()
            }
            return
        }
        
        let timeLineDB = Database.database().reference().child("content").childByAutoId()
        let storage = Storage.storage().reference(forURL: "gs://onlycatsnsapp.appspot.com")
        
        let profileImageKey = timeLineDB.child("profileImage").childByAutoId().key
        let contentImageKey = timeLineDB.child("contentImage").childByAutoId().key
        let profileImageRef = storage.child("\(String(describing: profileImageKey!)).jng")
        print(profileImageRef)
        let contentImageRef = storage.child("\(String(describing: contentImageKey!)).jng")
        
        var profileImageData:Data = Data()
        var contentImageData:Data = Data()
        
        if profileImage.image != nil{
            profileImageData = (profileImage.image?.jpegData(compressionQuality: 0.01)) as! Data
            print(profileImageData)
        }
        
        if contentImage.image != nil{
            contentImageData = (contentImage.image?.jpegData(compressionQuality: 0.01)) as! Data
            print("imageDataIN!!!!!!!!!!!!!!!!!!!!")
        }
        
        let uploadTask = profileImageRef.putData(profileImageData,metadata: nil){
            (metadata,error) in
            if error != nil{
                print("stopTask!!!!!!!!!!!!!!!!!!!")
                return
            }
            print("startTask!!!!!!!!!!!!!!!!!!!")
            let uploadTask = contentImageRef.putData(contentImageData,metadata: nil){
                (metadata,error) in
                if error != nil{
                    return
                }
                
                profileImageRef.downloadURL { (profileImageURL, error) in
                    if profileImageURL != nil{
                        contentImageRef.downloadURL { (contentImageURL, error) in
                            if contentImageURL != nil{
                                 print("URL!!!!!!!!!!!!!!!!!!!!")
                                let resultURL = contentImageURL?.absoluteString
                                self.visualRecognition.classify(url: resultURL) {response, error in
                                    if error != nil{
                                        print(error)
                                    }
                                    
                                    let resultString:String = (response?.result?.images[0].classifiers[0].classes[0].typeHierarchy)!
                                    if resultString.contains("cat") == false{
                                        DispatchQueue.main.async {
                                            self.checkAlert()
                                            print("nekotyekku!!!!!!!!!!!!!!!!!!!!")
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            if self.userNameString != nil && profileImageURL != nil && contentImageURL != nil && self.commentTextField.text != nil{
                                                let timeLineInfo = ["userName":self.userNameString,
                                                                    "profileImageURL":profileImageURL,
                                                                    "contentImageURL":contentImageURL,
                                                                    "comment":self.commentTextField.text,
                                                                    "postDate":ServerValue.timestamp()] as [String:Any]
                                                timeLineDB.updateChildValues(timeLineInfo)
                                                self.navigationController?.popViewController(animated: true)
                                            }else{
                                                DispatchQueue.main.async {
                                                    self.emptyAlert()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        uploadTask.resume()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func albumButtonPressed(_ sender: Any) {
       let sourceType:UIImagePickerController.SourceType = .photoLibrary
       if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
           let cameraPicker = UIImagePickerController()
           cameraPicker.allowsEditing = true
           cameraPicker.sourceType = sourceType
           cameraPicker.delegate = self
           present(cameraPicker,animated: true,completion: nil)
               
       }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
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
            contentImage.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkAlert(){
        let alert = EMAlertController(title: "どうやら猫ではないようです！", message: "猫の画像のみ投稿できます！")
        let action = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func emptyAlert(){
        let alert = EMAlertController(title: "何かが入力されていません！", message: "入力してください。")
        let action = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
}
