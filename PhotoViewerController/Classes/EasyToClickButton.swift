//
//  EasyToClickButton.swift
//  PhotoViewerController
//
//  Created by botirjon nasridinov on 15/05/2018.
//

import UIKit

public class EasyToClickButton : UIButton {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}
