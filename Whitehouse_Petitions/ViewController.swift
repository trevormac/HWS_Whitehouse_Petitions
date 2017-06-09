//
//  ViewController.swift
//  Whitehouse_Petitions
//
//  Created by Trevor MacGregor on 2017-05-10.
//  Copyright © 2017 Nusic_Inc. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
//Array of dictionaries. Each dict holding a string for its key, and a string for its value
    var petitions = [[String: String]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        
    }
    
    func fetchJSON() {
        let urlString:String
        //first vc loads the original Json
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            //detailVC only loads petitions with min 10,000 sigs
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        //make sure url is valid:
        if let url = URL(string: urlString) {
            //create a new data object using contentsOf. returns the contents of the url
            if let data = try? Data(contentsOf: url) {
                let json = JSON(data: data)
                //swiftyJson will return 0 if the values don't exist:
                if json["metadata"]["responseInfo"]["status"].intValue == 200 {
                    self.parse(json: json)
                    return
                }
            }
        }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    
    //Parse Json into dicts, with each dict having 3 values:title of the petition, body text, and how many signatures
    func parse(json: JSON){
        for result in json["results"].arrayValue {
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigs = result["signatureCount"].stringValue //swiftyJson converst from num to string
            let obj = ["title": title, "body": body, "sigs": sigs]
            //adds the new dict to our array
            petitions.append(obj)
        }
        tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
    }

    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition["title"]
        cell.detailTextLabel?.text = petition["body"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    

}

