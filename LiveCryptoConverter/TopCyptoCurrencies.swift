//
//  CoinsViewController.swift
//  LiveCryptoConverter
//
//  Created by MacBook on 12/6/1396 AP.
//  Copyright © 1396 MacBook. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection
import SwiftyJSON
import AlamofireImage
import CoreData
import GoogleMobileAds
import Gzip
import SKActivityIndicatorView


   // DTO
class coin: EVObject {

var symbol:String?
var ImageUrl:String?
var name:String?
var image = UIImage(named:"not-available-circle")
    // default image
var price_usd:String?
    
}

class CoinName: EVObject {

var name:coin = coin()

}

class ResponseObject: EVObject {

var BaseImageUrl:String?
var data:[CoinName] = []

}




class TopCyptoCurrencies: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,GADBannerViewDelegate,GADInterstitialDelegate {


@IBOutlet weak var bannerView: GADBannerView!
@IBOutlet weak var cryptoSearchBar: UISearchBar!

@IBOutlet weak var CryptoCollectionView: UICollectionView!

    let queue = DispatchQueue(label: "please.don't.block.my.UI.:P", qos: .background, attributes: .concurrent)

var shouldShowfiltered = false
var coins:[coin] = []
var filteredcoid:[coin] = []
var intersitial: GADInterstitial!
    
func getTopCoinsWithKeyword(){
    // activity indicator
SKActivityIndicator.show(" Fetching Market Top Cryptos ")

    // I use this api get coin name and keyword.
let url = "https://api.coinmarketcap.com/v1/ticker/?start=0&limit=200"

Alamofire.request(url, method: .get, parameters: nil
    , encoding: JSONEncoding.default, headers: nil).responseJSON(queue: queue)
    { (response) in
        print(response)
        
        
        let data = String(data:response.data!,encoding:String.Encoding.ascii) // json string
        let listOfCoins = [coin](json:data)
        self.coins = listOfCoins
        SKActivityIndicator.dismiss()
        
        DispatchQueue.main.async {
                self.CryptoCollectionView.reloadData()
                self.getCoinsDataWithImageUrl()
        }
     
}

}


func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if shouldShowfiltered {return filteredcoid.count}else{
        
    return self.coins.count
    }
}
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // showing search result.
    if shouldShowfiltered {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinsCollectionViewCell", for: indexPath) as! CoinsCollectionViewCell
        cell.coinImage.image = filteredcoid[indexPath.row].image
        cell.coinlabel.text = filteredcoid[indexPath.row].name
        cell.iden.text =  filteredcoid[indexPath.row].symbol
        cell.coinImage.asCircle()
        return cell
    }
    else{
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinsCollectionViewCell", for: indexPath) as! CoinsCollectionViewCell
    cell.coinImage.image = coins[indexPath.row].image
    cell.coinlabel.text = coins[indexPath.row].name
        cell.iden.text = coins[indexPath.row].symbol
    cell.coinImage.asCircle()
    return cell
}
}
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.view.frame.size.width/1.3, height: 70)
}
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if shouldShowfiltered {
        let actionSheet = UIAlertController(title: "Would You like to Monitor \(filteredcoid[indexPath.row].name!)", message: "Would You Like To Add \(filteredcoid[indexPath.row].name!) to Your Live Monitoring List", preferredStyle: .actionSheet)
        let add = UIAlertAction(title: "ADD", style: .default, handler: { (action) in
            
            self.setMonitored(coinn: self.filteredcoid[indexPath.row])
            if (self.intersitial.isReady) {
           
                self.intersitial.present(fromRootViewController: self)
                self.intersitial =  self.createAndLoadInterstitial()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(add)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    else {
        let actionSheet = UIAlertController(title: "Would You like to Monitor \(coins[indexPath.row].name!)", message:  "Add \(coins[indexPath.row].name!) to Your Live Monitoring List", preferredStyle: .actionSheet)
        let add = UIAlertAction(title: "ADD", style: .default, handler: { (action) in
            
            self.setMonitored(coinn: self.coins[indexPath.row])
            if (self.intersitial.isReady) {
                
                self.intersitial.present(fromRootViewController: self)
                self.intersitial =  self.createAndLoadInterstitial()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(add)
        actionSheet.addAction(cancel)
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = (collectionView.cellForItem(at: indexPath)?.bounds)!
        self.present(actionSheet, animated: true, completion: nil)
    }
}

func setMonitored(coinn:coin)  {
    
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Crypto")
    let result = try? LiveCryptoDataBase.CoreDataStore.Context().fetch(fetch) as! [Crypto]
    for cryptoo in result! {
        if cryptoo.symbol == coinn.symbol {
            cryptoo.is_monitored = true
             try? LiveCryptoDataBase.CoreDataStore.Context().save()
        }
    }
    
    
}

func getListFromCoreData()  {
    
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Crypto")
    let result = try? LiveCryptoDataBase.CoreDataStore.Context().fetch(fetch) as! [Crypto]
    
    if result?.count == 0 {
         getTopCoinsWithKeyword()
    }
    else{
        
        for cryptoo in result! {
            let coinn = coin()
            coinn.image = UIImage(data:cryptoo.imageData!)
            coinn.name = cryptoo.name
            coinn.symbol = cryptoo.symbol
             coins.append(coinn)

        }
        self.CryptoCollectionView.reloadData()
    }
    
    
}
override func viewDidLoad() {
    super.viewDidLoad()

    self.bannerView.delegate = self
    self.bannerView.rootViewController = self
    self.bannerView.adSize = kGADAdSizeBanner
    self.bannerView.adUnitID = "ca-app-pub-4044308120454547/4742939221"
    let request = GADRequest()
    
   self.intersitial =  createAndLoadInterstitial()
    self.bannerView.load(request)
    getListFromCoreData()
    // Do any additional setup after loading the view.
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    shouldShowfiltered = true
    self.filteredcoid = coins.filter({($0.name?.contains(searchText))!})
    self.CryptoCollectionView.reloadData()
}
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.shouldShowfiltered = false
    self.cryptoSearchBar.resignFirstResponder()
    CryptoCollectionView.reloadData()
}
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.cryptoSearchBar.resignFirstResponder()
    self.shouldShowfiltered = false
    CryptoCollectionView.reloadData()
}


var json:JSON?
var baseImageUrl:String?
func extractBaseUrl()  {
    
    baseImageUrl = json!["BaseImageUrl"].string
    self.jsonData = self.json!["Data"]
   
    for crypto in self.coins
    {
    extractImageUr(crypto: crypto)
    getImage(crypto: crypto)
    }
   
}
var jsonData:JSON?
func extractImageUr(crypto:coin)  {

    let coinData = jsonData![crypto.symbol!]
    
    crypto.ImageUrl = coinData["ImageUrl"].string
  
}
    
func getCoinsDataWithImageUrl()  {
    
    Alamofire.request("https://min-api.cryptocompare.com/data/all/coinlist", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: defaultHeaders).responseJSON { (response) in
       
        if response.result.isSuccess{
            self.json = try? JSON(data: response.data!)
            self.extractBaseUrl()
            
        }
        
        
    }
    
    
 
    
}
    // : gzip header reduces size - A7 processors  or iphone 6 can handle this.
    
lazy var defaultHeaders: [String: String] = {
 
    let acceptEncoding: String = "Accept-Encoding: gzip;q=1.0,compress;q=0.5"

    return ["Accept-Encoding": acceptEncoding]
}()

    
    // get Image for each crypto
func getImage(crypto:coin)  {
    
    if (crypto.ImageUrl == nil){
        return
        
    }
    
    let url = self.baseImageUrl! + crypto.ImageUrl!
Alamofire.request(url, method: .get).responseImage { response in
    
guard let image = response.result.value else {
// Handle error
return
}
     crypto.image = image
    
    self.storeToCoreData(crypto: crypto)
    
    self.CryptoCollectionView.reloadData()
    
}
}



func storeToCoreData(crypto:coin)

{
    
let cryptoManaged  = NSEntityDescription.insertNewObject(forEntityName: "Crypto", into: LiveCryptoDataBase.CoreDataStore.Context()) as! Crypto
    cryptoManaged.name = crypto.name
     let imagedata = UIImageJPEGRepresentation(crypto.image!, 0.0)
    cryptoManaged.imageData = imagedata
    cryptoManaged.symbol = crypto.symbol // keyword import for getting rates.
    cryptoManaged.is_monitored = false
    
    try? LiveCryptoDataBase.CoreDataStore.Context().save()
    
    
}
    

func createAndLoadInterstitial() -> GADInterstitial {
    
    intersitial = GADInterstitial(adUnitID: "ca-app-pub-4044308120454547/4088333101")
    
    intersitial.delegate = self
    intersitial.load(GADRequest())
    return intersitial
    
}

}



extension UIImageView
{
    // circle the image : used to circle currencies icons
func asCircle(){
    
    self.layer.cornerRadius = self.frame.width / 2;
    self.layer.masksToBounds = true
}

}
extension UICollectionView {

    // show a text when collection view is empty
func setEmptyMessage(_ message: String) {
    let messageLabel = UILabel(frame: CGRect(x: 0, y: self.frame.origin.y + 100 , width: self.bounds.size.width, height: self.bounds.size.height/2))
    messageLabel.text = message
    messageLabel.textColor = .black
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = .center;
    messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
    messageLabel.textColor = UIColor.white
    messageLabel.sizeToFit()
    
    self.backgroundView = messageLabel;
}

func restore() {
    // restore the empty message when collection view got items
    self.backgroundView = nil
}
}

