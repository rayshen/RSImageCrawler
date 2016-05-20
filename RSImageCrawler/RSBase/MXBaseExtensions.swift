//
//  MXBaseExtensions.swift
//  WebMailSDK
//
//  Created by shenzw on 16/3/15.
//  Copyright © 2016年 51dojo. All rights reserved.
//

import UIKit
import MBProgressHUD

extension NSDictionary{
    //NSDictionary转String
    func toJsonString()->String{
        let data : NSData! = try? NSJSONSerialization.dataWithJSONObject(self, options: [])
        //NSData转换成NSString打印输出
        let str:String!=String(data:data, encoding: NSUTF8StringEncoding)
        //输出json字符串
        return str
    }
}

extension NSArray{
    //NSArray转String
    func toJsonString()->String{
        let data : NSData! = try? NSJSONSerialization.dataWithJSONObject(self, options: [])
        //NSData转换成NSString打印输出
        let str:String!=String(data:data, encoding: NSUTF8StringEncoding)
        //输出json字符串
        return str
    }
}

extension NSData {
    //NSData转Dic或Array
    func toJsonObject()->AnyObject{
        let json : AnyObject! = try? NSJSONSerialization
            .JSONObjectWithData(self, options:NSJSONReadingOptions.AllowFragments)
        return json
    }
}

extension String {
    //String转Dic或Array
    func toJsonObject()->AnyObject{
        let strData:NSData=self.dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObject=strData.toJsonObject()
        return jsonObject
    }
}

extension NSObject{
    func delayToDoInMain(timeValue:NSTimeInterval,finish:()->()){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSThread.sleepForTimeInterval(timeValue)
            dispatch_async(dispatch_get_main_queue()) {
                finish()
            }
        }
    }
    
    func delayToDoInThread(timeValue:NSTimeInterval,finish:()->()){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSThread.sleepForTimeInterval(timeValue)
            finish()
        }
    }
}

extension UIViewController{
    func alertMessage(mMessage:String){
        let alertController = UIAlertController(title:"提示",message:mMessage,preferredStyle:UIAlertControllerStyle.Alert)
        let alertAction=UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension UIView{
    func showHUD(text:String){
        let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
        hud.labelText = text
    }
    func hideHUD(){
        MBProgressHUD.hideHUDForView(self, animated: true)
    }
    func hideAllHUDs(){
        MBProgressHUD.hideAllHUDsForView(self, animated: true)
    }
}