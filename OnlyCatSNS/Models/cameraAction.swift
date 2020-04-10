//
//  cameraAction.swift
//  OnlyCatSNS
//
//  Created by Kato Ryota  on 10/04/20.
//  Copyright © 2020 Kato Ryota . All rights reserved.
//

import UIKit
import Photos

class CameraAction:UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            let selectedImage = info[.originalImage] as! UIImage
            UserDefaults.standard.set(selectedImage.jpegData(compressionQuality: 0.1), forKey: "profileImage")
            picker.dismiss(animated: true, completion: nil)
                
        }
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
