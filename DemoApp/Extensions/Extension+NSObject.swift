//
//  Extension+NSObject.swift
//  Urban Clap
//
//  Created by JPLoft_2 on 05/10/21.
//

import Foundation
import UIKit


//MARK:- For Getting Class Name

extension NSObject {
  var className: String {
    return String(describing: type(of: self))
  }

  class var className: String {
    return String(describing: self)
  }
}
