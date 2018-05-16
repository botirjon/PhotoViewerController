//
//  MediaViewerController.swift
//  MediaViewer
//
//  Created by botirjon nasridinov on 16/01/2018.
//  Copyright © 2018 INHA UNIVERSITY. All rights reserved.
//
import UIKit

public protocol PhotoViewerControllerDelegate: NSObjectProtocol {
    
    // MARK: - Data Source
    
    /**
     Provides the action bar button at a position for an item at an index for customization in a photo viewer.
     - parameter photoViewer: The photo viewer controller object requesting this information.
     - returns: Number of items to display in `photoViewer`.
     */
    func numberOfItems(in photoViewer: PhotoViewerController) -> Int
    
    /**
     Provides the action bar button at a position for an item at an index for customization in a photo viewer.
     - parameter photoViewer: The photo viewer controller object requesting this information.
     - parameter index: An index number identifying the index of an item for which the number of actions is requested in `photoViewer`.
     - returns: The number of actions for an item at `index`.
     */
    func numberOfActions(in photoViewer: PhotoViewerController, forItemAt index: Int) -> Int
    
    // MARK: - Delegate
    
    /**
     Provides the action bar button at a position for an item at an index for customization in a photo viewer.
     - parameter photoViewer: The photo viewer controller object providing this information.
     - parameter imageView: An image view provided for customization to display an item at `index`.
     - parameter index: An index number identifying the index of an item for which an image view is provided in `photoViewer`.
     */
    func photoViewer(_ photoViewer: PhotoViewerController, imageView: UIImageView, at index: Int)
    
    /**
     Provides the action bar button at a position for an item at an index for customization in a photo viewer.
     - parameter photoViewer: The photo viewer controller object requesting this information.
     - parameter index: An index number identifying the index of an item for which left top bar items are requested in `photoViewer`.
     - returns: An array of left top bar items.
     */
    func photoViewer(_ photoViewer: PhotoViewerController, topBarLeftItemsAt index: Int) -> [UIBarButtonItem]
    
    /**
     Provides the action bar button at a position for an item at an index for customization in a photo viewer.
     - parameter photoViewer: The photo viewer controller object requesting this information.
     - parameter index: An index number identifying the index of an item for which right top bar items are requested in `photoViewer`.
     - returns: An array of right top bar items.
     */
    func photoViewer(_ photoViewer: PhotoViewerController, topBarRightItemsAt index: Int) -> [UIBarButtonItem]
    
    /**
     Provides the action bar button at a position for an item at an index for customization in a photo viewer.
     - parameter photoViewer: The photo viewer controller object providing this information.
     - parameter button: An action button at a position provided for customization in `photoViewer`.
     - parameter position: The position of the provided action button for an item at an `index`.
     - parameter index: An index number identifying the index of an item for which an action button at a position is provided in `photoViewer`.
     */
    func photoViewer(_ photoViewer: PhotoViewerController, actionBarButton button: UIButton, at position: Int, forItemAt index: Int)
    
    /**
     Tells the delegate to return the title text for an item at a particular index in a photo viewer controller.
     - parameter photoViewer: The photo viewer controller object requesting this information.
     - parameter index: An index number identifying the index of an item for which a title text is requested in `photoViewer`.
     - returns: title text for an item at `index`.
     */
    func photoViewer(_ photoViewer: PhotoViewerController, titleForItemAt index: Int) -> String
    
    /**
     Tells the delegate to return the caption text for an item at a particular index in a photo viewer controller.
     - parameter photoViewer: The photo viewer controller object requesting this information.
     - parameter index: An index number identifying the index of an item for which a caption text is requested in `photoViewer`.
     - returns: caption text for an item at `index`.
     */
    func photoViewer(_ photoViewer: PhotoViewerController, captionForItemAt index: Int) -> String
}


