//
//  ImageCell.swift
//  PhotoViewerController
//
//  Created by botirjon nasridinov on 15/05/2018.
//

import UIKit

public class ImageCell: UICollectionViewCell{
    
    var imageView: UIImageView?
    var scrollView: UIScrollView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView = makeScrollView()
        imageView = makeImageView()
        scrollView?.addSubview(imageView!)
        contentView.addSubview(scrollView!)
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    func makeScrollView()->UIScrollView{
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.2
        scrollView.maximumZoomScale = 5.0
        scrollView.backgroundColor = UIColor.clear
        
        return scrollView
    }
    
    func makeImageView() -> UIImageView{
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.backgroundColor = UIColor.clear
        return imageView
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutScrollView()
        layoutImageView()
    }
    
    func layoutScrollView(){
        var scrollViewFrame = scrollView?.frame
        scrollViewFrame?.size.height = self.frame.size.height
        scrollViewFrame?.size.width = self.frame.size.width
        scrollViewFrame?.origin.x = 0
        scrollViewFrame?.origin.y = 0
        scrollView?.frame = scrollViewFrame!
        scrollView?.contentSize = self.contentView.frame.size
    }
    
    func layoutImageView(){
        var frame = imageView?.frame
        frame?.size.height = self.frame.size.height
        frame?.size.width = self.frame.size.width
        frame?.origin.x = 0
        frame?.origin.y = 0
        imageView?.frame = frame!
    }
    
    
    public func handleDoubleTap(sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: scrollView)
        if (scrollView?.zoomScale ?? 1.0) > 1.0{
            scrollView?.setZoomScale(1.0, animated: true)
        }else{
            scrollView?.zoom(toPoint: touchPoint, scale: 3.0, animated: true)
        }
    }
    
}

extension ImageCell: UIScrollViewDelegate{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let subView = scrollView.subviews[0]
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * CGFloat(0.5), 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * CGFloat(0.5), 0.0)
        
        subView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= 1.0{
            UIView.animate(withDuration: 0.2, animations: {
                view?.transform = CGAffineTransform.identity
            })
        }
    }
}
