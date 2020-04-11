//
//  TimeLineViewController.swift
//  OnlyCatSNS
//
//  Created by Kato Ryota  on 8/04/20.
//  Copyright © 2020 Kato Ryota . All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController{
   
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//           <#code#>
//       }
//
//       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//           <#code#>
//       }
    
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toPost", sender: nil)
    }
    
}
