//
//  ScheduleSelectTableViewController.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/08/29.
//  Copyright © 2020 hairz. All rights reserved.
//

import UIKit
import GoogleSignIn

class ScheduleSelectTableViewController: UITableViewController {
    //MARK: properties
    let userDefault = UserDefaults()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ScheduleSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleSelectTableViewCell")
        if let userName = userDefault.string(forKey: "userName") {
            self.navigationItem.title = userName
        }
        self.tableView.allowsMultipleSelection = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleSelectTableViewCell") as? ScheduleSelectTableViewCell else {
            return UITableViewCell()
        }
        guard let date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: Date()) else {
            return UITableViewCell()
        }
        cell.configureCell(date: date)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.size.height
        guard let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height,
            let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height else {
            return screenHeight/8
        }
        let applicationHeight = screenHeight - statusBarHeight - navigationBarHeight

        return applicationHeight/7
    }

    @IBAction func onTapHoge(_ sender: Any) {
        createEvent()
    }

    private func createEvent() {
        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/meshiiru/events") else {
            print("Couldn't create new calendar.")
            return
        }
        let user = GIDSignIn.sharedInstance()?.currentUser
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        print(user?.authentication.accessToken)
        request.addValue("Bearer \(user?.authentication.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params: [String: Any] = [
            "end.date": "2020/9/3",
            "summary": "赤田"

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
