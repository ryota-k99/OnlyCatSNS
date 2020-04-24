//
//  ContentsData.swift
//  OnlyCatSNS
//
//  Created by Kato Ryota  on 11/04/20.
//  Copyright © 2020 Kato Ryota . All rights reserved.
//

import Foundation
class ContentsData{
    
    var userNameString:String = ""
    var profileImageString:String = ""
    var contentImageString:String = ""
    var commentString:String = ""
    var postDataString:String = ""
    
    init(userNameString:String,profileImageString:String,contentImageString:String,commentString:String,postDataString:String) {
        self.userNameString = userNameString
        self.profileImageString = profileImageString
        self.contentImageString = contentImageString
        self.commentString = commentString
        self.postDataString = postDataString
        
    }
    
}
