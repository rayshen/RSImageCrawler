//
//  RSSideImageView.swift
//  RSImageCrawler
//
//  Created by shenzw on 4/19/16.
//  Copyright © 2016 shenzw. All rights reserved.
//

import UIKit
import SDWebImage

class RSSideImageView: UIView,UITableViewDelegate,UITableViewDataSource{
    typealias finishBlock = (status:Int,data:AnyObject) ->()
    typealias RSTransBlock = (index:Int,data:AnyObject) ->()
    var transBlock:RSTransBlock?
    var resultBlock:finishBlock?
    var sideTableView:UITableView!
    var urlArray:[String] = [String]()
    var downloadBtn:UIButton?
    var selectedCell:RSImageTableCell!
    var failSum = 0

    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        downloadBtn = UIButton.init(frame: CGRectMake(0, 0, self.frame.size.width, 44))
        downloadBtn?.backgroundColor = MainThemeColor
        downloadBtn?.setTitle("一键保存", forState: UIControlState.Normal)
        downloadBtn?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        downloadBtn?.addTarget(self, action: #selector(self.download), forControlEvents: UIControlEvents.TouchUpInside)
//        self.addSubview(downloadBtn!)
        sideTableView = UITableView.init(frame: CGRectMake(0,0, self.frame.size.width, self.frame.size.height))
        sideTableView.tableFooterView = UIView()
        sideTableView.backgroundColor = UIColor.clearColor()
        sideTableView.registerNib(UINib(nibName:"RSImageTableCell",bundle:nil),forCellReuseIdentifier:"myCell")
        sideTableView.delegate = self
        sideTableView.dataSource = self
        self.addSubview(sideTableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshContent(urlArray:[String]){
        self.urlArray = urlArray
    }
    
    func reloadData(){
        self.sideTableView.reloadData()
    }
    
    func download(){
        weak var weakself = self
        self.failSum = 0
        self.resultBlock?(status: -1,data: "保存中...")
        var sum = 0
        for index in 0...self.urlArray.count-1{
            sum += 1
            let imgView = UIImageView()
            imgView.sd_setImageWithURL(NSURL(string:self.urlArray[index]), completed: { (theImage, NSError, SDImageCacheType, NSURL) in
                UIImageWriteToSavedPhotosAlbum(theImage, weakself,#selector(RSSideImageView.imageSave(_:didFinishSavingWithError:contextInfo:)), nil)
                weakself?.delayToDoInMain(0, finish: {
                    if(sum == self.urlArray.count){
                        let num = (weakself?.failSum)! as Int
                        weakself?.resultBlock?(status: 2 ,data: "保存成功,失败\(num)张")
                    }
                })
            })
        }
    }
    
    func cellDownload(sender: UIButton){
        let indexPath = NSIndexPath.init(forRow: sender.tag, inSection: 0)
        selectedCell = self.sideTableView.cellForRowAtIndexPath(indexPath) as! RSImageTableCell
        UIImageWriteToSavedPhotosAlbum(selectedCell.centerImageView.image!, self, #selector(RSSideImageView.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func imageSave(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            self.failSum += 1
            print("错误")
//            self.resultBlock?(status: 0,data: "保存失败")
        }else{
            print("保存成功")
//            self.resultBlock?(status: 1,data: "保存成功")
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        self.resultBlock?(status: -1,data: "保存中...")
        if didFinishSavingWithError != nil {
            print("错误")
            self.resultBlock?(status: 0,data: "保存失败")
        }else{
            print("保存成功")
            self.resultBlock?(status: 1,data: "保存成功")
        }
    }
    
    //在本例中，只有一个分区
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //返回表格行数（也就是返回控件数）
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlArray.count
    }
    
    //单元格高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)
        -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! RSImageTableCell
        return indexPath
    }
    
    //创建各单元显示内容(创建参数indexPath指定的单元）
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell:RSImageTableCell = tableView.dequeueReusableCellWithIdentifier("myCell") as! RSImageTableCell
        cell.centerImageView?.clipsToBounds = true
        let thisUrl = self.urlArray[indexPath.row]
        cell.originUrl = thisUrl
        cell.centerImageView?.sd_setImageWithURL(NSURL(string:thisUrl), placeholderImage:nil, options: SDWebImageOptions.RefreshCached)
        cell.downButton.addTarget(self, action: #selector(self.cellDownload(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.downButton.tag = indexPath.row
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! RSImageTableCell
        print(selectedCell.originUrl)
        self.transBlock?(index:indexPath.row,data:self.urlArray)
    }
}
