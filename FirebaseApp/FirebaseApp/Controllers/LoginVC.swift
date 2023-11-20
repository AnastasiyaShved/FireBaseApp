//
//  LoginVC.swift
//  FirebaseApp
//
//  Created by Apple on 8.11.23.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
  
    // MARK: - Properties
    var ref: DatabaseReference!
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!

    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLbl.alpha = 0
        //вкидываем реальную ссылку на хранилище Firebase (withPath - категория, в которую будем записывать юзеров)
        ref = Database.database().reference(withPath: "users")
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ [ weak self ] _, user in
            guard let _ = user else { return }
            self?.performSegue(withIdentifier: "goToTasks", sender: nil)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(kdWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kdWillHide),  name: UIWindow.keyboardWillHideNotification, object: nil)
        
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //чистим поля при возврашении на страницу входа
        emailTF.text = nil
        passwordTF.text = nil

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //отписываемся от абсервера когла выходим с экрана
        NotificationCenter.default.removeObserver(self)
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }
    
    // MARK: - Actions
    @IBAction func loginBtn(_ sender: UIButton) {
        guard let email = emailTF.text,
              let password = passwordTF.text,
                !email.isEmpty,
              !password.isEmpty
        else {

            self.displayWarningLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [ weak self ] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "SignIn was incorrect = \(error)")
            } else if let user = user {
                self?.displayWarningLabel(withText: "No such user")
            }
        }
    }

    @IBAction func registrationBtn(_ sender: UIButton) {
        guard let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty
        else {
            self.displayWarningLabel(withText: "Info is incorrect")
            return
        }
        // создаем нового user
        Auth.auth().createUser(withEmail: email, password: password) { [ weak self ] user, error in
            if let error = error {
                self?.displayWarningLabel(withText: "Registration was incorrect = \(error)")
            } else if let user = user {
                ///нужно получить ссылку на категорию users в Firebase, стучимся в категорию  и в ней создаем child
                let userref = self?.ref.child(user.user.uid)
                userref?.setValue(["email": user.user.email])
                ///для записи в базу активируем на сайте
            }
        }
    }
    
    // MARK: - Private func
    private func displayWarningLabel(withText text: String) {
        warningLbl.text = text
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut) { [weak self ] in
            self?.warningLbl.alpha = 1
        } completion: { [weak self ] _ in
            self?.warningLbl.alpha = 0
            self?.warningLbl.text = nil
        }
    }
    
    @objc
    private func kdWillShow(notification: Notification) {
        view.frame.origin.y = 0
        if let kayboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= (kayboardSize.height / 2)
        }
    }
    
    @objc
    private func kdWillHide() {
        view.frame.origin.y = 0
    }
    
    deinit {
        print("!!! DEINITED loginVC !!!")
    }
}

// MARK: - Extension
///скрытие клаву по  нажатии ввода
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
