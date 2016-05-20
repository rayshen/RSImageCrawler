//
//  RSIndexViewController.swift
//  RSImageCrawler
//
//  Created by shenzw on 4/18/16.
//  Copyright © 2016 shenzw. All rights reserved.
//

import UIKit
import WebKit
import HTMLReader
import MBProgressHUD

class RSIndexViewController: UIViewController,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UITextFieldDelegate,UIScrollViewDelegate{
    
    var baseUrl = "https://www.baidu.com/"
    var curUrl = ""
    var webConf = WKWebViewConfiguration()
    var webView:WKWebView!
    var progressView:UIProgressView!
    var testField:UITextField!
    var flowButton:UIButton!
    var bottomToolBar:UIToolbar!
    var sideView:RSSideImageView!
    var fullImageView:RSCollectionView!
    var imageUrlArray:[String]?
    var sideIsShow:Bool = false
    var hud:MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        ADService.sharedInstance().showFullScreenAD(self)
        setupNavigation()
        setupWebView()
        setupBrowserToolbar()
        setupSideTableView()
        startLoadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /***************************ViewSettings start********************/
    func setupNavigation(){
        self.navigationController?.navigationBar.barTintColor = MainThemeColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.view.backgroundColor = UIColor(red: 49.0/255.0, green: 159.0/255.0, blue: 222.0/255.0, alpha:1)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "mx-icon-back"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.gotoBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(self.refreshWebView))
        
