//
//  FetchDataManager.swift
//  HftpHW6
//
//  Created by Kai Wang on 2/27/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import Foundation
import UIKit

/*** Input:
*   isLogin: Bool. Use to differ between segue from login and from fresh
* sender: UIRefreshControl.
* vc: UIViewController. The UiViewController which call this function
**** Output:
*       A URLSessionTask
*   This function fetch the information throw HTTP Requst
***/

func urlGET(_ isLogin: Bool, _ sender: UIRefreshControl? = nil, _ vc: UIViewController) -> URLSessionTask{
    let url = URL(string: "https://rt113-dt01.egr.duke.edu:5640/b64entries")!
    
    // create the request
    let httprequest = URLSession.shared.dataTask(with: url){
        (data, response, error) in
        if error != nil {
            loadErrorHandling(error, isLogin, vc, sender)
        } else {
            if let data = data {
                do{
                    //delete the local data in dukePersonArray
                    dukePersonsArray = []
                    
                    let list = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    
                    //parse the data
                    fetchData(list!)
                    //save the data in local
                    let _ = DukePerson.saveDukePersonInfo(dukePersonsArray)
                    
                    //If from the Login segue
                    if (isLogin) {
                        DispatchQueue.main.async {
                            let actionController = vc as! LoginViewController
                            
                            // navigate to main View
                            actionController.performSegue(withIdentifier: K.loginSegue, sender: vc)
                        }
                    } else {
                        // If the RefreshController call the function
                        DispatchQueue.main.async {
                            let actionController = vc as! PersonTableViewController
                            //reload the view
                            actionController.loadDukePersonSections()
                            actionController.tableView.reloadData()
                            sender!.endRefreshing()
                        }
                    }
                }
                catch let err {
                    loadErrorHandling(err, isLogin, vc, sender)
                }
            }
        }
        
    }
    return httprequest
    
}

/*** Input:
*   data: [[String]]. The intial data from server
*
*   This function fetch the information from HTTP Requst body and save into dukePerson list
***/

func fetchData(_ data:[[String: Any]]) {
    for person in data {
        let savePerson = person as NSDictionary
        
        let firstName = savePerson["firstname"] as! String
        let lastName = savePerson["lastname"] as! String
        let from = savePerson["wherefrom"] as! String
        let _gender = savePerson["gender"] as! String
        let email = savePerson["email"] as! String
        let hobby = savePerson["hobbies"] as! [String]
        let _role = savePerson["role"] as! String
        let degree = savePerson["degree"] as! String
        let language = savePerson["languages"] as! [String]
        let team = savePerson["team"] as! String
        var picture = savePerson["picture"] as? String
        let netID = savePerson["netid"] as! String
        let department = savePerson["department"] as! String
        
        var gender: Gender
        var role: DukeRole
        
        switch _gender {
        case "Female":
            gender = .Female
        default:
            gender = .Male
        }
        
        switch _role {
        case "TA":
            role = .TA
        case "Professor":
            role = .Professor
        default:
            role = .Student
        }
        
        if let pic = picture {
            if(pic.isEmpty) {
                picture = UIImage(named: "No photo")!.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString()
            }
        } else {
            picture = UIImage(named: "No photo")!.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString()
        }
        
        let getPerson = DukePerson(
            f: firstName,
            l: lastName,
            n: netID,
            w: from,
            g: gender,
            e: email,
            h: hobby,
            r: role,
            dg: degree,
            dp: department,
            l: language,
            t: team,
            p: picture!
        )
        dukePersonsArray.append(getPerson)
    }
}

/*** Input:
* error: Error? Error message
*  isLogin: Bool. Use to differ between segue from login and from fresh
* sender: UIRefreshControl.
* vc: UIViewController. The UiViewController which call this function
*
*   This function uses internal pop-up window function to show the error message
***/

func loadErrorHandling(_ error: Error?, _ isLogin: Bool, _ vc: UIViewController, _ sender: UIRefreshControl? = nil) {
    
    var message: String
    if let _message = error?.localizedDescription {
        message = _message + " Error happens in GET People, load local data instead"
    } else {
        message = "Error happens in GET People, load local data instead"
    }
    
    DispatchQueue.main.async {
        Alert.loadFailedAlert(on: vc, message: message)
        if(isLogin) {
            let actionController = vc as! LoginViewController
            actionController.performSegue(withIdentifier: K.loginSegue, sender: vc)
        } else {
            sender!.endRefreshing()
        }
    }
    
}
