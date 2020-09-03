//
//  AppDelegate.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/08/29.
//  Copyright © 2020 hairz. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "897033838765-08e2bq8opjgvtou9j1rffjacsoqv78nt.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        let scopes = ["https://www.googleapis.com/auth/calendar.readonly", "https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/calendar"]
        for scope in scopes {
            GIDSignIn.sharedInstance()?.scopes.append(scope)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")

        } else {
          print("\(error.localizedDescription)")
        }
        return
      }
        print("ログイン成功してるで")
//        getEvents(token: user.authentication.accessToken)
        // userDefaultにトークンを保存する
        let userDefaults = UserDefaults.standard
        userDefaults.set(user.authentication.accessToken, forKey: "token")
//        createCalendar(token: user.authentication.accessToken)
        UIApplication.shared.windows.first?.rootViewController?.performSegue(withIdentifier: "toHome", sender: nil)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    private func getEvents(token: String) {
      // イベントリストを取得するURL
      let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary")
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      // ヘッダに情報を設定
      var request = URLRequest(url: url!)
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      // API叩く
      let task = session.dataTask(with: request) { (data, response, error) in
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
            print(json)
        }
      }
      task.resume()
    }

    private func createCalendar(token: String) {
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars") else {
            print("Couldn't create new calendar.")
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String: Any] = [
            "summary": "meshiiru"
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!
                print("result:\(resultData)")
                print("response:\(response)")

            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
    }
}

