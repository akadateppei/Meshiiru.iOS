//
//  AppDelegate.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/08/29.
//  Copyright © 2020 hairz. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "897033838765-08e2bq8opjgvtou9j1rffjacsoqv78nt.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        FirebaseApp.configure()
        let scopes = ["https://www.googleapis.com/auth/calendar.readonly", "https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/calendar.events"]
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

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // typeをチェック
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let webpageURL = userActivity.webpageURL!
            if !handleUniversalLink(URL: webpageURL) {
                // コンテンツをアプリで開けない場合は、Safariに戻す
                UIApplication.shared.open(webpageURL)
                return false
            }
        }
        return true
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
        let calendarService = GoogleCalendarService()
        let userDefaults = UserDefaults.standard
        // ユーザネームが保存されていなければ保存
        if userDefaults.object(forKey: "userName") == nil {
            guard let userName = user.profile.name else {
                return
            }
            userDefaults.set(userName, forKey: "userName")
        }
        // カレンダーIDが保存されていなければリストから取得
        calendarService.fetchCalendarList(token: user.authentication.accessToken)
        // リストにIDがなければ作成か共有
        if userDefaults.object(forKey: "calendarId") == nil {
            // TODO:作成画面へ
            return
        }
        // 予定作成画面へ
        UIApplication.shared.windows.first?.rootViewController?.performSegue(withIdentifier: "toHome", sender: nil)
    }

    private func handleUniversalLink(URL url: URL) -> Bool {
        // TODO:modeがshareなら権限付与、addCalendarならカレンダーリストにmeshiiruを追加
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            let mail = queryItems.first(where: { $0.name == "mail" })?.value,
            let calendarId = queryItems.first(where: { $0.name == "calendarId" })?.value else {
                return false
        }
        let service = GoogleCalendarService()
        // aclで権限付与してあげる
        service.addUser(email: mail, calendarId: calendarId)
        return true
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}

