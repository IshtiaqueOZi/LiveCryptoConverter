//
//  LiveRatesViewController.swift
//  LiveCryptoConverter
//
//  Created by MacBook on 12/5/1396 AP.
//  Copyright © 1396 MacBook. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMobileAds
import RSSelectionMenu
import CoreData
import SKActivityIndicatorView

class LiveRatesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, GADInterstitialDelegate {

@IBOutlet weak var refreshButtonAction: UIButton!
@IBOutlet weak var changeCurrency: UIButton!

@IBOutlet weak var currencyTableView: UITableView!

@IBAction func refreshRates(_ sender: Any)
{
    
    self.getPriceForCryptos()
}
var dataSource = DefaultCoinDatasource.sharedInstance.currencie
var currencySelected = Currency()
 var CurrencySelectionMenu = RSSelectionMenu<Any>()
var odd = false
@IBAction func changeCurrencyButnAction(_ sender: Any)
{
   
    if (self.intersitial.isReady && odd) {
        odd = false
        self.intersitial.present(fromRootViewController: self)
        self.intersitial =  self.createAndLoadInterstitial()
    }
    CurrencySelectionMenu.show(style: .Formsheet, from: self)
    CurrencySelectionMenu.setSelectedItems(items: DefaultCoinDatasource.sharedInstance.currencie) { (cell, Selected, indexPath) in
        
       
        
        self.odd =  true
        let selected:[Currency] = indexPath as! [Currency]
        self.currencySelected = selected.last!
        self.changeCurrency.setBackgroundImage(self.currencySelected.image, for: .normal)
        self.getPriceForCryptos()
        
        
    }
}
func numberOfSections(in tableView: UITableView) -> Int
{
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return DefaultCoinDatasource.sharedInstance.cryptos.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveRatesTableViewCell", for: indexPath) as! LiveRatesTableViewCell
    cell.currencyImage.image = DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].image
    cell.cryptoName.text = DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].name
    cell.price.text = String(DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].price)
    cell.currencyImage.asCircle()
    return cell
    
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
}
func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveRatesHeaderTableViewCell") as! LiveRatesHeaderTableViewCell
    let price = currencySelected.iden
    cell.priceLabel.text = "Price" + "(" + price + ")"
    return cell
}
func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 60
}
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}
func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let delete = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in

        DefaultCoinDatasource.sharedInstance.cryptos.remove(at: indexPath.row)
        self.currencyTableView.reloadData()
        
    }
    return [delete]
}
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
    let add = UIAlertAction(title: "Pin to top", style: .default, handler: { (action) in
        
        DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].ispinnedToTop = true
        self.pinToTop(crypto: DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row])
        DefaultCoinDatasource.sharedInstance.cryptos.sort(by: { $0.ispinnedToTop && !$1.ispinnedToTop })

        self.currencyTableView.reloadData()
    })
    let remove = UIAlertAction(title: "Remove from list", style: .default, handler: { (action) in
        
        DefaultCoinDatasource.sharedInstance.cryptos.remove(at: indexPath.row)
        self.currencyTableView.reloadData()
    })
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
       actionSheet.addAction(add)
       actionSheet.addAction(remove)
    actionSheet.popoverPresentationController?.sourceView = self.view
    actionSheet.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.layer.bounds)!
    actionSheet.addAction(cancel)
    self.present(actionSheet, animated: true, completion: nil)
}

func pinToTop(crypto:Currency)
{
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Crypto")
    fetch.predicate = NSPredicate(format: "name == %@", crypto.name)
    let result = try? LiveCryptoDataBase.CoreDataStore.Context().fetch(fetch) as! [Crypto]
    for resultItem in result!
    {
     resultItem.is_monitored = true
    }
    
}

func getPriceForCryptos(){
    

    for crypto in DefaultCoinDatasource.sharedInstance.cryptos
    {
        
        fetchLiveRates(currency: crypto, selectedName: self.currencySelected.name)
        
    }

   
}

func fetchLiveRates(currency:Currency,selectedName:String)  {
   
     let fSysm = self.currencySelected.name
    
    let url = "https://min-api.cryptocompare.com/data/price?fsym=\(currency.iden)&tsyms=\(fSysm)"
    
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in

        if response.result.isSuccess {
        let json  = try? JSON(data: response.data!)
        currency.price = json![selectedName].double!
        
        self.currencyTableView.reloadData()
        }
        else{
            
            
        }
    }
}


func createAndLoadInterstitial() -> GADInterstitial
{
    
     intersitial = GADInterstitial(adUnitID: "ca-app-pub-4044308120454547/4088333101")
   
    intersitial.delegate = self
    intersitial.load(GADRequest())
    return intersitial

}

func populateData()  {
    
    DefaultCoinDatasource.sharedInstance.populateCryptos()
    // sort on pinned to top behaviour.
    DefaultCoinDatasource.sharedInstance.cryptos.sort(by: { $0.ispinnedToTop && !$1.ispinnedToTop })

    self.currencySelected = DefaultCoinDatasource.sharedInstance.currencie.first!

    currencyTableView.reloadData()
  
}


var intersitial: GADInterstitial!

override func viewWillAppear(_ animated: Bool) {
    populateData()
    
    getPriceForCryptos()
}
override func viewDidLoad() {
    super.viewDidLoad()
   DefaultCoinDatasource.sharedInstance.populateCurencies()
   
    // makes intersitial ready
       self.intersitial  =  createAndLoadInterstitial()
    
    CurrencySelectionMenu =  RSSelectionMenu(selectionType: .Single, dataSource: DefaultCoinDatasource.sharedInstance.currencie , cellType: .Custom(nibName: "CurrencyTableViewCell", cellIdentifier: "CurrencyTableViewCell")) { (cell, person, indexPath) in
        
        // cast cell to your custom cell type
        let customCell = cell as! CurrencyTableViewCell
        
        customCell.nameOfCurrency.text = DefaultCoinDatasource.sharedInstance.currencie[indexPath.row].iden
        customCell.IdentifierOfCurrency.text = DefaultCoinDatasource.sharedInstance.currencie[indexPath.row].name
        customCell.imageOfCurrency.image  = UIImage(named:DefaultCoinDatasource.sharedInstance.currencie[indexPath.row].name.lowercased())
        // set cell data here
    }
    CurrencySelectionMenu.uniquePropertyName = "name"
    
    // Do any additional setup after loading the view.
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}


/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
}
*/

}
