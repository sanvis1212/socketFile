//
//  RVSocketConstant.swift
//  RVSocketIO
//
//  Created by Ram Vinay on 03/01/20.
//  Copyright © 2020 Ram Vinay. All rights reserved.
//

import UIKit

//MARK:- BASE URLS SETUP
struct RVSocketURL {
    static let socketURl = URL(string: Bundle.main.infoDictionary?["RVSocketUrl"] as? String ?? "")
}
