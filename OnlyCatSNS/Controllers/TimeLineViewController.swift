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
//        profileImageView.layer.cornerRadius = 100.0
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentArray.count
       }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        profileImageView.sd_setImage(with: URL(string: contentArray[contentArray.count - indexPath.row - 1].profileImageString), completed: nil)
        profileImageView.layer.cornerRadius = 30.0
        
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        userNameLabel.text = contentArray[contentArray.count - indexPath.row - 1].userNameString
        
        let contentImageView = cell.viewWithTag(3) as! UIImageView
        contentImageView.sd_setImage(with: URL(string: contentArray[contentArray.count - indexPath.row - 1].contentImageString), completed: nil)
        
        let commentLabel = cell.viewWithTag(4) as! UILabel
        commentLabel.text = contentArray[contentArray.count - indexPath.row - 1].commentString
        
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
        let fetchDataRef = Database.database().reference().child("content").queryLimited(toLast: 100).queryOrdered(byChild: "pastDate").observe(.value) { (snapshots) in
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
                let indexPath = IndexPath(row: self.contentArray.count - 1, section: 0)
                if self.contentArray.count >= 5{
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
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
