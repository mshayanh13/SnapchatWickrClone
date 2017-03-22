//
//  UserTVC.swift
//  SnapchatWickrClone
//
//  Created by Mohammad Hemani on 3/20/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Parse

class UserTVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var usernames: [String]!
    
    var recipientUsername: String!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        usernames = [String]()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UserTVC.checkForMessages), userInfo: nil, repeats: true)
        
        
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: (PFUser.current()?.username)!)
        
        do {
            
            let users = try query?.findObjects()
            
            if let users = users as? [PFUser] {
                
                for user in users {
                    
                    self.usernames.append(user.username!)
                    
                }
                
                tableView.reloadData()
                
            }
            
        } catch {
            
            print("Could not get users")
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Logout" {
            
            PFUser.logOut()
            
            timer.invalidate()
            
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        recipientUsername = usernames[indexPath.row]
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            print("Image returned")
            
            let imageToSend = PFObject(className: "Image")
            imageToSend["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(image, 0.5)!)
            
            imageToSend["senderUsername"] = PFUser.current()?.username
            imageToSend["recipientUsername"] = recipientUsername
            
            imageToSend.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    self.showErrorAlert(title: "Message Sent!", message: "Your message has been sent")
                    
                } else {
                    
                    self.showErrorAlert(title: "Sending Failed", message: "Please try again later")
                    
                }
                
            })
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func checkForMessages() {
        
        //print("Timer activated")
        
        let query = PFQuery(className: "Image")
        query.whereKey("recipientUsername", equalTo: (PFUser.current()?.username)!)
        
        do {
            
            let images = try query.findObjects()
            
            
            if images.count > 0 {
                
                var senderUsername = "Unknown User"
                if let username = images[0]["senderUsername"] as? String {
                    
                    senderUsername = username
                    
                }
                
                if let pfFile = images[0]["photo"] as? PFFile {
                    
                    pfFile.getDataInBackground(block: { (data, error) in
                        
                        if let imageData = data {
                            
                            images[0].deleteInBackground()
                            
                            self.timer.invalidate()
                            
                            if let imageToDisplay = UIImage(data: imageData) {
                                
                                let title = "You have a message"
                                let message = "Message from \(senderUsername)"
                                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    let backgroundImageView = UIImageView(frame:  CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    backgroundImageView.backgroundColor = UIColor.black
                                    backgroundImageView.alpha = 0.8
                                    backgroundImageView.tag = 13
                                    self.view.addSubview(backgroundImageView)
                                    
                                    let displayedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    
                                    displayedImageView.image = imageToDisplay
                                    displayedImageView.contentMode = .scaleAspectFit
                                    
                                    displayedImageView.tag = 13
                                    
                                    self.view.addSubview(displayedImageView)
                                    
                                    _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                                        
                                        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(UserTVC.checkForMessages), userInfo: nil, repeats: true)
                                        
                                        for subview in self.view.subviews {
                                            
                                            if subview.tag == 13 {
                                                
                                                subview.removeFromSuperview()
                                                
                                            }
                                            
                                        }
                                        
                                    })
                                    
                                })
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    })
                    
                }
                
                
                
            }
            
            
            
        } catch {
            
            print("Could not get images")
            
        }
        
    }

}
