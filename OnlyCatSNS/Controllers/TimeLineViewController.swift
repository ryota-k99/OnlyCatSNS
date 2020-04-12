//
//  TimeLineViewController.swift
//  OnlyCatSNS
//
//  Created by Kato Ryota  on 8/04/20.
//  Copyright © 2020 Kato Ryota . All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
   
    var contentArray = [ContentsData]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentArray.count
       }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        return cell
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 546
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toPost", sender: nil)
    }
    
    func fetchData(){
        let fetchDataRef = Database.database().reference().child("content").queryLimited(toLast: 100).queryOrdered(byChild: "postaDate").observe(.value) { (snapshots) in
            self.contentArray.removeAll()
            
            if let snapshot = snapshots.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if let postedContents = snap.value as? [String:Any]{
                        let userName = postedContents["userName"] as? String
                        let profileImageString = postedContents["profileImageURL"] as? String
                        let contentImageString = postedContents["contentImageURL"] as? String
                        let comment = postedContents["comment"] as? String
                        var postDate:CLong?
                        if let postedDate = postedContents["postDate"] as? CLong{
                            postDate = postedDate
                        }
                        let postedTimeString = self.convertTime(serverTime: postDate!)
                        self.contentArray.append(ContentsData(userNameString: userName!, profileImageString: profileImageString!, contentImageString: contentImageString!, commentString: comment!, postDataString: postedTimeString))
                    }
                }
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    func convertTime(serverTime: CLong)->String{
        let x = serverTime / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(x))
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date)
    }
    
}
