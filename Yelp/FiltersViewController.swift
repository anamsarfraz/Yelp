//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Unum Sarfraz on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit


@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, RadioCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    var filterSettings: YelpFilterSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.backgroundColor = yelpWhite
        
        navigationController?.navigationBar.barTintColor = yelpRed
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: yelpWhite]
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: yelpWhite], for: UIControlState.normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: yelpWhite], for: UIControlState.normal)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)

        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filterSettings.getCurrentFilters())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterSettings.filterSectionSettings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currSection = FilterSections(rawValue: section)!
        let visibleRows = filterSettings.filterSectionSettings[currSection]?["visibleRows"] as? [Int]
        
        return visibleRows!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currSection = FilterSections(rawValue: section)!
        return filterSettings.filterSectionSettings[currSection]?["title"] as? String
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let currSection = FilterSections(rawValue: section)!
        switch(currSection) {
        case .Category:
            return "See All"
        default:
            return ""
        }
    }
    
    func footerButtonSelected(sender: UIButton?) {
        let categoryAllData = filterSettings.filterSectionSettings[.Category]?["data"] as? [String]
        let isExpanded = filterSettings.filterSectionSettings[.Category]?["isExpanded"] as? Bool

        if isExpanded! {
            // Collapse if expanded
            filterSettings.filterSectionSettings[.Category]?["visibleRows"] = defaultVisibleCategoryRows as AnyObject
        } else {
            // Expand if collapsed
            filterSettings.filterSectionSettings[.Category]?["visibleRows"] = (0..<categoryAllData!.count).map { $0 } as AnyObject
        }
        filterSettings.filterSectionSettings[.Category]?["isExpanded"] = !isExpanded! as AnyObject
            
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let currSection = FilterSections(rawValue: section)!
        switch(currSection) {
        case .Category:
            let isExpanded = filterSettings.filterSectionSettings[.Category]?["isExpanded"] as? Bool
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
            footerView.backgroundColor = yelpWhite
            
            let footerButton = UIButton(frame: CGRect(x: 0, y: 0, width: footerView.frame.size.width,  height: footerView.frame.size.height))
            if (isExpanded!) {
                footerButton.setTitle("Collapse All", for: .normal)
            } else {
                footerButton.setTitle("See All", for: .normal)
            }
            
            footerButton.setTitleColor(UIColor.black, for: .normal)
            footerButton.addTarget(self, action: #selector(footerButtonSelected), for: UIControlEvents.touchUpInside)
            footerButton.layer.borderColor = UIColor.lightGray.cgColor
            footerButton.layer.borderWidth = 1.0
            footerButton.layer.cornerRadius = 3


            footerView.addSubview(footerButton)
            return footerView
        default:
            return nil
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currSection = FilterSections(rawValue: indexPath.section)!
        let visibleRows = filterSettings.filterSectionSettings[currSection]?["visibleRows"] as? [Int]
        let currSectionAllData = filterSettings.filterSectionSettings[currSection]?["data"] as? [String]

        switch currSection {
        case .Deal, .Category:
            let sectionSwitchStates = filterSettings.switchStates[currSection]
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            switchCell.delegate = self
            switchCell.switchLabel.text = currSectionAllData?[(visibleRows?[indexPath.row])!]
            switchCell.onSwitch.isOn = sectionSwitchStates?[indexPath.row] ?? false

            return switchCell
            
        case .Distance, .SortBy:
            let sectionRowSelected = filterSettings.buttonSelections[currSection]
            let radioCell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell
            let image = visibleRows!.count == 1 ? UIImage(named: "downArrow"): UIImage(named: "radioCheckButton")

            radioCell.delegate = self
            radioCell.radioLabel.text = currSectionAllData?[(visibleRows?[indexPath.row])!]
            radioCell.radioButton.isSelected = visibleRows?[indexPath.row] == (sectionRowSelected ?? -1)
            radioCell.radioButton.setImage(image, for: UIControlState.selected)
            
            return radioCell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currSection = FilterSections(rawValue: indexPath.section)!
        let currSectionAllData = filterSettings.filterSectionSettings[currSection]?["data"] as? [String]
        let isExpandable = filterSettings.filterSectionSettings[currSection]?["isExpandable"] as? Bool
        let isExpanded = filterSettings.filterSectionSettings[currSection]?["isExpanded"] as? Bool
        
        if isExpandable! {
            if isExpanded! {
                // Collapse if expanded
                if (currSection == .Category) {
                    filterSettings.filterSectionSettings[currSection]?["visibleRows"] = defaultVisibleCategoryRows as AnyObject
                } else {
                    filterSettings.filterSectionSettings[currSection]?["visibleRows"] = [filterSettings.buttonSelections[currSection]!] as AnyObject
                }
                
            } else {
                // Expand if collapsed
                filterSettings.filterSectionSettings[currSection]?["visibleRows"] = (0..<currSectionAllData!.count).map { $0 } as AnyObject
            }
            filterSettings.filterSectionSettings[currSection]?["isExpanded"] = !isExpanded! as AnyObject
            
            tableView.reloadData()
        }
        
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        let currSection = FilterSections(rawValue: indexPath.section)!
        var currSectionChanges = filterSettings.switchStates[currSection] ?? [:]
        currSectionChanges[indexPath.row] = value
        filterSettings.switchStates[currSection] = currSectionChanges
    }
    
    func radioCell(radioCell: RadioCell, didTouchInside value: Bool) {
        let indexPath = tableView.indexPath(for: radioCell)!
        let currSection = FilterSections(rawValue: indexPath.section)!
        let currSectionAllData = filterSettings.filterSectionSettings[currSection]?["data"] as? [String]
        let isExpanded = filterSettings.filterSectionSettings[currSection]?["isExpanded"] as? Bool
        
        // Collapsing after selection. Check if already collapsed
        if (isExpanded!) {
            filterSettings.buttonSelections[currSection] = indexPath.row
            filterSettings.filterSectionSettings[currSection]?["visibleRows"] = [indexPath.row] as AnyObject

        } else {
            filterSettings.filterSectionSettings[currSection]?["visibleRows"] = (0..<currSectionAllData!.count).map { $0 } as AnyObject
        }
        
        filterSettings.filterSectionSettings[currSection]?["isExpanded"] = !isExpanded! as AnyObject
        tableView.reloadData()

        //tableView.reloadSections(IndexSet(indexPath), with: UITableViewRowAnimation.fade)
        
    }
    
}
