//
//  ViewController.swift
//  LiveCryptoConverter
//
//  Created by MacBook on 12/4/1396 AP.
//  Copyright © 1396 MacBook. All rights reserved.
//

import UIKit
import  Alamofire
import SwiftyJSON
import RSSelectionMenu
import GoogleMobileAds

class ViewController: UIViewController,UITextFieldDelegate,GADBannerViewDelegate {


@IBOutlet weak var bannerViewFromStoryBoard: GADBannerView!
@IBOutlet weak var bannerView: UIView!
@IBOutlet weak var sourceView: UIView!

@IBOutlet weak var destTextField: UIView!
@IBOutlet weak var srcTextFView: UIView!
@IBOutlet weak var destView: UIView!
@IBOutlet weak var sourceLabel: UILabel!

@IBOutlet weak var destinationLabel: UILabel!
@IBOutlet weak var destinationTextField: UITextField!
@IBOutlet weak var sourceTextField: UITextField!
@IBOutlet weak var destinationDropDown: UIButton!
@IBOutlet weak var sourceDropDown: UIButton!
@IBOutlet weak var destinationImage: UIImageView!
@IBOutlet weak var sourceImage: UIImageView!

var conversionFactor = 0.0

func getConvertedRatesFromAPI()  {
    
    let url = "https://min-api.cryptocompare.com/data/price?fsym=\(self.sourceLabel.text!)&tsyms=\(self.destinationLabel.text!)"
    Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
        print(response)
        
        if response.result.isSuccess
        {
        let json  = try? JSON(data: response.data!)
        let currency = self.destinationLabel.text!
        self.conversionFactor = json![currency].double!
        }
        
    }
    
}







@IBAction func destinationButtonAction(_ sender: Any) {
    
    CurrencySelectionMenu.show(style: .Formsheet, from: self)
    self.sourceTextField.text = ""
    self.destinationTextField.text = ""
    
}

@IBAction func sourceButtonAction(_ sender: Any) {
    cryptosSelectionMenu.show(style: .Formsheet, from: self)
    self.sourceTextField.text = ""
    self.destinationTextField.text = ""
}

func setDefaultFields() {
    
    self.sourceImage.image =  (DefaultCoinDatasource.sharedInstance.cryptos.first?.image)
    self.sourceLabel.text = DefaultCoinDatasource.sharedInstance.cryptos.first?.iden
    self.destinationImage.image  = (DefaultCoinDatasource.sharedInstance.currencie.first?.image)
    self.destinationLabel.text = DefaultCoinDatasource.sharedInstance.currencie.first?.name
    self.sourceTextField.placeholder = "Enter Quantity"
    
}

func populateData()  {
    
    DefaultCoinDatasource.sharedInstance.populateCryptos()
    DefaultCoinDatasource.sharedInstance.populateCurencies()
}
@objc func srcTextFieldDidChange(_ textField: UITextField) {
    
    if !((textField.text?.isEmpty)!) {
        let value = Double(textField.text!)
        self.destinationTextField.text = String(value! * conversionFactor)
    }
}
@objc func destTextFieldDidChange(_ textField: UITextField) {
    if !((textField.text?.isEmpty)!) {
        let value = Double(textField.text!)
        self.sourceTextField.text = String(value! / conversionFactor)
    }
}
@objc func showView(){
    cryptosSelectionMenu.show(style: .Formsheet, from: self)
    self.sourceTextField.text = ""
    self.destinationTextField.text = ""
}
@objc func showDest(){
    CurrencySelectionMenu.show(style: .Formsheet, from: self)
    self.sourceTextField.text = ""
    self.destinationTextField.text = ""
}

