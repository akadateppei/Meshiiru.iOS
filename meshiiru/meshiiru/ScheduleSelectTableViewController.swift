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
    @IBOutlet weak private var completeButton: UIBarButtonItem!
    let userDefault = UserDefaults()
    var meshiiranList = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ScheduleSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleSelectTableViewCell")
        if let userName = userDefault.string(forKey: "userName") {
            self.navigationItem.title = userName
        }
        self.tableView.allowsMultipleSelection = true

        completeButton.isEnabled = false

        getEvents()
    }

    override func viewDidAppear(_ animated: Bool) {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completeButton.isEnabled = true
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        completeButton.isEnabled = true
    }

    @IBAction func onTapCompleteButton(_ sender: Any) {
        completeButton.isEnabled = false
        let service = GoogleCalendarService()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        // 予定作成
        for indexPath in selectedIndexPaths {
            if meshiiranList.allKeysForValue(value: indexPath.row) == [] { //　元から選択されてない時
                // 予定を追加
                guard let date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: Calendar.current.startOfDay(for: Date())) else {
                    return
                }
                let dateString = formatter.string(from: date)
                service.createEvent(date: dateString)
            }
            Thread.sleep(forTimeInterval: 1.0)
        }
        // 予定削除
        var idsForDelete: [String] = []
        for row in meshiiranList.values {
            let indexPath = IndexPath(row: row, section: 0)
            if !selectedIndexPaths.contains(indexPath) {
                if let idForDelete = meshiiranList.keyForValue(value: indexPath.row) {
                    print(idForDelete + "を消すよ")
                    idsForDelete.append(idForDelete)
                }
            }
        }
        service.deleteEvents(ids: idsForDelete) { () -> Void in
            Thread.sleep(forTimeInterval: 0.5)
            self.getEvents()
            return
        }
    }

    private func getEvents(){
        meshiiranList = [:]
        GoogleCalendarService().getEvents(){ meshiiranList in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today = Calendar.current.startOfDay(for: Date())
            for (meshiiranId, meshiiranDate) in meshiiranList {
                if let meshiiranDay = dateFormatter.date(from: meshiiranDate) {
                    if let dayInterval = (Calendar.current.dateComponents([.day], from: today, to: meshiiranDay)).day {
                        self.meshiiranList.updateValue(dayInterval, forKey: meshiiranId)
                    }
                }
            }
            self.setupRows()
            print(self.meshiiranList)
        }
    }

    private func setupRows() {
        for (_, row) in meshiiranList {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
    }
}

extension Dictionary where Value: Equatable {
    func allKeysForValue(value: Value) -> [Key] {
        return self.filter({ $0.1 == value }).map({ $0.0 })
        // return self.flatMap({ $0.1 == value ? $0.0 : nil }) // こっちでもok
    }
    func keyForValue(value: Value) -> Key? {
        return allKeysForValue(value: value).first
    }
}
