//
//  ViewController.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 17/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//

import UIKit

class StockDetailsViewController: UIViewController {
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet var myView: UIView!
    
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var viewActivityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    let persistence = PersistenceService.shared
    
    
    private let viewModel = SearchDetailsViewModel()
    private var searchDetails  = [Entity]()
    private var filteredDetails = [Entity]()
    var selectedSearchIndex = 0
    var canEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        stockLabel.isHidden = true
        
        
        self.persistence.fetch(Entity.self, completion: {(objects) in
            if objects.isEmpty == true {
                DispatchQueue.main.async {
                    self.viewActivityIndicator.startAnimating()
                    self.myTableView.isHidden = true
                    self.viewModel.sendSearchValue(from: "fromviewDidLoad")
                }
                
            } else {
                self.stockLabel.isHidden = false
                self.setupSearchController()
                self.searchDetails = objects
                self.reloadTableView()
            }
            
        })
        
        
    }
    //for search
    func filterContentForSearchText(_ searchText: String, scope: String = stockName) {
        filteredDetails = searchDetails.filter { result in
            reloadTableView()
            if !(result.addList == false) && scope == stockName || !(result.addList == true) && scope == selectedStockName{
                return false
            }
            return (result.username?.lowercased().contains(searchText.lowercased()))! || searchText == ""
        }
        
        
    }
    //for search
    func setupSearchController() {
        DispatchQueue.main.async {
            self.stockLabel.isHidden = false
            self.searchController.searchResultsUpdater = self
            self.searchController.dimsBackgroundDuringPresentation = false
            self.definesPresentationContext = true
            self.searchController.searchBar.scopeButtonTitles = [stockName,selectedStockName]
            self.searchController.searchBar.delegate = self
            if #available(iOS 11, *) {
                self.navigationItem.searchController = self.searchController
                self.navigationItem.searchController?.isActive = true
                self.navigationItem.hidesSearchBarWhenScrolling = false
            } else {
                self.myTableView.tableHeaderView = self.searchController.searchBar
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.viewActivityIndicator.stopAnimating()
            self.myTableView.isHidden = false
            self.myTableView.reloadData()
        }
    }
    func hideTableView() {
        DispatchQueue.main.async {
            self.viewActivityIndicator.startAnimating()
            self.myTableView.isHidden = true
            self.myTableView.reloadData()
        }
    }
    
    
    
    
}

//table view extensions
extension StockDetailsViewController: UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let cell = self.myTableView.cellForRow(at: indexPath) as? StockDetailTableViewCell {
            self.persistence.fetch(Entity.self, completion: {(objects) in
                for obj in objects {
                    
                    if cell.stockUserName.text?.lowercased() == obj.username!.lowercased() {
                        obj.setValue(false, forKey: "addList")
                        self.persistence.saveContext()
                        
                        break
                    }
                    
                }
            })
        }
        let hide = UIContextualAction(style: .destructive, title: "Delete Stock") { action, view, completion in
            
            self.filteredDetails.remove(at: indexPath.row)
            self.myTableView.deleteRows(at: [indexPath], with: .automatic)
            
            completion(true)
            self.alertMessageOK(for: "one record removed successfully")
        }
        
        hide.backgroundColor = .red
        
        let conf = UISwipeActionsConfiguration(actions: [hide])
        return conf
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if selectedSearchIndex == 0 {
            canEdit = false
        } else {
            canEdit = true
        }
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredDetails.count
        }
        return searchDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockDetailTableViewCell", for: indexPath) as! StockDetailTableViewCell
        
        let stock: Entity
        
        if searchController.isActive {
            stock = filteredDetails[(indexPath as NSIndexPath).row]
        } else {
            stock = searchDetails[(indexPath as NSIndexPath).row]
        }
        cell.myTableActivity.stopAnimating()
        cell.stockUserName.text = stock.username
        cell.stockDisplayName.text = stock.display_name
        cell.myCheckBox.isChecked = stock.addList
        cell.myCheckBox.addTarget(self, action: #selector(onCheckBoxValueChange(_:)), for: .valueChanged)
        cell.myCheckBox.tag = indexPath.row
        //cell.desc.text = self.articles[indexPath.item].desc ?? "No Desc"
        
        let urlimage = stock.avatarUrl
        if urlimage != nil{
            do {
                cell.stockImage.image = UIImage(data: urlimage! as Data)
            } catch {
                cell.stockImage.image = UIImage(named: "noImage.png")
            }
            
        }
        
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 5))
        separator.backgroundColor = UIColor.groupTableViewBackground
        cell.contentView.addSubview(separator)
        
        return cell
        
    }
    
    @objc func onCheckBoxValueChange(_ sender: CheckBox) {
        let index = NSIndexPath(item: sender.tag, section: 0)
        if let cell = myTableView.cellForRow(at: index as IndexPath) as? StockDetailTableViewCell {
            // persistence.updateData()
            self.persistence.fetch(Entity.self, completion: {(objects) in
                for obj in objects {
                    
                    if cell.stockUserName.text?.lowercased() == obj.username!.lowercased() {
                        obj.setValue(true, forKey: "addList")
                        self.persistence.saveContext()
                        break
                    }
                    
                }
            })
        }
        
        
    }
    
}

//protocol extensions
extension StockDetailsViewController: StockDetailViewControllerDelegate {
    func getNewStockDetailSuccessInformationBack(getSearchDetails: [Entity]) {
        DispatchQueue.main.async {
            self.searchDetails = getSearchDetails
            let searchBar = self.searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            self.alertMessageOK(for: "new record added successfully")
            self.filterContentForSearchText(self.searchController.searchBar.text!, scope: scope)
        }
    }
    
    func getStockDetailSuccessInformationBack(getSearchDetails: [Entity]) {
        self.setupSearchController()
        self.searchDetails = getSearchDetails
        self.reloadTableView()
        
    }
    
    func getStockDetailErrorInformationBack(getErrorDetails: String) {
        viewActivityIndicator.stopAnimating()
        alertMessageOK(for: getErrorDetails)
        
    }
    
    
}

//search list extensions
extension StockDetailsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        reloadTableView()
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        if let searchBarText = searchBar.text {
            DispatchQueue.main.async {
                self.viewActivityIndicator.startAnimating()
                self.myTableView.isHidden = true
                self.viewModel.sendSearchValue(from: searchBarText)
            }
            
        }
    }
}
extension StockDetailsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        stockLabel.isHidden = false
        selectedSearchIndex = selectedScope
        if selectedScope == 0 {
            stockLabel.text = lblStockName
        } else if selectedScope == 1 {
            stockLabel.text = lblSelectedStockName
        }
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stockLabel.text = allStocks
    }
    
}
