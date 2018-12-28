//
//  AwardTackingTableViewController.swift
//  AwardTrackingTable
//
//  Created by Jun Dang on 2018-12-25.
//  Copyright © 2018 Jun Dang. All rights reserved.
//

import UIKit
import RealmSwift

protocol HandleButtonDelegate: class {
    func handleMark(cell: UITableViewCell)
}

class AwardTackingTableViewController: UITableViewController, HandleButtonDelegate {

    let cellId = "cellId"
    var dateStringArray = [String]()
    var dateKeys = [String]()
    var goodBehaviourDictionary = [String: ExpandableGoodBehaviours]()
    let realm = try! Realm()
    let uniqueHeaderSectionTag: Int = 7000
    var expandedSectionHeader: UITableViewHeaderFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "AwardTable"
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action:#selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
        
        tableView.register(BehaviourCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 99
        fetchExpandableGoodBehaviours()
        
    }
    
    @objc func addTapped(_sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add the behaviour you want", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add behaviour", style: .default) { (action) in
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
            
            let currentDateString: String = dateFormatter.string(from: date)
          
            let behaviour = GoodBehaviour(goodBehaviour: textField.text!, goodJob: false, dateString: currentDateString)
         
            try! self.realm.write({
                self.realm.add(behaviour)
            })
            self.fetchExpandableGoodBehaviours()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Add a Behaviour"
        }
        present(alert, animated: true, completion: nil)
    }
    
    func fetchExpandableGoodBehaviours() {
        var goodBehaviours: Results<GoodBehaviour> {
            get {
                return realm.objects(GoodBehaviour.self)
            }
        }
        dateStringArray = goodBehaviours.map{ $0.dateString }
        for dateKey in dateStringArray {
            let newGoodBehaviours = List<GoodBehaviour>()
            for goodBehaviour in goodBehaviours {
                if goodBehaviour.dateString == dateKey {
                    newGoodBehaviours.append(goodBehaviour)
                }
                let behaviours = ExpandableGoodBehaviours(isExpanded: true, goodBehaviours: newGoodBehaviours)
                self.goodBehaviourDictionary[dateKey] = behaviours
            }
        }
        dateKeys = [String](goodBehaviourDictionary.keys).sorted()
        tableView.reloadData()
    }
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return goodBehaviourDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = .lightOrange
        header.textLabel?.textColor = .white
        
        if let viewWithTag = self.view.viewWithTag(uniqueHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = uniqueHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(AwardTackingTableViewController.handleExpandClose(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let expandableBehaviours = goodBehaviourDictionary[dateKeys[section]] else {
            return 0
        }
        if expandableBehaviours.isExpanded == false {
            return 0
        }
        let count = expandableBehaviours.goodBehaviours.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return dateKeys.sorted()[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BehaviourCell
        let cell = BehaviourCell(style: .subtitle, reuseIdentifier: cellId)
        cell.delegate = self
        let goodBehaviour = goodBehaviourDictionary[dateKeys[indexPath.section]]?.goodBehaviours[indexPath.row]
      /*  if let goodBehaviour = goodBehaviour {
            var behaviourString = goodBehaviour.goodBehaviour.components(separatedBy: " ").first?.lowercased() ?? "listen"
            if behaviourString != "listen", behaviourString != "temper" {
                behaviourString = "listen2"
            }
            cell.behaviourImageView.image = UIImage(named: behaviourString)*/
         if let goodBehaviour = goodBehaviour {
    
            cell.desLbl.text = goodBehaviour.goodBehaviour
            cell.accessoryView?.tintColor = goodBehaviour.goodJob ? .blue : .lightGray
         }
        
        return cell
}
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            let goodBehaviour = goodBehaviourDictionary[dateKeys[indexPath.section]]?.goodBehaviours[indexPath.row]
            guard let unwrappedGoodBehaviour = goodBehaviour else {
                return
            }
            
            goodBehaviourDictionary[dateKeys[indexPath.section]]?.goodBehaviours.remove(at: indexPath.row)
          
            try! self.realm.write({
                self.realm.delete(unwrappedGoodBehaviour)
            })
       
            tableView.deleteRows(at:[indexPath], with: .automatic)
            
        }
    }
  
    @objc func handleExpandClose(_ sender: UITapGestureRecognizer) {
        
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let imageView = headerView.viewWithTag(uniqueHeaderSectionTag + section) as? UIImageView
        var indexPaths = [IndexPath]()
        guard let expandableBehaviours = goodBehaviourDictionary[dateKeys[section]] else {
            return
        }
        
        for row in expandableBehaviours.goodBehaviours.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let isExpanded = expandableBehaviours.isExpanded
        expandableBehaviours.isExpanded = !isExpanded
        
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
            UIView.animate(withDuration: 0.4, animations: {
                imageView?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
            UIView.animate(withDuration: 0.4, animations: {
                imageView?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
        }
    }
    
     func handleMark(cell: UITableViewCell) {
         guard  let indexPathTapped = tableView.indexPath(for: cell) else {
             return
         }
         guard let expandableBehaviours = goodBehaviourDictionary[dateKeys[indexPathTapped.section]] else {
             return
         }
         let goodBehaviour = expandableBehaviours.goodBehaviours[indexPathTapped.row]
         let goodJob = goodBehaviour.goodJob
        
         try! realm.write {
             goodBehaviour.goodJob = !goodJob
         }
        
         cell.accessoryView?.tintColor = goodJob ? .lightGray : .blue
    }
    
}
