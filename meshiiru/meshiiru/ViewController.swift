//
//  ViewController.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/08/29.
//  Copyright © 2020 hairz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var scheduleSelectTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleSelectTableView.register(UINib(nibName: "ScheduleSelectTableViewCell", bundle: nil), forCellReuseIdentifier: "scheduleSelectTableViewCell")
    }
}
