//
//  ProgressView.swift
//  evrotrust-ios
//
//  Created by Michael Dugah on 17/07/2020.
//  Copyright © 2020 Software Group. All rights reserved.
//

import UIKit

final class ProgressView: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    private let activityIndictor: UIActivityIndicatorView = {
        guard #available(iOS 13.0, *)
        else { return UIActivityIndicatorView(style: .gray) }
        
        return UIActivityIndicatorView(style: .medium)
    }()
    
    private let label: UILabel = UILabel()
    
    private let vibrancyView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        
        return UIVisualEffectView(effect: vibrancyEffect)
    }()
    
    init(text: String) {
        self.text = text
        
        super.init(effect: UIBlurEffect(style: .light))
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview
        else { return }
        
        let width = superview.frame.size.width / 2.0
        let height: CGFloat = 50.0
        
        frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                       y: superview.frame.height / 2 - height / 2,
                       width: width,
                       height: height)
        
        vibrancyView.frame = bounds
        
        let activityIndicatorSize: CGFloat = 40
        
        activityIndictor.frame = CGRect(x: 5,
                                        y: height / 2 - activityIndicatorSize / 2,
                                        width: activityIndicatorSize,
                                        height: activityIndicatorSize)
        
        layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.frame = CGRect(x: activityIndicatorSize + 5,
                             y: 0,
                             width: width - activityIndicatorSize - 15,
                             height: height)
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
    }
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    private func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        
        activityIndictor.startAnimating()
    }
}
