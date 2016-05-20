//
//  RSImageFindService.swift
//  RSImageCrawler
//
//  Created by shenzw on 4/18/16.
//  Copyright © 2016 shenzw. All rights reserved.
//

import UIKit
import HTMLReader

class RSImageFindService: NSObject {
    typealias finishBlock = (status:Int,data:AnyObject) ->()

    class func findForHTMLStr(htmlStr:String,finish:finishBlock){
        RSNetBase.getRequest("http://www.cnblogs.com/rayshen/", params: nil, headersDic:nil) { (status, data) in
            //错误处理
            if(status == 0 ){
                return;
            }
            let dataStr = data as! String
            let document = HTMLDocument(string:dataStr)
            let pageResultArray = document.nodesMatchingSelector("img")
            for oneResult:HTMLElement in pageResultArray{
//                if(oneResult.hasClass("postTitle2")){
                    print(oneResult.attributes)
//                }
            }
            print(dataStr)
        }
    }
}
