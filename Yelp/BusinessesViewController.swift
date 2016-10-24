//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD


class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,FiltersViewControllerDelegate, UIScrollViewDelegate {
    
    var businesses: [Business]!
    var currBusinesses: [Business]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yelpNavigationBar: UINavigationItem!
    
    var searchBar: UISearchBar!
    var filterSettings: YelpFilterSettings!
    var currFilters: [String: AnyObject]!
    
    var currOffSet = 0
    var currTotal = 0
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize businesses as empty arrays for overall business results and current results
        businesses = [Business]()
        currBusinesses = [Business]()
        
        // Initialize filter settings
        filterSettings = YelpFilterSettings()
        currFilters = filterSettings.getCurrentFilters()
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Set navigation bar colors
        navigationController?.navigationBar.barTintColor = yelpRed
        navigationController?.navigationBar.tintColor = yelpWhite
        navigationController?.navigationBar.isTranslucent = false

        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        searchBar.placeholder = defaultSearchTerm
        searchBar.barTintColor = yelpRed
        searchBar.searchBarStyle = .prominent
        searchBar.isTranslucent=false
        navigationItem.titleView = searchBar

        // Initialize business table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120


        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
        // Perform the first search when the view controller first loads
        doSearch(term: defaultSearchTerm, sort: currFilters["sort"] as? YelpSortMode, categories: currFilters["categories"] as? [String], deals: currFilters["deals"] as? Bool, distance: currFilters["distance"] as? Double)
        
    }
    
    fileprivate func doSearch(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Double?) {
        if (!isMoreDataLoading) {
            // Show the progress bar when infinite scroll is not showing
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.currOffSet = 0
        }
        
        Business.searchWithTerm(term: term, sort: sort, categories: categories, deals: deals, distance: distance, offset: currOffSet, completion: { (businesses: [Business]?, total: Int?, error: Error?) -> Void in
            
            self.currBusinesses = businesses
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // Check if more data is loading, stop infinite scroll animation
            if (self.isMoreDataLoading) {
                self.loadingMoreView?.stopAnimating()
                self.isMoreDataLoading = false
                self.businesses.append(contentsOf: self.currBusinesses ?? [])
            } else {
                self.businesses = self.currBusinesses
            }
            self.currTotal = total!
            
            self.tableView.reloadData()
            }
        )
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        currFilters = filters
        businesses = [Business]()
        doSearch(term: defaultSearchTerm, sort: currFilters["sort"] as? YelpSortMode, categories: currFilters["categories"] as? [String], deals: currFilters["deals"] as? Bool, distance: currFilters["distance"] as? Double)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                
                let numBusinesses = (currBusinesses?.count)!
                if (currOffSet + numBusinesses) < currTotal {
                    currOffSet += numBusinesses
                    loadingMoreView!.startAnimating()

                    doSearch(term: defaultSearchTerm, sort: currFilters["sort"] as? YelpSortMode, categories: currFilters["categories"] as? [String], deals: currFilters["deals"] as? Bool, distance: currFilters["distance"] as? Double)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let businessCell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        businessCell.business = businesses[indexPath.row]
        
        return businessCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.filterSettings = filterSettings
            filtersViewController.delegate = self
    }
    
}

// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        doSearch(term: defaultSearchTerm, sort: currFilters["sort"] as? YelpSortMode, categories: currFilters["categories"] as? [String], deals: currFilters["deals"] as? Bool, distance: currFilters["distance"] as? Double)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        doSearch(term: searchBar.text!, sort: currFilters["sort"] as? YelpSortMode, categories: currFilters["categories"] as? [String], deals: currFilters["deals"] as? Bool, distance: currFilters["distance"] as? Double)
    }
}

