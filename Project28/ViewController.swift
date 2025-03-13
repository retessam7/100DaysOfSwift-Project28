//
//  ViewController.swift
//  Project28
//
//  Created by Aleksei Ivanov on 13/3/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        // from project 19
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // when our app has been backgrounded or the user has switched to multitasking mode
        // calls our saveSecretMessage() directly when the notification comes in, which means the app automatically saves any text and hides it when the app is moving to a background state.
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        unlockSecretMessage()
    }
    
    // needs to show the text view, then load the keychain's text into it
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        //  Loading strings from the keychain using
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    // to write the text view's text to the keychain, then make it hidden
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // is used to tell a view that has input focus that it should give up that focus (to tell our text view that we're finished editing it, so the keyboard can be hidden)
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
}

