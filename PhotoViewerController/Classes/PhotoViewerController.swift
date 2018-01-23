//
//  MediaViewerController.swift
//  MediaViewer
//
//  Created by botirjon nasridinov on 16/01/2018.
//  Copyright © 2018 INHA UNIVERSITY. All rights reserved.
//
import UIKit

public protocol PhotoViewerControllerDelegate {
    
    func photoViewer(imageView: UIImageView, at index: Int)
    
    func numberOfItems()->Int
    
    func topBarLeftItems(forItemAt index: Int)->[UIBarButtonItem]
    
    func topBarRightItems(forItemAt index: Int)->[UIBarButtonItem]
    
    func numberOfActions(forItemAt index: Int)->Int
    
    func actionBar(button: UIButton, at position: Int, forItemAt index: Int)
    
    func title(forItemAt index: Int) ->String
    
    func caption(forItemAt index: Int)->String
    
}


public class PhotoViewerController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var actionBar: UIView!
    @IBOutlet var topBar: UINavigationBar!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var captionView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var topGuide: UIView!
    
    
    // --------------------------------------------------------------------------------------//
    // constants
    // --------------------------------------------------------------------------------------//
    
    let dimBlackColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
    let shortAnimationDuration: TimeInterval = 0.2
    let mediumAnimationDuration: TimeInterval = 0.3
    
    
    // --------------------------------------------------------------------------------------//
    // public
    // --------------------------------------------------------------------------------------//
    
    public var delegate: PhotoViewerControllerDelegate?{
        didSet{
            numberOfImages = delegate?.numberOfItems() ?? 0
            numberOfActionsForItem = Array(repeating: 0, count: numberOfImages)
        }
    }
    public var initialItemIndex: Int = 0
    
    
    // --------------------------------------------------------------------------------------//
    // private
    // --------------------------------------------------------------------------------------//
    
    var isAlreadyArranged: Bool = false
    var collectionViewLayout: CollectionViewLayout?
    var actionsCount = 0
    var actionButtons = [UIButton]()
    var numberOfImages: Int = 0
    var cellAllocatingForTheFirstTime = true
    var numberOfActionsForItem = [Int]()
    var visibleIndex: Int = 0
    var currentIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    var currentItemWithCaption: Bool = false
    var contentViewTapped: Bool = false
    var alphaZeroByTap = false
    var captionExistForCurrentItem: Bool = false
    var lastOrientation: UIDeviceOrientation = UIDevice.current.orientation
    weak var navItem: UINavigationItem!
    
    
    // --------------------------------------------------------------------------------------//
    // init from nib
    // --------------------------------------------------------------------------------------//
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        var bundle: Bundle?
        let podBundle = Bundle(for: PhotoViewerController.self)
        if let bundleURL = podBundle.url(forResource: "PhotoViewerController", withExtension: "bundle"){
            bundle = Bundle(url: bundleURL)
        } else {
            assertionFailure("Could not create a path to the bundle")
        }
        super.init(nibName: "PhotoViewerController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // --------------------------------------------------------------------------------------//
    // override lifecycle m
    // --------------------------------------------------------------------------------------//
    
    override public func viewWillAppear(_ animated: Bool) {
        contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height)
        self.view.backgroundColor = UIColor.black
        
        if cellAllocatingForTheFirstTime == false{
            setupInitial()
        }
        
        lastOrientation = UIDevice.current.orientation
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewLayout = CollectionViewLayout()
        collectionView.collectionViewLayout = collectionViewLayout!
        
        configureTopBar()
        configureCaptionView()
        configureCollectionView()
        configureActionBar()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:)))
        self.view.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        self.contentView.addGestureRecognizer(tap)
        
        contentView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor.black
        collectionView.backgroundColor = UIColor.clear
        
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let  insets = self.collectionView.contentInset
        self.collectionView.contentInset = insets
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        if UIDevice.current.orientation != lastOrientation{
            self.collectionView.setContentOffset(CGPoint(x: self.view.frame.size.width * CGFloat(self.visibleIndex), y: 0), animated: false)
            self.lastOrientation = UIDevice.current.orientation
        }
    
        updateArrangement(in: actionBar, for: numberOfActionsForItem[visibleIndex])
    }
    
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.modalPresentationStyle == .overCurrentContext{
            self.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        guard let flowLayout = collectionView.collectionViewLayout as? CollectionViewLayout else {
            return
        }
        flowLayout.invalidateLayout()
        
    }
    
    
    override public var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override public var prefersStatusBarHidden: Bool{
        return false
    }
    
    // --------------------------------------------------------------------------------------//
    //
    // --------------------------------------------------------------------------------------//
    
    @objc func handleTapGesture(sender: UITapGestureRecognizer){
        
        if contentViewTapped{
            contentViewTapped = false
            setAlphaOnTap(alpha: 1.0)
            alphaZeroByTap = false
        }else{
            contentViewTapped = true
            setAlphaOnTap(alpha: 0.0)
            alphaZeroByTap = true
        }
    }
    
    func setAlphaOnTap(alpha: CGFloat){
        
        UIView.animate(withDuration: shortAnimationDuration) {
            self.topBar.alpha = alpha
            self.topGuide.alpha = alpha
            if alpha == 0{
                self.actionBar.alpha = alpha
                self.captionView.alpha = alpha
            }else{
                if self.currentItemWithCaption == true{
                    self.actionBar.alpha = alpha
                    self.captionView.alpha = alpha
                }
            }
        }
    }
    
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    func handleDissmiss(ended: Bool){
        if ended{
            // cancelled
            if alphaZeroByTap == false{
                self.topBar.alpha = 1.0
                self.topGuide.alpha = 1.0
                
                if currentItemWithCaption == true{
                    self.captionView.alpha = 1.0
                }
                
                if currentItemWithCaption == true{
                    self.actionBar.alpha = 1.0
                    if numberOfActionsForItem[visibleIndex] != 0{
                        self.actionBar.alpha = 1.0
                    }
                }
            }
            
            UIApplication.shared.statusBarStyle = .lightContent
            
        }else{
            // began
            self.actionBar.alpha = 0.0
            self.topBar.alpha = 0.0
            self.topGuide.alpha = 0.0
            self.captionView.alpha = 0.0
            
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        
        let _:CGFloat = 0.3
        
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            
            if touchPoint.y - initialTouchPoint.y > 0 {
                
                self.contentView.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
                
                let translation: CGFloat = touchPoint.y - initialTouchPoint.y
                let proportion: CGFloat = translation / 20.0
                
                if proportion < 1.0{
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0 - proportion)
                    
                }else if proportion > 1.0{
                    self.view.backgroundColor = UIColor.clear
                }
                
                UIView.animate(withDuration: shortAnimationDuration, animations: {
                    self.handleDissmiss(ended: false)
                })
            }else{
                self.view.backgroundColor = UIColor.black
                self.contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        }
        else if sender.state == UIGestureRecognizerState.ended || sender.state ==
            UIGestureRecognizerState.cancelled {
            
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.topBar.isHidden = true
                self.topGuide.isHidden = true
                self.dismiss(animated: true, completion: {
                    self.topBar.isHidden = false
                    self.topGuide.isHidden = false
                    
                })
            } else {
                
                UIView.animate(withDuration: shortAnimationDuration, animations: {
                    self.handleDissmiss(ended: true)
                })
                
                UIView.animate(withDuration: mediumAnimationDuration, animations: {
                    self.contentView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
                    self.view.backgroundColor = UIColor.black
                })
            }
        }
    }
    
    
    func configureCaptionView(){
        captionLabel.lineBreakMode = .byTruncatingTail
        captionLabel.numberOfLines = 0
        captionLabel.textColor = UIColor.white
        captionLabel.backgroundColor = UIColor.clear
        captionLabel.adjustsFontSizeToFitWidth = false
        
        captionView.isUserInteractionEnabled = false
        captionView.backgroundColor = dimBlackColor
    }
    
    
    func configureTopBar(){
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topGuide.backgroundColor = dimBlackColor
        topGuide.translatesAutoresizingMaskIntoConstraints = false
        
        topBar.setBackgroundImage(UIImage(), for: .default)
        topBar.shadowImage = UIImage()
        topBar.tintColor = UIColor.white
        topBar.isTranslucent = true
        topBar.backgroundColor = dimBlackColor
    }
    
    func configureActionBar(){
        actionBar.backgroundColor = dimBlackColor
    }
    
    func configureCollectionView(){
        collectionView.backgroundColor = UIColor.black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    /* ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...... ... ... ... ... ... ... ... ... ... */
    
    func configButton(at position: Int, forItemAt index: Int){
        delegate?.actionBar(button: actionButtons[position], at: position, forItemAt: index)
        
        if let image = actionButtons[position].backgroundImage(for: .normal){
            actionButtons[position].setBackgroundImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        if let image = actionButtons[position].image(for: .normal){
            actionButtons[position].setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func calculateSpacing(for numberOfItems: Int, ofWidth: CGFloat, inWidth: CGFloat, withMargin: CGFloat)->CGFloat{
        
        let flexibleSpace = inWidth - (2 * ofWidth + 2 * withMargin)
        let floatingItemsCount = numberOfItems - 2
        let freeSpace = flexibleSpace - CGFloat(floatingItemsCount) * ofWidth
        let spacing = freeSpace / CGFloat(floatingItemsCount + 1)
        
        return spacing
    }
    
    func calculateSpacing(for numberOfItems: Int, of width: CGFloat, in view: UIView, with margin: CGFloat) -> CGFloat{
        
        let flexibleSpace = view.frame.width - (2 * width + 2 * margin)
        let floatingItemsCount = numberOfItems - 2
        let freeSpace = flexibleSpace - CGFloat(floatingItemsCount) * width
        let spacing = freeSpace / CGFloat(floatingItemsCount + 1)
        
        return spacing
    }
    
    func makeButton(frame: CGRect)->UIButton{
        let button = UIButton(frame: frame)
        button.backgroundColor = UIColor.clear
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.tintColor = UIColor.white
        
        return button
    }
    
    func arrange(numberOfItems: Int, in view: UIView){
        
        let width: CGFloat = 25
        let margin: CGFloat = 16
        
        let spacing = calculateSpacing(for: numberOfItems, of: width, in: actionBar, with: margin)
        let topMargin = (view.frame.height - width) / 2
        
        if numberOfItems > 1{
            for i in 0..<numberOfItems{
                let x = margin + (spacing + width) * CGFloat(i)
                let button = makeButton(frame: CGRect(x: x, y: topMargin, width: width, height: width))
                view.addSubview(button)
                actionButtons.append(button)
            }
        }else if numberOfItems == 1{
            let x = margin
            let button = makeButton(frame: CGRect(x: x, y: topMargin, width: width, height: width))
            view.addSubview(button)
            actionButtons.append(button)
        }
    }
    
    func updateArrangement(in view: UIView, for numberOfItems: Int){
        
        let width: CGFloat = 25
        let margin: CGFloat = 16
        
        let spacing = calculateSpacing(for: numberOfItems, of: width, in: view, with: margin)
        let topMargin = (view.frame.height - width ) / 2
        
        if numberOfItems > 1{
            for i in 0..<numberOfItems{
                let x = margin + (spacing + width) * CGFloat(i)
                actionButtons[i].frame = CGRect(x: x, y: topMargin, width: width, height: width)
            }
        }
    }
    
    func updateSubviews(forItemAt index: Int){
        
        configNavBarItems(forItemAt: index)
        
        //OperationQueue.main.addOperation {
            self.displayCaptionForItem(at: index)
        //}
        
        numberOfActionsForItem[index] = delegate?.numberOfActions(forItemAt: index) ?? 0
        for i in 0..<actionButtons.count{
            actionButtons[i].removeFromSuperview()
        }
        actionButtons = [UIButton]()
        arrange(numberOfItems: numberOfActionsForItem[index], in: actionBar)
        configButtons(forItemAt: index)
        
        print("number of action for this item: ", numberOfActionsForItem)
    }
    
    func displayCaptionForItem(at index: Int){
        if let caption = delegate?.caption(forItemAt: index){
            UIView.animate(withDuration: shortAnimationDuration, animations: {
                if caption != ""{
                    if self.alphaZeroByTap == false{
                        self.captionView.alpha = 1.0
                    }
                    self.captionLabel.text = caption
                    self.currentItemWithCaption = true
                }else{
                    self.currentItemWithCaption = false
                    self.captionView.alpha = 0.0
                }
            })
        }else{
            UIView.animate(withDuration: shortAnimationDuration, animations: {
                self.currentItemWithCaption = false
                self.captionView.alpha = 0.0
            })
        }
    }
    
    func configButtons(forItemAt index: Int){
        
        for i in 0..<numberOfActionsForItem[index]{
            configButton(at: i, forItemAt: index)
        }
        
        UIView.animate(withDuration: shortAnimationDuration) {
            
            if self.numberOfActionsForItem[index] == 0{
                if self.currentItemWithCaption == false{
                    self.actionBar.alpha = 0.0
                }
            }else{
                if self.alphaZeroByTap == false{
                    self.actionBar.alpha = 1.0
                }
            }
        }
    }
    
    func configNavBarItems(forItemAt index: Int){
        
        if alphaZeroByTap == false{
            topBar.alpha = 1.0
            topGuide.alpha = 1.0
        }
        
        let title = delegate?.title(forItemAt: index) ?? ""
        let leftItems = delegate?.topBarLeftItems(forItemAt: index) ?? [UIBarButtonItem]()
        let rightItems = delegate?.topBarRightItems(forItemAt: index) ?? [UIBarButtonItem]()
        
        topBar.topItem?.title = title
        topBar.topItem?.leftBarButtonItems = leftItems
        topBar.topItem?.rightBarButtonItems = rightItems
    }
    
    public func go(toItemAt index: Int){
        print("Going to item at index")
        collectionView.setContentOffset(CGPoint(x: CGFloat(index) * self.view.frame.size.width, y: 0), animated: true)
        visibleIndex = index
        currentIndexPath = IndexPath.init(row: visibleIndex, section: 0)
        updateSubviews(forItemAt: index)
    }
    
    
    public func getCurrentIndex()->Int{
        return visibleIndex
    }
    
    
    func setupInitial(){
        if initialItemIndex > numberOfImages - 1{
            initialItemIndex = numberOfImages - 1
        }else if initialItemIndex < 0{
            initialItemIndex = 0
        }
        collectionView.setContentOffset(CGPoint(x: CGFloat(initialItemIndex) * self.view.frame.size.width, y: 0), animated: false)
        visibleIndex = initialItemIndex
        currentIndexPath = IndexPath.init(row: initialItemIndex, section: 0)
        updateSubviews(forItemAt: visibleIndex)
    }
}

extension PhotoViewerController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages // numberOfImages
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        
        delegate?.photoViewer(imageView: cell.imageView!, at: indexPath.row)
        
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if cellAllocatingForTheFirstTime{
            setupInitial()
            cellAllocatingForTheFirstTime = false
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleIndexPath = calcualteVisibleIndexPath()
        visibleIndex = visibleIndexPath.row
        currentIndexPath = visibleIndexPath
        updateSubviews(forItemAt: visibleIndex)

    }
    
    
    func calcualteVisibleIndexPath()->IndexPath{
        
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath = collectionView.indexPathForItem(at: visiblePoint)!
        
        return visibleIndexPath
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let visibleIndexPath = visibleCurrentCell ?? IndexPath() //calcualteVisibleIndexPath()
//        visibleIndex = visibleIndexPath.row
//        currentIndexPath = visibleIndexPath
//        updateSubviews(forItemAt: visibleIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let visibleIndexPath = calcualteVisibleIndexPath()
//        visibleIndex = visibleIndexPath.row
//        currentIndexPath = visibleIndexPath
//        updateSubviews(forItemAt: visibleIndex)
    }
    
}

public class CollectionViewLayout: UICollectionViewFlowLayout {
    
    let innerSpace: CGFloat = 10.0
    
    var mostRecentOffset : CGPoint = CGPoint()
    
    override init() {
        super.init()
        self.minimumInteritemSpacing = innerSpace
        self.minimumLineSpacing = 0.0
        self.scrollDirection = .horizontal
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func itemWidth() -> CGFloat {
        return collectionView!.frame.size.width
    }
    
    func itemHeight() -> CGFloat {
        return collectionView!.frame.size.height
    }
    
    
    
    override public var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight())
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight())
        }
    }
    
}

public class ImageCell: UICollectionViewCell{
    
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFit
        imageView?.clipsToBounds = true
        imageView?.isUserInteractionEnabled = false
        
        imageView?.backgroundColor = UIColor.clear
        
        contentView.addSubview(imageView!)
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        var frame = imageView?.frame
        frame?.size.height = self.frame.size.height
        frame?.size.width = self.frame.size.width
        frame?.origin.x = 0
        frame?.origin.y = 0
        imageView?.frame = frame!
    }
}


