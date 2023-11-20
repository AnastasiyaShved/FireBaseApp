//
//  User.swift
//  FirebaseApp
//
//  Created by Apple on 9.11.23.
//

import Foundation
import Firebase
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        uid = user.uid
        email = user.email ?? ""
    }
}
