//
//  RSCollectionView.swift
//  RSImageCrawler
//
//  Created by shenzw on 4/20/16.
//  Copyright © 2016 shenzw. All rights reserved.
//

import UIKit
import SDWebImage

class RSCollectionView: UIView,UICollectionViewDelegate, UICollectionViewDataSource{
    typealias finishBlock = (status:Int,data:AnyObject) ->()
    typealias RSTransBlock = (status:Int,data:AnyObject) ->()
    var transBlock:RSTransBlock?
    var resultBlock:finishBlock?
    var urlArray:[String] = [String]()
    var collectionView:UICollectionView!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: self.frame.size.width,height: self.frame.size.height)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView = UICollectionView.init(frame:CGRectMake(0,0,kScreenWidth, self.frame.size.height), collectionViewLayout: flow)
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib.init(nibName: "RSImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "RSImageCollectionCell")
        self.addSubview(collectionView)
        let tapGes = UITapGestureRecognizer.init(target: self, action:#selector(RSCollectionView.cellClick))
        collectionView.addGestureRecognizer(tapGes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadWithArray(urlArray:[String]){
        self.urlArray = urlArray
        collectionView.reloadData()
    }
    
    func moveToIndex(index:Int){
        let indexPath = NSIndexPath.init(forRow:index, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    }
    
    func cellClick(){
        self.transBlock?(status: 1,data: "")
    }
    
    func cellDownload(sender: UIButton){
        let indexPath = NSIndexPath.init(forRow: sender.tag, inSection: 0)
        let selectedCell = self.collectionView.cellForItemAtIndexPath(indexPath) as! RSImageCollectionCell
        UIImageWriteToSavedPhotosAlbum(selectedCell.centerImageView.image!, self, #selector(RSSideImageView.image(_:didFinishSavingWithError:contextInfo:)), nil)
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
    
    // CollectionView行数
    func collectionView(collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return self.urlArray.count
    }
    
    // 获取单元格
    func collectionView(collectionView: UICollectionView,cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RSImageCollectionCell", forIndexPath: indexPath) as! RSImageCollectionCell
        cell.backgroundColor = UIColor.clearColor()
        cell.centerImageView.backgroundColor = UIColor.clearColor()
        let thisUrl = self.urlArray[indexPath.row]
        cell.centerImageView?.sd_setImageWithURL(NSURL(string:thisUrl), placeholderImage:nil, options: SDWebImageOptions.RefreshCached)
        cell.downButton.addTarget(self, action: #selector(self.cellDownload(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.downButton.tag = indexPath.row
        
        return cell
    }
    
    // 单元格点击响应
    func collectionView(collectionView: UICollectionView,didSelectItemAtIndexPath indexPath: NSIndexPath){
    }
}
