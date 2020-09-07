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
    var selectedRows: [Int] = []
    var selectedEventIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ScheduleSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleSelectTableViewCell")
        if let userName = userDefault.string(forKey: "userName") {
            self.navigationItem.title = userName
        }
        self.tableView.allowsMultipleSelection = true

        completeButton.isEnabled = false

        GoogleCalendarService().getEvents(completion1: {ids in
                self.selectedEventIds = ids
            print(ids)
        }){ meshiiranList in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let today = Calendar.current.startOfDay(for: Date())
            for meshiiranDay in meshiiranList {
                if let meshiiranDate = dateFormatter.date(from: meshiiranDay) {
                    if let dayInterval = (Calendar.current.dateComponents([.day], from: today, to: meshiiranDate)).day {
                        self.selectedRows.append(dayInterval)
                    }
                }
            }
            self.setupRows()
        }
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
        print(selectedRows)
        let service = GoogleCalendarService()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for id in selectedEventIds {
            service.deleteCalendar(id: id)
        }
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        for indexPath in selectedIndexPaths {
            guard let date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: Date()) else {
                return
            }
            let dateString = formatter.string(from: date)
            service.createEvent(date: dateString)
        }
    }

    private func setupRows() {
        for row in selectedRows {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
    }
}
