//
//  HudView.swift
//  MyLocations
//
//  Created by Bakhrom Usmanov on 21/11/24.
//
import UIKit

class HudView : UIView {
   var text = ""
   var imageName = ""
   
   class func hud(inView view: UIView, animated: Bool) -> HudView {
      let hudView = HudView(frame: view.bounds)
      hudView.isOpaque = false
      view.isUserInteractionEnabled = false
      view.addSubview(hudView)
      hudView.show(animated: animated)
      return hudView
   }
   
   func hide() {
      superview?.isUserInteractionEnabled = true
      removeFromSuperview()
   }
   
   override func draw(_ rect: CGRect) {
      let boxWidth: CGFloat = 96
      let boxHeight: CGFloat = 96
      
      let boxRect = CGRect(
         x: round((bounds.size.width - boxWidth)/2),
         y: round((bounds.size.height - boxHeight)/2),
         width: boxWidth,
         height: boxHeight)
      
      let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
      UIColor(white: 0.3, alpha: 0.8).setFill()
      roundedRect.fill()
      
      guard let image = UIImage(named: imageName) else { return }
      let imagePoint = CGPoint(
         x: center.x - round(image.size.width/2),
         y: center.y - round(image.size.height/2) - boxHeight/8)
      image.draw(at: imagePoint)
      
      let textAttributes = [
         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
         NSAttributedString.Key.foregroundColor: UIColor.white
      ]
      let textSize = text.size(withAttributes: textAttributes)
      let textPoint = CGPoint(
         x: center.x - round(textSize.width/2),
         y: center.y - round(textSize.height/2) + boxHeight/4)
      text.draw(at: textPoint, withAttributes: textAttributes)
   }
   
   //MARK: - Animations
   func show(animated: Bool) {
      if animated {
         alpha = 0
         transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
         
         UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            animations: {
               self.alpha = 1
               self.transform = CGAffineTransform.identity
            }
         )
      }
   }
   
   func hide(animated: Bool) {
      if animated {
         UIView
            .animate(
               withDuration: 0.3,
               delay: 0,
               usingSpringWithDamping: 0.7,
               initialSpringVelocity: 0.5,
               animations: {
                  self.alpha = 0
                  self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
               }
            )
      }
   }
   
   
}
