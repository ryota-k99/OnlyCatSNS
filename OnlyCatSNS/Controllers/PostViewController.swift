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
    
    
    let visualRecognition = VisualRecognition(version: "2020-04-04", authenticator: WatsonIAMAuthenticator(apiKey: "apiKey"))
    
    let screenSize = UIScreen.main.bounds.size
    var contentCount = Int()
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameString = UserDefaults.standard.object(forKey: "userName") as! String
        profileImageData = UserDefaults.standard.object(forKey: "profileImage") as! Data
        userNameLabel.text = userNameString
        profileImage.image = UIImage(data: profileImageData)
        
        visualRecognition.serviceURL = "URL"
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notificaiton: NSNotification){
        let keyboardHeight = ((notificaiton.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any ) as AnyObject).cgRectValue.height
        
        commentTextField.frame.origin.y = screenSize.height - keyboardHeight - commentTextField.frame.height
    }
    
    @objc func keyboardWillHide(_ notificaiton: NSNotification){
        
        commentTextField.frame.origin.y = screenSize.height - commentTextField.frame.height - containerView.frame.height
        guard let rect = ((notificaiton.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as Any ) as AnyObject).cgRectValue,
            let duration = notificaiton.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else{return}
        
        UIView.animate(withDuration: duration){
            let transfrom = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transfrom
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        if contentImage.image == nil{
            DispatchQueue.main.async {
                self.emptyAlert()
            }
            return
        }
        
        let timeLineDB = Database.database().reference().child("content").childByAutoId()
        let storage = Storage.storage().reference(forURL: "URL")
        
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
        }
        
        let uploadTask = profileImageRef.putData(profileImageData,metadata: nil){
            (metadata,error) in
            if error != nil{
                print("stopTask!")
                return
            }
            print("startTask!!")
            let uploadTask = contentImageRef.putData(contentImageData,metadata: nil){
                (metadata,error) in
                if error != nil{
                    return
                }
                
                profileImageRef.downloadURL { (profileImageURL, error) in
                    if profileImageURL != nil{
                        contentImageRef.downloadURL { (contentImageURL, error) in
                            if contentImageURL != nil{
                                let resultURL = contentImageURL?.absoluteString
                                self.visualRecognition.classify(url: resultURL) {response, error in
                                    if error != nil{
                                        print(error)
                                    }
                                    
                                    let resultString:String = (response?.result?.images[0].classifiers[0].classes[0].typeHierarchy)!
                                    if resultString.contains("cat") == false{
                                        DispatchQueue.main.async {
                                            self.checkAlert()
                                            print("checkWhetherCatOrNot")
                                        }
                                    }else{
                                        DispatchQueue.main.async {
                                            if self.userNameString != nil && profileImageURL?.absoluteString != nil && contentImageURL?.absoluteString != nil && self.commentTextField.text?.isEmpty != true{
                                                let timeLineInfo = ["userName":self.userNameString as Any,
                                                                    "profileImageURL":profileImageURL?.absoluteString as Any,
                                                                    "contentImageURL":contentImageURL?.absoluteString as Any,
                                                                    "comment":self.commentTextField.text as Any,
                                                                    "postDate":ServerValue.timestamp(),
                                                                    "contentCount":self.contentCount] as [String:Any]
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
        let alert = EMAlertController(title: "猫ではありません。", message: "猫の画像を選択してください。")
        let action = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func emptyAlert(){
        let alert = EMAlertController(title: "空欄があります。", message: "入力してください。")
        let action = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           commentTextField.resignFirstResponder()
       }
    
    
    
}