func setTapGestures()  {
    let tapGest = UITapGestureRecognizer(target: self, action: #selector(self.showView))
    
    self.sourceView.addGestureRecognizer(tapGest)
    
    let tapGest2 = UITapGestureRecognizer(target: self, action: #selector(self.showDest))

    self.destView.addGestureRecognizer(tapGest2)
    
}
var cryptosSelectionMenu = RSSelectionMenu<Any>()
 var CurrencySelectionMenu = RSSelectionMenu<Any>()
override func viewDidLoad() {
    super.viewDidLoad()
    
 setTapGestures()
    
    self.bannerViewFromStoryBoard.delegate = self
    self.bannerViewFromStoryBoard.rootViewController = self
    self.bannerViewFromStoryBoard.adSize = kGADAdSizeBanner
    self.bannerViewFromStoryBoard.adUnitID = "ca-app-pub-4044308120454547/4742939221"
    let request = GADRequest()


    self.bannerViewFromStoryBoard.load(request)
//
    self.sourceTextField.addTarget(self, action: #selector(ViewController.srcTextFieldDidChange(_:)),
                        for: UIControlEvents.editingChanged)
    self.destinationTextField.addTarget(self, action: #selector(ViewController.destTextFieldDidChange(_:)),
                                   for: UIControlEvents.editingChanged)
    self.sourceTextField.delegate = self
    self.destinationTextField.delegate = self
    populateData()
    setDefaultFields()
    getConvertedRatesFromAPI()
    
     cryptosSelectionMenu =  RSSelectionMenu(selectionType: .Single, dataSource: DefaultCoinDatasource.sharedInstance.cryptos , cellType: .Custom(nibName: "CurrencyTableViewCell", cellIdentifier: "CurrencyTableViewCell")) { (cell, person, indexPath) in
        
        // cast cell to your custom cell type
        let customCell = cell as! CurrencyTableViewCell
        
        customCell.nameOfCurrency.text = DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].name
        customCell.IdentifierOfCurrency.text = DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].iden
        customCell.imageOfCurrency.image  = DefaultCoinDatasource.sharedInstance.cryptos[indexPath.row].image
        // set cell data here
    }
    cryptosSelectionMenu.uniquePropertyName = "name"
    
    
    
    
    CurrencySelectionMenu =  RSSelectionMenu(selectionType: .Single, dataSource: DefaultCoinDatasource.sharedInstance.currencie , cellType: .Custom(nibName: "CurrencyTableViewCell", cellIdentifier: "CurrencyTableViewCell")) { (cell, person, indexPath) in
        
        // cast cell to your custom cell type
        let customCell = cell as! CurrencyTableViewCell
        
        customCell.nameOfCurrency.text = DefaultCoinDatasource.sharedInstance.currencie[indexPath.row].iden
        customCell.IdentifierOfCurrency.text = DefaultCoinDatasource.sharedInstance.currencie[indexPath.row].name
        customCell.imageOfCurrency.image  = UIImage(named:DefaultCoinDatasource.sharedInstance.currencie[indexPath.row].name.lowercased())
        // set cell data here
    }
    CurrencySelectionMenu.uniquePropertyName = "name"
    
    cryptosSelectionMenu.setSelectedItems(items: DefaultCoinDatasource.sharedInstance.cryptos) { (cell, Selected, indexPath) in
        
        let selected:[Currency] = indexPath as! [Currency]
        self.sourceImage.image = (selected.last?.image)
        self.sourceLabel.text = selected.last?.iden
        self.getConvertedRatesFromAPI()
        
    }
    CurrencySelectionMenu.setSelectedItems(items: DefaultCoinDatasource.sharedInstance.currencie) { (cell, Selected, indexPath) in
        
        let selected:[Currency] = indexPath as! [Currency]
        self.destinationImage.image = (selected.last?.image)
        self.destinationLabel.text = selected.last?.name
        self.getConvertedRatesFromAPI()
        
    }
    
    
    
}

func setViews()  {
    
    self.sourceView.layer.borderWidth = 1
    self.sourceView.layer.borderColor = UIColor.white.cgColor
    self.destView.layer.borderWidth = 1
    self.destView.layer.borderColor = UIColor.white.cgColor
    self.srcTextFView.layer.borderWidth = 1
    self.srcTextFView.layer.borderColor = UIColor.white.cgColor
    self.destTextField.layer.borderWidth = 1
    self.destTextField.layer.borderColor = UIColor.white.cgColor
    sourceTextField.attributedPlaceholder = NSAttributedString(string:" Enter Quantity",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
}

override func viewWillLayoutSubviews() {
    setViews()
 
}

func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("Banner  Loaded Successfully")
    
}
func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
    print("Error \(error)")
}
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.sourceTextField.resignFirstResponder()
    self.destinationTextField.resignFirstResponder()
}


}

