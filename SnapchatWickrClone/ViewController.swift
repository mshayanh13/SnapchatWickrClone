//
//  ViewController.swift
//  SnapchatWickrClone
//
//  Created by Mohammad Hemani on 3/20/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: MaterialTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
            
            performSegue(withIdentifier: "UserTVC", sender: self)
            
        }
        
    }
    
    @IBAction func signUpLogInButtonPressed(_ sender: MaterialButton) {
        
        if let username = usernameTextField.text ,username != "" {
            
            PFUser.logInWithUsername(inBackground: username, password: "password", block: { (user, logInError) in
                
                if logInError != nil {
                    
                    let user = PFUser()
                    
                    user.username = username
                    user.password = "password"
                    
                    user.signUpInBackground(block: { (success, signUpError) in
                        
                        if let signUpError = signUpError as? NSError {
                            
                            var errorMessage = "Signup failed - Please try again"
                            
                            if let errorString = signUpError.userInfo["error"] as? String {
                                
                                errorMessage = errorString
                                
                            }
                            
                            self.errorLabel.text = errorMessage
                            
                        } else {
                            
                            self.performSegue(withIdentifier: "UserTVC", sender: self)
                            
                        }
                        
                    })
                    
                } else {
                    
                    print("Logged In")
                    self.performSegue(withIdentifier: "UserTVC", sender: self)
                    
                }
                
            })
            
            
        } else {
            
            errorLabel.text = "A username is required"
            
        }
        
    }
    
    
}

