//
//  Utility.swift
//  RescribeDoctor
//
//  Created by Swapnil Dhotre on 02/02/18.
//  Copyright © 2018 Swapnil Dhotre. All rights reserved.
//

import UIKit

class Utility {
  static var cache: NSCache<AnyObject, AnyObject>!

  init() {
    //    self.cache = NSCache()
  }

  // NSUserDefault Methods
  class func setUserLocalObject(object: Any?, key: String) -> Bool {
    let defaults = UserDefaults.standard
    defaults.set(object, forKey: key)
    return defaults.synchronize()
  }

  class func getUserLocalObjectForKey(key: String) -> Any? {
    let defaults = UserDefaults.standard
    return defaults.object(forKey: key) as Any?
  }

  class func getUserLocalBoolForKey(key: String) -> Bool {
    let defaults = UserDefaults.standard

    if let value = defaults.object(forKey: key) as? Bool {
      return value
    }
    return false
  }

  class func clearLocalObjectsFor(key: String) {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: key)
    defaults.synchronize()
  }
}
