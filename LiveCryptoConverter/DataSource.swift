//
//  Data.swift
//  LiveCryptoConverter
//
//  Created by MacBook on 12/4/1396 AP.
//  Copyright © 1396 MacBook. All rights reserved.
//




import UIKit
import CoreData

class Currency: NSObject {
    
    var name = String()
    var iden = String()
    var price = 0.0
    var image = UIImage()
    var ispinnedToTop = false

    
    override init() {
        
    }
    init(name:String,iden:String,isCoreData:Bool,data:Data,isCurrency:Bool) {
        self.name = name
        self.iden = iden
        
        if isCoreData
        {
            
            self.image = UIImage(data:data)!
            
        }
        else
        {
            if isCurrency {
                
            self.image = UIImage(named:name.lowercased())!
                
            }
            else {
                self.image = UIImage(named:iden.lowercased())!

            }
            
        }
        
    }
    init(name:String,iden:String,isCoreData:Bool,data:Data,isCurrency:Bool,ispinned:Bool) {
        
        self.name = name
        self.iden = iden
        self.image = UIImage(data:data)!
        self.ispinnedToTop = ispinned

        
    }
    
    
    
}

class DataSource: NSObject {
    
    
   lazy var cryptos:[Currency] = []
   lazy var currencie:[Currency] = []
    
    static var sharedInstance:DataSource = {
        return DataSource()
    }()
    
    func populateCryptos()
    {
    
        self.cryptos.removeAll()
        self.cryptos.append(Currency(name:"Bitcoin",iden:"BTC",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Ethereum",iden:"ETH",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Litecoin",iden:"LTC",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Stellar",iden:"XLM",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Bitcoin Cash",iden:"BCH",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"ZCash",iden:"ZEC",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"NEO",iden:"NEO",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Monero",iden:"XMR",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Ripple",iden:"XRP",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"EOS",iden:"EOS",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"NEM",iden:"XEM",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Verge",iden:"XVG",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Vcash",iden:"XVC",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"Ethereum Classic",iden:"ETC",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"ARK",iden:"ARK",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"NavCoin",iden:"NAV",isCoreData:false,data:Data(),isCurrency:false))
        self.cryptos.append(Currency(name:"PotCoin",iden:"POT",isCoreData:false,data:Data(),isCurrency:false))
         let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Crypto")
        let result = try? LiveCryptoDataBase.CoreDataStore.Context().fetch(fetch) as! [Crypto]
        
        for cryptoo in result! {


            if cryptoo.is_monitored
            {
                self.cryptos.append(Currency(name: cryptoo.name!, iden: cryptoo.symbol!, isCoreData: true, data: cryptoo.imageData!,isCurrency:false,ispinned:cryptoo.is_monitored))
            }
        }
    
        
    
    }
    
    
    func populateCurencies()
    {
        
        self.currencie.removeAll()
        self.currencie.append(Currency(name: "USD", iden: "US Dollar",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "NGN", iden: "NG Naira",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "GBP", iden: "GB Pound",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "EUR", iden: "EU Euro",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "JPY", iden: "JP Yen",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "CAD", iden: "CA Dollar",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "AUD", iden: "AU Dollar",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "INR", iden: "IN Rupees",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "MYR", iden: "MY Ringgit",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "CNY", iden: "CN Yuan",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "NZD", iden: "NZ Dollar",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "KRW", iden: "SK Won",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "CHF", iden: "Swiss Franc",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "MXN", iden: "MX Peso",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "ZAR", iden: "SA Rand",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "IDR", iden: "ID Rupiah",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "EGP", iden: "EG Pound",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "GHS", iden: "GH Cedi",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "RUB", iden: "RU Ruble",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "HKD", iden: "HK Dollar",isCoreData:false,data:Data(),isCurrency:true))
        self.currencie.append(Currency(name: "PKR", iden: "PK Rupees",isCoreData:false,data:Data(),isCurrency:true))
    }
    

}