public class PhotoViewerController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var actionBar: UIView!
    @IBOutlet var topBar: UINavigationBar!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var captionView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var topGuide: UIView!
    @IBOutlet var actionBarContainer: UIView!
    @IBOutlet var captionViewContainer: UIView!
    @IBOutlet var topGuideHeight: NSLayoutConstraint!
    
    // MARK: - Constants
    
    let dimBlackColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
    let shortAnimationDuration: TimeInterval = 0.2
    let mediumAnimationDuration: TimeInterval = 0.3
    
    
    // MARK: - Public properties
    
    weak open var delegate: PhotoViewerControllerDelegate?
    public var initialItemIndex: Int = 0
    
    public var whenFullScreen: ((PhotoViewerController) -> Void)?
    public var whenDetailed: ((PhotoViewerController) -> Void)?
    public var completion: (() -> Void)?
    
    // MARK: - Private properties
    
    var isAlreadyArranged: Bool = false
    var collectionViewLayout: CollectionViewLayout?
    var actionsCount = 0
    var actionButtons = [EasyToClickButton]()
    var cellAllocatingForTheFirstTime = true
    var visibleIndex: Int = 0
    var currentIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    var currentItemWithCaption: Bool = false
    var contentViewTapped: Bool = false
    var alphaZeroByTap = false
    var captionExistForCurrentItem: Bool = false
    var lastOrientation: UIDeviceOrientation = UIDevice.current.orientation
    weak var navItem: UINavigationItem!
    var statusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var lastStatusBarStyle: UIStatusBarStyle?
    
    
    
    // MARK: - Init
    
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
    
    
    override public func viewWillAppear(_ animated: Bool) {
        contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height)
        self.view.backgroundColor = UIColor.black
        
        if cellAllocatingForTheFirstTime == false{
            setupInitial()
        }
        
        lastOrientation = UIDevice.current.orientation
        
        // remember the entry status bar style
        lastStatusBarStyle = UIApplication.shared.statusBarStyle
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        if !UIApplication.shared.isStatusBarHidden {
            topGuideHeight.constant = UIApplication.shared.statusBarFrame.size.height
        }
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {

        if let style = lastStatusBarStyle{
            UIApplication.shared.statusBarStyle = style
        }
        
        topGuideHeight.constant = 20
        restoreIdentity()
        completion?()
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupAll()
    }
    
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let  insets = self.collectionView.contentInset
        self.collectionView.contentInset = insets
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        if UIDevice.current.orientation != lastOrientation{
            self.collectionView.setContentOffset(CGPoint(x: self.view.frame.size.width * CGFloat(self.visibleIndex), y: 0), animated: false)
            self.lastOrientation = UIDevice.current.orientation
            updateArrangement(in: actionBar, for: delegate?.numberOfActions(in: self, forItemAt: visibleIndex) ?? 0)
        }
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
        return statusBarHidden
    }

    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    
    // MARK: -
    
    @objc func handleDoubleTapGesture(sender: UITapGestureRecognizer){
        let cell = collectionView.cellForItem(at: currentIndexPath) as! ImageCell
        cell.handleDoubleTap(sender: sender)
    }
    
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
            self.statusBarHidden = alpha == 0.0
            
            if alpha == 0.0{
                self.actionBarContainer.alpha = alpha
                self.captionViewContainer.alpha = alpha
                self.whenDetailed?(self)
            }else{
                self.whenFullScreen?(self)
                if self.currentItemWithCaption == true{
                    self.captionViewContainer.alpha = alpha
                    self.actionBarContainer.alpha = alpha
                }else{
                    if (self.delegate?.numberOfActions(in: self, forItemAt: self.visibleIndex) ?? 0) != 0{
                        self.actionBarContainer.alpha = alpha
                    }
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
                    self.captionViewContainer.alpha = 1.0
                }
                
                if currentItemWithCaption == true{
                    self.actionBarContainer.alpha = 1.0
                    if (self.delegate?.numberOfActions(in: self, forItemAt: visibleIndex) ?? 0) != 0{
                        self.actionBar.alpha = 1.0
                    }
                }
            }
        }else{
            // began
            self.actionBarContainer.alpha = 0.0
            self.topBar.alpha = 0.0
            self.topGuide.alpha = 0.0
            self.captionViewContainer.alpha = 0.0
        }
    }
    
    public func restoreIdentity() {
        self.topBar.isHidden = false
        self.topGuide.isHidden = false
        
        if let cell = self.collectionView.cellForItem(at: self.currentIndexPath) as? ImageCell, let scrollView = cell.scrollView {
            if scrollView.zoomScale > 1.0 {
                scrollView.setZoomScale(1.0, animated: false)
            }
        }
    }
    
    public func dismissSelf() {
        self.dismiss(animated: true, completion: {
            self.restoreIdentity()
            self.completion?()
        })
    }
    
    
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        
        let _:CGFloat = 0.3
        
        let touchPoint = sender.location(in: self.view?.window)
        let state = sender.state
        if state == .began {
            initialTouchPoint = touchPoint
        } else if state == .changed {
            
            let translation: CGFloat = touchPoint.y - initialTouchPoint.y
            if translation > 0 {
                
                self.contentView.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)

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
                let width = self.view.frame.size.width
                let height = self.view.frame.size.height
                self.contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                self.view.backgroundColor = UIColor.black
            }
        }
        else if state == .ended || state == .cancelled {
            
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.topBar.isHidden = true
                self.topGuide.isHidden = true
                
                self.dismissSelf()

            } else {
                
                UIView.animate(withDuration: shortAnimationDuration, animations: {
                    self.handleDissmiss(ended: true)
                })
                
                UIView.animate(withDuration: mediumAnimationDuration, animations: {
                    let width = self.contentView.frame.size.width
                    let height = self.contentView.frame.size.height
                    self.contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    self.view.backgroundColor = UIColor.black
                })
            }
        }
    }
    
    
    
    /* ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...... ... ... ... ... ... ... ... ... ... */
    
    func configButton(at position: Int, forItemAt index: Int){
        delegate?.photoViewer(self, actionBarButton: actionButtons[position], at: position, forItemAt: index)
        
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
    
    func makeButton(frame: CGRect)->EasyToClickButton{
        let button = EasyToClickButton(frame: frame) // UIButton(frame: frame)
        button.backgroundColor = UIColor.clear
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.tintColor = UIColor.white
        
        return button
    }
    
    func arrange(numberOfItems: Int, in view: UIView){
        
        let width: CGFloat = 30
        let margin: CGFloat = 0
        
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
        
        let width: CGFloat = 30
        let margin: CGFloat = 0
        
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
        self.displayCaptionForItem(at: index)
        
        
        for i in 0..<actionButtons.count{
            actionButtons[i].removeFromSuperview()
        }
        actionButtons = [EasyToClickButton]()
        let numberOfActions = self.delegate?.numberOfActions(in: self, forItemAt: index) ?? 0
        arrange(numberOfItems: numberOfActions, in: actionBar)
        configButtons(forItemAt: index, numberOfActions: numberOfActions)
        
    }
    
    func displayCaptionForItem(at index: Int){
        if let caption = delegate?.photoViewer(self, captionForItemAt: index){
            UIView.animate(withDuration: shortAnimationDuration, animations: {
                if caption != ""{
                    if self.alphaZeroByTap == false{
                        self.captionViewContainer.alpha = 1.0
                    }
                    self.captionLabel.text = caption
                    self.currentItemWithCaption = true
                }else{
                    self.currentItemWithCaption = false
                    self.captionViewContainer.alpha = 0.0
                }
            })
        }else{
            UIView.animate(withDuration: shortAnimationDuration, animations: {
                self.currentItemWithCaption = false
                self.captionViewContainer.alpha = 0.0
            })
        }
    }
    
    
    func configButtons(forItemAt index: Int, numberOfActions: Int){
        
        for i in 0..<numberOfActions {
            configButton(at: i, forItemAt: index)
        }
        
        UIView.animate(withDuration: shortAnimationDuration) {
            
            if self.alphaZeroByTap == false{
                if self.currentItemWithCaption == true{
                    self.actionBarContainer.alpha = 1.0
                }else{
                    if numberOfActions != 0{
                        self.actionBarContainer.alpha = 1.0
                    }else{
                        self.actionBarContainer.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func configNavBarItems(forItemAt index: Int){
        
        if alphaZeroByTap == false{
            topBar.alpha = 1.0
            topGuide.alpha = 1.0
        }
        
        let title = delegate?.photoViewer(self, titleForItemAt: index) ?? ""
        let leftItems = delegate?.photoViewer(self, topBarLeftItemsAt: index) ?? [UIBarButtonItem]()
        let rightItems = delegate?.photoViewer(self, topBarRightItemsAt: index) ?? [UIBarButtonItem]()
        
        topBar.topItem?.title = title
        topBar.topItem?.leftBarButtonItems = leftItems
        topBar.topItem?.rightBarButtonItems = rightItems
    }
    
    public func go(toItemAt index: Int, animated: Bool){
        collectionView.setContentOffset(CGPoint(x: CGFloat(index) * self.view.frame.size.width, y: 0), animated: animated)
        visibleIndex = index
        currentIndexPath = IndexPath.init(row: visibleIndex, section: 0)
        updateSubviews(forItemAt: index)
    }
    
    
    public var currentItemIndex: Int{
        return visibleIndex
    }
    
    
    public func reloadData(){
        collectionView.reloadData()
        updateSubviews(forItemAt: visibleIndex)
    }
    
    
    func setupInitial(){
        let numberOfImages = delegate?.numberOfItems(in: self) ?? 0
        
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

// MARK: - Configure methods

extension PhotoViewerController {
    
    func setupAll() {
        initSelf()
        initContentView()
        setupCollectionView()
        setupTopBar()
        setupCaptionViewContainer()
        setupCaptionView()
        setupActionBarContainer()
        setupActionBar()
    }
    
    func initSelf() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:)))
        self.view.addGestureRecognizer(pan)
        
        self.view.backgroundColor = UIColor.black
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    func initContentView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender:)))
        tap.numberOfTapsRequired = 1
        
        tap.delegate = self
        self.contentView.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(sender:)))
        doubleTap.numberOfTapsRequired = 2
        tap.require(toFail: doubleTap)
        doubleTap.delegate = self
        contentView.addGestureRecognizer(doubleTap)
        
        contentView.backgroundColor = UIColor.clear
    }
    
    func setupCollectionView(){
        
        collectionViewLayout = CollectionViewLayout()
        collectionView.collectionViewLayout = collectionViewLayout!
        
        collectionView.backgroundColor = UIColor.black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.clear
    }
    
    func setupTopBar(){
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topGuide.backgroundColor = dimBlackColor
        topGuide.translatesAutoresizingMaskIntoConstraints = false
        
        topBar.setBackgroundImage(UIImage(), for: .default)
        topBar.shadowImage = UIImage()
        topBar.tintColor = UIColor.white
        topBar.isTranslucent = true
        topBar.backgroundColor = dimBlackColor
    }
    
    func setupCaptionViewContainer() {
        captionViewContainer.backgroundColor = dimBlackColor
    }
    
    func setupCaptionView(){
        captionLabel.lineBreakMode = .byTruncatingTail
        captionLabel.numberOfLines = 0
        captionLabel.textColor = UIColor.white
        captionLabel.backgroundColor = UIColor.clear
        captionLabel.adjustsFontSizeToFitWidth = false
        
        captionView.isUserInteractionEnabled = false
        captionView.backgroundColor = UIColor.clear
        captionView.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: captionView,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: self.view,
                                      attribute: .leftMargin,
                                      multiplier: 1,
                                      constant: 0)
        let right = NSLayoutConstraint(item: captionView,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: self.view,
                                       attribute: .rightMargin,
                                       multiplier: 1,
                                       constant: 0)
        self.view.addConstraints([left, right])
    }
    
    func setupActionBarContainer() {
        actionBarContainer.backgroundColor = dimBlackColor
    }
    
    func setupActionBar(){
        actionBar.backgroundColor = UIColor.clear
        actionBar.translatesAutoresizingMaskIntoConstraints = false
        
        let left = NSLayoutConstraint(item: actionBar,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: self.view,
                                      attribute: .leftMargin,
                                      multiplier: 1,
                                      constant: 0)
        let right = NSLayoutConstraint(item: actionBar,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: self.view,
                                       attribute: .rightMargin,
                                       multiplier: 1,
                                       constant: 0)
        
        self.view.addConstraints([left, right])
    }
}

// MARK: - Gesture recognizer delegate

extension PhotoViewerController: UIGestureRecognizerDelegate{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - Scroll View

extension UIScrollView{
    
    func zoom(toPoint zoomPoint : CGPoint, scale : CGFloat, animated : Bool) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, self.minimumZoomScale)
        
        var translatedZoomPoint : CGPoint = .zero
        translatedZoomPoint.x = zoomPoint.x + contentOffset.x
        translatedZoomPoint.y = zoomPoint.y + contentOffset.y
        
        let zoomFactor = 1.0 / zoomScale
        
        translatedZoomPoint.x *= zoomFactor
        translatedZoomPoint.y *= zoomFactor
        
        var destinationRect : CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
        destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5
        
        if animated {
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: [.allowUserInteraction], animations: {
                self.zoom(to: destinationRect, animated: false)
            }, completion: {
                completed in
                if let delegate = self.delegate, delegate.responds(to: #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))), let view = delegate.viewForZooming?(in: self) {
                    delegate.scrollViewDidEndZooming!(self, with: view, atScale: scale)
                }
            })
        } else {
            zoom(to: destinationRect, animated: false)
        }
    }
}


