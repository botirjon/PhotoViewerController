//
//  PhotoViewerController+CollectionView.swift
//  PhotoViewerController
//
//  Created by botirjon nasridinov on 15/05/2018.
//

import UIKit

extension PhotoViewerController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfItems(in: self) ?? 0
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        
        delegate?.photoViewer(self, imageView: cell.imageView!, at: indexPath.row)
        
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
    
}

// MARK: - CollectionView Layout

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
