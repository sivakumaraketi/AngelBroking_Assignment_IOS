//
//  SearchDetailsViewModel.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 17/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//

import Foundation

protocol viewModelDelegate: class {
    func sendSearchValue(from SearchText: String)
}

protocol StockDetailViewControllerDelegate: class {
    func getStockDetailSuccessInformationBack(getSearchDetails: [Entity])
    func getNewStockDetailSuccessInformationBack(getSearchDetails: [Entity])
    func getStockDetailErrorInformationBack(getErrorDetails: String)
}

class SearchDetailsViewModel: viewModelDelegate {
    
    let persistence = PersistenceService.shared
    
    let rechability = Reachability.init()
    
    weak var delegate: StockDetailViewControllerDelegate?
    var searchDetails: [Entity] = []
    var mySearchText = ""
    var isFetchRequired = false
    var addResults = false
    var newsearchDetails: [Entity] = []
    
    func sendSearchValue(from SearchText: String) {
        mySearchText = SearchText
        if mySearchText == "fromviewDidLoad" {
            self.isFetchRequired = true
        } else {
            self.persistence.fetch(Entity.self, completion: {(objects) in
                
                self.delegate?.getStockDetailSuccessInformationBack(getSearchDetails: objects)
                self.newsearchDetails = objects
                
                if objects.isEmpty == true {
                    self.isFetchRequired = true
                } else {
                    if self.mySearchText.isEmpty == false {
                        
                        for obj in objects {
                            if obj.username!.lowercased() == self.mySearchText.lowercased() {
                                self.isFetchRequired = false
                                break
                            } else {
                                self.isFetchRequired = true
                            }
                        }
                    }
                    
                }
            })
        }
        
        if isFetchRequired == true {
            fetchRequest()
        }
    }
    
    func fetchRequest() {
        if ((self.rechability!.connection) != .none) {
            isFetchRequired = false
            guard let searchUrl = URL(string: url) else {return}
            URLSession.shared.dataTask(with: searchUrl) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.getStockDetailErrorInformationBack(getErrorDetails: error?.localizedDescription ?? errorMessage)
                    return
                }
                
                guard let data = data else { return }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    self.searchDetails = [Entity]()
                    if let sourcesFromJson = jsonData["users"] as?[[String : AnyObject]]{
                        if self.persistence.isEmpty == true {
                            
                            for sourcesFromJson in sourcesFromJson {
                                if let display_name = sourcesFromJson["display_name"] as? String,let avatar_url = sourcesFromJson["avatar_url"] as? String, let username = sourcesFromJson["username"] as? String, let id = sourcesFromJson["id"] as? Int{
                                    
                                    let source = Entity(context: self.persistence.context)
                                    source.addList = false
                                    source.id = Int16(id)
                                    source.username = username
                                    source.display_name = display_name
                                    var myUrl:NSURL?
                                    if let url: NSURL = NSURL(string: avatar_url) {
                                        myUrl = url
                                    } else if let url: NSURL = NSURL(string: avatar_url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                                        myUrl = url
                                    }
                                    
                                    do {
                                        let imageData = try Data(contentsOf: myUrl! as URL)
                                        source.avatarUrl = imageData as Data
                                    } catch {
                                        self.delegate?.getStockDetailErrorInformationBack(getErrorDetails: error.localizedDescription )
                                    }
                                }
                                self.persistence.saveContext()
                                self.persistence.fetch(Entity.self, completion: {(objects) in
                                    self.delegate?.getStockDetailSuccessInformationBack(getSearchDetails: objects)
                                })
                                
                            }
                            
                            
                        } else {
                            self.persistence.fetch(Entity.self, completion: {(objects) in
                                for obj in objects {
                                    if self.mySearchText.lowercased() == obj.username!.lowercased() {
                                        self.delegate?.getStockDetailSuccessInformationBack(getSearchDetails: objects)
                                        break
                                        
                                    } else {
                                        let source = Entity(context: self.persistence.context)
                                        source.addList = false
                                        source.id = Int16(self.newsearchDetails.count + 1)
                                        var myUrl:NSURL?
                                        let th = Bundle.main.url(forResource: "noImage", withExtension: "png")
                                        myUrl = th! as NSURL
                                        
                                        do {
                                            let imageData = try Data(contentsOf: myUrl! as URL)
                                            source.avatarUrl = imageData
                                        } catch {
                                            self.delegate?.getStockDetailSuccessInformationBack(getSearchDetails: objects)
                                        }
                                        source.display_name = self.mySearchText
                                        source.username = self.mySearchText
                                        self.searchDetails.append(source)
                                        self.persistence.saveContext()
                                        self.persistence.fetch(Entity.self, completion: {(objects) in
                                            self.delegate?.getNewStockDetailSuccessInformationBack(getSearchDetails: objects)
                                        })
                                        
                                    }
                                    break
                                }
                            })
                        }
                    } else {
                        self.delegate?.getStockDetailErrorInformationBack(getErrorDetails: jsonSearchError)
                    }
                    
                } catch {
                    self.delegate?.getStockDetailErrorInformationBack(getErrorDetails: error.localizedDescription)
                }
                
            }.resume()
            
        } else {
            self.delegate?.getStockDetailErrorInformationBack(getErrorDetails: noNetwork)
        }
        
    }
    
}