        self.testField = UITextField.init(frame: CGRectMake(40, 0, kScreenWidth - 80, 25))
        self.testField.autocapitalizationType = UITextAutocapitalizationType.None
        self.testField.text = self.baseUrl
        self.testField.tintColor = MainThemeColor
        self.testField.returnKeyType = UIReturnKeyType.Go
        self.testField.backgroundColor = UIColor.whiteColor()
        self.testField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        self.testField.delegate = self
        self.navigationItem.titleView = self.testField
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.lightGrayColor()
    }
    
    func setupWebView(){
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressView.frame = CGRectMake(0,64,UIScreen.mainScreen().bounds.width,22)
        progressView.tintColor = UIColor.greenColor()
        self.view.addSubview(progressView)
        webView = WKWebView(frame: CGRectMake(0,64,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height-88), configuration: webConf)
        self.view.insertSubview(webView, belowSubview: progressView)
        
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.navigationDelegate = self
        webView.UIDelegate = self
        webView.scrollView.delegate = self
        webView.scrollView.bounces = false
        
        //JavaScript回调APP
        webConf.userContentController.addScriptMessageHandler(self, name:"mxBack")
        webConf.userContentController.addScriptMessageHandler(self, name:"mxAppNotiction")
    }
    
    func setupBrowserToolbar()
    {
        bottomToolBar =  UIToolbar(frame:CGRectMake(0, kScreenHeight-44, kScreenWidth, 44))
        bottomToolBar.barTintColor = MainThemeColor
        self.view.addSubview(bottomToolBar)
        
        let centerButton = UIBarButtonItem.init(title: "嗅一嗅", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.flowTableView))
        centerButton.tintColor = UIColor.whiteColor()
        bottomToolBar.setItems([centerButton],animated: true)
    }
    
    func setupSideTableView(){
        weak var weakself=self
        sideView = RSSideImageView(frame: CGRectMake(kScreenWidth,64, kScreenWidth*0.6, kScreenHeight-64))
        self.view.insertSubview(sideView, aboveSubview: bottomToolBar)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(RSIndexViewController.handleSwipeGesture(_:)))
        self.view.addGestureRecognizer(swipeGesture)
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(RSIndexViewController.handleSwipeGesture(_:)))
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left //不设置是右
        self.view.addGestureRecognizer(swipeLeftGesture)
        
        self.fullImageView = RSCollectionView.init(frame: CGRectMake(0,64, kScreenWidth, kScreenHeight-64))
        fullImageView.hidden = true
        self.view.addSubview(self.fullImageView)
        fullImageView.transBlock = { status,data in
            weakself?.fullImageView.hidden = true
        }
        
        
        fullImageView.resultBlock = { status,data in
            weakself?.showIndicator(status, data: data)
        }
        
        sideView.resultBlock = { status,data in
            weakself?.showIndicator(status, data: data)
        }
        
        sideView.transBlock = { index,data in
            weakself?.fullImageView.reloadWithArray(data as! [String])
            weakself?.fullImageView.moveToIndex(index)
            weakself?.fullImageView.hidden = false
        }
    }
    
    func showIndicator(status:Int,data:AnyObject){
        weak var weakself=self
        if(status == -1){
            weakself?.hud=MBProgressHUD.init(view: self.view)
            weakself?.hud?.mode=MBProgressHUDMode.CustomView
            weakself?.view.addSubview(self.hud!)
            weakself?.hud?.customView=UIImageView(image: UIImage(named:"37x-Checkmark"))
            weakself?.hud?.labelText = data as! String
            weakself?.hud?.show(true)
        }else if(status == 0 ){
            weakself?.hud?.hide(true)
            weakself?.hud=MBProgressHUD.init(view: self.view)
            weakself?.hud?.mode=MBProgressHUDMode.CustomView
            weakself?.view.addSubview(self.hud!)
            weakself?.hud?.customView=UIImageView(image: UIImage(named:"37x-Checkmark"))
            weakself?.hud?.labelText = data as! String
            weakself?.hud?.show(true)
            weakself?.hud?.hide(true, afterDelay:0.5)
        }else if(status == 1){
            weakself?.hud?.hide(true)
            weakself?.hud=MBProgressHUD.init(view: self.view)
            weakself?.hud?.mode=MBProgressHUDMode.CustomView
            weakself?.view.addSubview(self.hud!)
            weakself?.hud?.customView=UIImageView(image: UIImage(named:"37x-Checkmark"))
            weakself?.hud?.labelText = data as! String
            weakself?.hud?.show(true)
            weakself?.hud?.hide(true, afterDelay:0.5)
        }else{
            weakself?.hud?.hide(true)
            weakself?.hud=MBProgressHUD.init(view: self.view)
            weakself?.hud?.mode=MBProgressHUDMode.CustomView
            weakself?.view.addSubview(self.hud!)
            weakself?.hud?.customView=UIImageView(image: UIImage(named:"37x-Checkmark"))
            weakself?.hud?.labelText = data as! String
            weakself?.hud?.show(true)
            weakself?.hud?.hide(true, afterDelay:2)
        }
    }
    
    func startLoadWebView(){
        var loadUrl = ""
        if(curUrl != ""){
            loadUrl = curUrl
        }else{
            loadUrl = baseUrl
        }
        let request = NSURLRequest(URL: NSURL(string:loadUrl)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 20)
        self.webView.loadRequest(request)
    }
    
    func gotoBack() {
        if(self.webView.canGoBack){
            self.webView.goBack()
        }
    }
    
    func cancelLoad(){
        self.webView.hideAllHUDs()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(self.refreshWebView))
        self.webView!.stopLoading()
    }
    
    func refreshWebView(){
        self.webView.hideAllHUDs()
        self.webView!.reload()
    }
    
    func flowTableView(){
        if(sideIsShow){
            hideSide()
        }else{
            weak var weakself = self
            let getHtmlJS = "document.documentElement.innerHTML";
            self.webView.evaluateJavaScript(getHtmlJS) { (AnyObject, NSError) in
                let htmlStr = AnyObject as! String
                let document = HTMLDocument(string:htmlStr)
                weakself?.filterImage(document)
            }
            sideView.reloadData()
            showSide()
        }
    }
    
    func showSide(){
        self.sideIsShow = true
        UIView.animateWithDuration(0.25) {
            self.sideView.frame = CGRectMake(kScreenWidth - kScreenWidth*0.6, 64, kScreenWidth*0.6, kScreenHeight)
        }
    }
    
    func hideSide(){
        self.sideIsShow = false
        UIView.animateWithDuration(0.25) {
            self.sideView.frame = CGRectMake(kScreenWidth,64, kScreenWidth*0.6, kScreenHeight)
        }
    }
    
    /*********************View Delegate start********************/
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        refreshNavigation()
        self.testField.text = self.webView.URL?.absoluteString
        //右上角变成叉叉
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(self.cancelLoad))
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        refreshNavigation()
        //右上角变成刷新按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(self.refreshWebView))
        weak var weakself = self
        self.testField.text = self.webView.URL?.absoluteString
        self.webView.hideAllHUDs()
        self.webView.showHUD("分析中")
        let getHtmlJS = "document.documentElement.innerHTML";
        self.webView.evaluateJavaScript(getHtmlJS) { (AnyObject, NSError) in
            self.webView.hideAllHUDs()
            let htmlStr = AnyObject as! String
            let document = HTMLDocument(string:htmlStr)
            weakself?.filterImage(document)
        }
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError){
       refreshNavigation()
        weak var weakself = self
        self.webView.hideAllHUDs()
        self.webView.showHUD("分析中")
        let getHtmlJS = "document.documentElement.innerHTML";
        self.webView.evaluateJavaScript(getHtmlJS) { (AnyObject, NSError) in
            self.webView.hideAllHUDs()
            let htmlStr = AnyObject as! String
            let document = HTMLDocument(string:htmlStr)
            weakself?.filterImage(document)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "title" {
            self.title = self.webView.title
        }
        if keyPath == "estimatedProgress" {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "mxBack"){
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func filterImage(document:HTMLDocument){
        let mutableArray = NSMutableArray()
        //先找img标签
        let imgSelectorArray = document.nodesMatchingSelector("img")
        for oneResult:HTMLElement in imgSelectorArray{
            //进行筛选,判断存在url链接的
            let resultStr = self.getImageUrl(oneResult, curAddr: (webView.URL?.absoluteString)!)
            if(resultStr != ""){
//                print("img: "+resultStr)
                mutableArray.addObject(resultStr)
            }
        }
        //再找a标签
        let aSelectorArray = document.nodesMatchingSelector("a")
        for oneResult:HTMLElement in aSelectorArray{
            let styleStr = oneResult.attributes["style"]
            if(styleStr != nil){
//                print(styleStr)
                var infoStr:NSString?
                let infoScanner = NSScanner(string: styleStr!)
                infoScanner.scanUpToString("url(", intoString: nil)
                infoScanner.scanUpToString("http", intoString: nil)
                infoScanner.scanUpToString(")", intoString: &infoStr)
                if(infoStr != nil){
//                    print("style: " + (infoStr! as String))
                    mutableArray.addObject(infoStr! as String)
                }
            }
        }
        
        self.imageUrlArray = mutableArray as NSArray as? [String]
        self.sideView.refreshContent(self.imageUrlArray!)
        sideView.reloadData()
    }
    
    func getImageUrl(oneResult:HTMLElement,curAddr:String)->String{
        var fullUrl = ""
        let srcStr = oneResult.attributes["src"]
        if(srcStr != nil){
            //直接就是该图片
            if(srcStr!.containsString("http")){
                fullUrl = srcStr!
            }else{
                //cdn形式
                if(srcStr!.hasPrefix("//")){
                    if(curAddr.hasPrefix("https")){
                        fullUrl = "https:" + srcStr!
                    }else{
                        fullUrl = "http:" + srcStr!
                    }
                    //根据相对位置的图片
                }else{
                    
                }
            }
        }
        //去除svg
        if(fullUrl.containsString(".svg")){
            fullUrl = ""
        }
        return fullUrl
    }
    
    func refreshNavigation(){
        if(!self.webView.canGoBack){
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.lightGrayColor()
        }else{
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        }
    }
    
    func cancelEdit(){
        if(self.webView.loading){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(self.cancelLoad))
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(self.refreshWebView))
        }
        var loadUrl = ""
        if(curUrl != ""){
            loadUrl = curUrl
        }else{
            loadUrl = baseUrl
        }
        self.testField.text = loadUrl
        self.testField.resignFirstResponder()
    }
    
    //划动手势
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        //划动的方向
        let direction = sender.direction
        //判断是上下左右
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            showSide()
            break
        case UISwipeGestureRecognizerDirection.Right:
            hideSide()
            break
        case UISwipeGestureRecognizerDirection.Up:
            break
        case UISwipeGestureRecognizerDirection.Down:
            break
        default:
            break;
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        let rightItemCancel = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancelEdit))
        self.navigationItem.rightBarButtonItem = rightItemCancel
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if(!self.testField.text!.containsString("http")){
            self.curUrl = "http://" + self.testField.text!
        }else{
            self.curUrl = self.testField.text!
        }
        self.curUrl = self.curUrl.stringByReplacingOccurrencesOfString(" ", withString: "")
        let request = NSURLRequest(URL: NSURL(string:self.curUrl)!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 20)
        self.webView.loadRequest(request)
        cancelEdit()
        return true
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        cancelEdit()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool){
    }
}
