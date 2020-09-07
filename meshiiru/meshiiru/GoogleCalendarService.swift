//
//  GoogleCalendarService.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/09/05.
//  Copyright © 2020 hairz. All rights reserved.
//

import Foundation
import GoogleSignIn

class GoogleCalendarService {
    private let session = { () -> URLSession in
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()

    func fetchCalendarList(token: String) {
        let url = URL(string: "https://www.googleapis.com/calendar/v3/users/me/calendarList")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // ヘッダに情報を設定
        var request = URLRequest(url: url!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // API叩く
        let task = session.dataTask(with: request) { (data, response, error) in
            // パース
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                guard let res = json, let items = res["items"] as? [[String: Any]] else {
                    return
                }
                for calendarList: [String: Any] in items {
                    guard let calendarName = calendarList["summary"] as? String else {
                        return
                    }
                    // カレンダーの名前がmeshiiruならidを保存 & カレンダーを持っていることも保存
                    if calendarName == "meshiiru" {
                        guard let calendarId = calendarList["id"] else {
                            return
                        }
                        UserDefaults.standard.set(calendarId, forKey: "calendarId")
                    }
                }
            }
        }
        task.resume()
    }

    func getAuthentication() {
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/meshiiru/acl"),
            let token = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken else {
                print("Couldn't get authentication.")
                return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String: Any] = [
            "role": "writer"
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!

            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
    }

    func addUser(email: String, calendarId: String) {
        guard let token = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken,
            let url = URL(string: String(format: "https://www.googleapis.com/calendar/v3/calendars/%@/acl", calendarId)) else {
            return
        }

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String: Any] = [
            "role": "writer",
            "scope": [
                "type": "user",
                "value": email,
            ]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                // 画面遷移の処理

            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
    }

    func createCalendar(token: String) {
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

            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
    }

    func getEvents(completion: @escaping([String: String]) -> Void) {
        var meshiiranList: [String: String] = [:]
        guard let token = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken, let calendarId = UserDefaults().string(forKey: "calendarId") else {
            return
        }
        let calendar = Calendar.current
        let date = Date()
        guard let minDate = calendar.date(byAdding: .day, value: 0, to: calendar.startOfDay(for: date)),
            let maxDate = calendar.date(byAdding: .day, value: 6, to: calendar.nextDay(for: date)) else {
                return
        }

        let minDateString = stringFromDate(date: minDate)
        let maxDateString = stringFromDate(date: maxDate)
        // イベントリストを取得するURL
        guard let url = URL(string: String(format: "https://www.googleapis.com/calendar/v3/calendars/%@/events?timeMin=%@&timeMax=%@", calendarId, minDateString, maxDateString)) else {
            return
        }
        // ヘッダに情報を設定
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // API叩く
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
                    return
                }
                let events = json["items"] as! [[String: Any]]
                for event in events {
                    if event["summary"] as? String == UserDefaults().string(forKey: "userName") {
                        let startItems = event["start"] as! [String: Any]
                        if startItems["date"] != nil, let id = event["id"] as? String {
                            meshiiranList.updateValue(startItems["date"] as! String, forKey: id)
                        }
                    }
                }
                completion(meshiiranList)
            }
        }
        task.resume()
    }

    func deleteEvents(ids: [String], completion: () -> Void ) {
        guard let calendarId = UserDefaults().string(forKey: "calendarId"),
            let token = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken else {
            print("Couldn't get calendarId or access token.")
            return
        }
        for id in ids {
            guard let url = URL(string: String(format: "https://www.googleapis.com/calendar/v3/calendars/%@/events/%@", calendarId, id)) else {
                print("Couldn't create URL.")
                continue
            }
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "Delete"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            print("delete a calendar id of " + id)
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!
                print(resultData)
            })
            task.resume()
            Thread.sleep(forTimeInterval: 0.5)
        }
        completion()
    }

    func createEvent(date: String) {
        guard let calendarId = UserDefaults().string(forKey: "calendarId"),
            let url = URL(string: String(format: "https://www.googleapis.com/calendar/v3/calendars/%@/events", calendarId)) else {
            print("Couldn't create new calendar.")
            return
        }
        guard let token = GIDSignIn.sharedInstance()?.currentUser.authentication.accessToken, let userName = UserDefaults().string(forKey: "userName") else {
            print("Don't have access token.")
            return
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String: Any] = [
            "start": [
                "date": date
            ],
            "end": [
                "date": date
            ],
            "summary": userName
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!

            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
    }

    func stringFromDate(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}

extension Calendar {
    func nextDay(for date:Date) -> Date {
        return move(date, byDays: 1)
    }

    func move(_ date:Date, byDays days:Int) -> Date {
        return self.date(byAdding: .day, value: days, to: startOfDay(for: date))!
    }
}
