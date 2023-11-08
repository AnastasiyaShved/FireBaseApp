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
  
    var ref: DatabaseReference!
    
    // MARK: - Properties
    @IBOutlet weak var warningLbl: UILabel!
    
    
    @IBOutlet weak var emailTF: UITextField!
   
    @IBOutlet weak var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLbl.alpha = 0
        //вкидываем реальнуб ссылку на хранилище Firebase (withPath - категория, в которую будем записывать юзеров)
        ref = Database.database().reference(withPath: "users")
    }
    @IBAction func loginBtn(_ sender: UIButton) {
    }
    @IBAction func registrationBtn(_ sender: UIButton) {
        guard let email = emailTF.text,
              let password = passwordTF.text,
                !email.isEmpty,
              !password.isEmpty
        else {
            //TODO: - Info is uncorrect
            return
        }
        // создаем нового user
        Auth.auth().createUser(withEmail: email, password: password) { [ weak self ] user, error in
            if let error = error {
                print(error)
            } else if let user = user {
                ///нужн получить ссылку на категорию users в Firebase, стучимся в категорию  и в ней создаем child
                let userref = self?.ref.child(user.user.uid)
                userref?.setValue(["email": user.user.email])
                ///для записи в базу активируем на сайте
            }
        }
    }
    

    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
