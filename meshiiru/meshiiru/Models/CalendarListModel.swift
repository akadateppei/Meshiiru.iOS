//
//  CalendarListModel.swift
//  meshiiru
//
//  Created by AKADA TEPPEI on 2020/09/04.
//  Copyright © 2020 hairz. All rights reserved.
//

import Foundation

struct CalendarLists: Codable {
    public let calendarLists: [CalendarList]
    struct CalendarList: Codable {
        public let summary: String
        public let description: String
    }
}
