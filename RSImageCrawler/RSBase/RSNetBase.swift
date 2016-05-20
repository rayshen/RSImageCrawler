//
//  RSNetBase.swift
//  RSImageCrawler
//
//  Created by shenzw on 4/18/16.
//  Copyright © 2016 shenzw. All rights reserved.
//

import UIKit
import Alamofire

class RSNetBase{
    typealias finishBlock = (status:Int,data:AnyObject) ->()
    
    class func getRequest(url:String, params: [String: AnyObject]?,headersDic:[String: String]?,finish:finishBlock){
        Alamofire.Manager.sharedInstance.request(.GET, url, parameters: params, headers:headersDic)
            .responseJSON { response in
                let data = response.data
                if(data != nil){
                    let jsonResult = String(data:data!, encoding: NSUTF8StringEncoding)
                    finish(status: 1 ,data:jsonResult!)
                }else{
                    finish(status: 0 ,data:"")
                }
        }
    }
    
    class func postRequest(url:String, params: [String: AnyObject]?,headersDic:[String: String]?,finish:finishBlock){
        Alamofire.Manager.sharedInstance.request(.POST, url, parameters: params, headers:headersDic)
            .responseJSON { response in
                let data = response.data
                if(data != nil){
                    let jsonResult = String(data:data!, encoding: NSUTF8StringEncoding)
                    finish(status: 1 ,data:jsonResult!)
                }else{
                    finish(status: 0 ,data:"")
                }
        }
    }
    
    // response json get request
    class func getRequestInJson(url:String, params: [String: AnyObject]?,headersDic:[String: String]?,finish:finishBlock){
        //let httpParams = paramsHandler(params)
        //        print("---------get request-------------")
        //        print("url:\(url)")
        //        print("params:\(params)")
        //        print("---------------------------------")
        Alamofire.Manager.sharedInstance.request(.GET, url, parameters: params, headers:headersDic)
            .responseJSON { response in
                let data = response.data
                let jsonResult = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if(jsonResult != nil){
                    finish(status: 1 ,data:jsonResult!)
                }else{
                    print("Request Fail")
                    finish(status: 0 ,data:"")
                }
        }
    }
    
    // respone json post request
    class func postRequestInJson(url:String, params:[String: AnyObject]?,headersDic:[String: String]?,finish:finishBlock){
        //let httpParams = paramsHandler(params)
        //        print("---------post request-------------")
        //        print("url:\(url)")
        //        print("params:\(params)")
        //        print("----------------------------------")
        Alamofire.Manager.sharedInstance.request(.POST, url, parameters: params, encoding:.JSON, headers:headersDic)
            .responseJSON { response -> Void in
                let data = response.data
                do {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSObject
                    finish(status: 1 ,data:jsonResult)
                }
                catch
                {
                    print("Request Fail")
                    finish(status: 0 ,data:"")
                }
        }
    }
    
    class func requestWithURLSession(theUrl:String){
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: NSURL(string: theUrl)!)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("returnStr:\(string!)")
        })
        task.resume()
    }
}
