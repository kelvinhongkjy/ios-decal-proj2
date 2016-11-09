//
//  GameViewController.swift
//  Hangman
//
//  Created by Shawn D'Souza on 3/3/16.
//  Copyright © 2016 Shawn D'Souza. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phraseLabel: UILabel!
    @IBOutlet weak var wrongGuessesLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    
    var state: Int = 1
    var phrase: String = ""
    var guesses: Array<String> = []
    var wrongGuesses: Array<String> = []
    let hangmanPhrases = HangmanPhrases()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
        let gr = UITapGestureRecognizer.init(target: self, action: #selector(tapped))
        self.view.addGestureRecognizer(gr)
        restart(self)
    }

    func keyboardWillAppear(_ n: Notification) {
        if let info = n.userInfo as? Dictionary<String, Any> {
            let v: NSValue = info[UIKeyboardFrameBeginUserInfoKey] as! NSValue
            let size = v.cgRectValue.size
            let transform = CGAffineTransform.init(translationX: 0, y: -size.height)

            UIView.animate(withDuration: 0.3, animations: { 
                self.view.transform = transform
            })
        }
    }
    
    func keyboardWillDisappear(_ n: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    func updateView() {
        var displayStringBuffer: Array<String> = [""]
        for char in self.phrase.characters {
            if guesses.contains(String(char)) {
                displayStringBuffer.append(String(char))
            } else {
                displayStringBuffer.append("_")
            }
        }
        let displayString = displayStringBuffer.joined(separator: " ")
        self.phraseLabel.text = displayString
        
        self.imageView.image = UIImage(named: "hangman\(self.state).gif")
        self.wrongGuessesLabel.text = "Incorrect Guesses: \(self.wrongGuesses.description)"
        
        if self.state == 7 || !displayString.contains("_") {
            self.guessTextField.isEnabled = false
            let title = self.state == 7 ? "You lose" : "You win"
            let alert = UIAlertController.init(title: title, message: self.phrase, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.guessTextField.isEnabled = true
        }
    }
    
    @IBAction func restart(_ sender: AnyObject) {
        state = 1
        guesses = [" "]
        wrongGuesses = []
        phrase = hangmanPhrases.getRandomPhrase()
        print(phrase)
        updateView()
    }

    func tapped(_: Any) {
        self.guessTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            print(text)
            guess(text)
            textField.text = ""
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 1
    }
    
    func guess(_ s: String) {
        let cs = s.capitalized
        if self.state < 7 && !self.guesses.contains(cs) && !self.wrongGuesses.contains(cs) {
            if self.phrase.contains(cs) {
                self.guesses.append(cs)
            } else {
                self.state += 1
                self.wrongGuesses.append(cs)
            }
            updateView()
        }
    }
}
