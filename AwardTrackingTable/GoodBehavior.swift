//
//  GoodBehavior.swift
//  AwardTrackingTable
//
//  Created by Jun Dang on 2018-12-25.
//  Copyright © 2018 Jun Dang. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class ExpandableGoodBehaviours: Object {
    
      dynamic var isExpanded: Bool = false
      dynamic var goodBehaviours =  List<GoodBehaviour>()
 
      convenience init(isExpanded: Bool, goodBehaviours: List<GoodBehaviour>) {
          self.init()
          self.isExpanded = isExpanded
          self.goodBehaviours = goodBehaviours
      }
}

@objcMembers class GoodBehaviour: Object{

      dynamic var goodBehaviour: String = ""
      dynamic var goodJob: Bool = false
      dynamic var dateString: String = ""
 
    convenience init(goodBehaviour: String, goodJob: Bool, dateString: String) {
          self.init()
          self.goodBehaviour = goodBehaviour
          self.goodJob = goodJob
          self.dateString = dateString
      }
}
