//
//  Task.swift
//  FirebaseApp
//
//  Created by Apple on 9.11.23.
//

import Foundation
import Firebase
import FirebaseAuth

struct Task {
    let title: String
    let userId: String
    var ref: DatabaseReference? /// ссылка к конкретной записи в БД
    var completed: Bool = false
    /// для создание обьекта локально сощдаем init
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
    }
    // для создания оббекта из FireBase, DataSnapshot - снимок иерархии DataBase
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue = snapshot.value as? [String: Any],
              let title = snapshotValue[Constans.titleKey] as? String,
              let userId = snapshotValue[Constans.userIdKey] as? String,
              let completed = snapshotValue[Constans.completedKey] as? Bool else { return nil }
        self.title = title
        self.userId = userId
        self.completed = completed
        self.ref = snapshot.ref
      
    }
    
    ///свойство для перевода данных а словарь
    func convertToDictinary() -> [String: Any] {
        [Constans.titleKey: title, Constans.userIdKey: userId, Constans.completedKey: completed]
    }
    
    private enum Constans {
        static let titleKey = "title"
        static let userIdKey = "userId"
        static let completedKey = "completed"
    }
}
