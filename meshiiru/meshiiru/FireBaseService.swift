//
//  FireBaseService.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/09/21.
//  Copyright © 2020 hairz. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseService {
    var ref: DatabaseReference!
    static let shared = FirebaseService()

    private init() {
        ref = Database.database().reference()
    }

    // ユーザの追加
    func createUser(userId: String, userName: String) {
        ref.child("/users/\(userId)").setValue(["userId": userId, "userName": userName, "calendars": ""]) // 最初はカレンダーは空
    }

    func getUser(userId: String) -> UserModel {
        var user = UserModel(userId: "", userName: "", calendars: "")
        ref.child("/users/\(userId)").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            user.userId = value?["userId"] as? String ?? ""
            user.userName = value?["userName"] as? String ?? ""
            user.calendars = value?["calendar"] as? String ?? ""
        }){ (error) in
            print(error.localizedDescription)
        }
        return user
    }

    func putData(to pass: String, data: [String: Any]) {
        self.ref.child("/\(pass)").setValue(data)
    }

}
