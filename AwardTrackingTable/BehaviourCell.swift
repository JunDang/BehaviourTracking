//
//  BehaviourCell.swift
//  AwardTrackingTable
//
//  Created by Jun Dang on 2018-12-25.
//  Copyright © 2018 Jun Dang. All rights reserved.
//

import UIKit
import Cartography


class BehaviourCell: UITableViewCell {
    
   let behaviourImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        imageView.image = UIImage(named: "happyApple")
        //imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.blue
        return imageView
    }()
    
    let desLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.text = ""
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 5
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    var didSetupConstraints = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let starButton = UIButton(type: .system)
        starButton.setImage(UIImage(named: "star"), for: .normal)
        starButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        starButton.tintColor = .blue
        starButton.addTarget(self, action: #selector(handleMark), for: .touchUpInside)
        accessoryView = starButton
        setup()
        layoutView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  override func updateConstraints() {
        if didSetupConstraints {
            super.updateConstraints()
            return
        }
        layoutView()
        super.updateConstraints()
        didSetupConstraints = true
    }
    func setup() {
         addSubview(desLbl)
         addSubview(behaviourImageView)
    }
    
    func layoutView() {
        constrain(behaviourImageView) {
            $0.left == $0.superview!.left + 5
            $0.top == $0.superview!.top + 2
            $0.bottom == $0.superview!.bottom - 2
            $0.width == 100
            $0.height == 100
        }
        constrain(desLbl, behaviourImageView) {
            $0.left == $1.right + 2
            $0.top == $1.top
            $0.bottom == $1.bottom
            $0.right == $0.superview!.right - 100
        }
       
       
    }
    
    weak var delegate: HandleButtonDelegate?
    
    @objc private func handleMark() {
           delegate?.handleMark(cell: self as UITableViewCell)
    }
}
