//
//  ScheduleSelectTableViewCell.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/08/29.
//  Copyright © 2020 hairz. All rights reserved.
//

import UIKit

class ScheduleSelectTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var meshiiruCheckImage: UIImageView!

    var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print(selected)
        selectionColor = selected ? UIColor(red: 80/255, green: 215/255, blue: 255/255, alpha: 1) : UIColor.white
        // Configure the view for the selected state
    }

    func configureCell(date: Date) {
        dateLabel.text = stringFromDate(date: date)
        weekdayLabel.text = weekdayFromDate(date: date)
    }

    func stringFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "M/d"
        print(formatter.string(from: date))
        return formatter.string(from: date)
    }

    func weekdayFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    func switchBackgroudColor() {
        if self.isSelected == true {
            self.backgroundColor = UIColor(red: 80/255, green: 215/255, blue: 255/255, alpha: 1)
        } else {
            self.backgroundColor = UIColor.white
        }
    }

}
