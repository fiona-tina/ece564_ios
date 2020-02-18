//
//  Extensions.swift
//  ECE564_HOMEWORK
//
//  Created by Nan Ni on 2/2/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import UIKit

//MARK: - Dismiss keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        /* Dismiss keyboard by touching anywhere
         Reference: https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
         */
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
}


//MARK: - Rotate UIView
extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}

//MARK: - Change appearance of UITextField
extension UITextField {
    func isDisabled(_ state: Bool){
        self.isUserInteractionEnabled = state
        self.textColor = state ? UIColor.black : UIColor(named: K.BrandColors.gray)
    }
}

//MARK: - Convert UIImage into String
extension UIImage {
    func base64ToString() -> String {
        let imageData: Data = self.jpegData(compressionQuality: 0.1)!
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
}

//MARK: - Convert String into UIImage
extension String {
    func base64ToImage() -> UIImage {
        let dataDecode = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
        return UIImage(data: dataDecode)!
    }
}

//MARK: - Change UImage quality & size
extension UIImage {
    func resizeImage(resize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(resize,false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: resize.width, height: resize.height))
        let resizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizeImage
    }
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let resize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return resizeImage(resize: resize)
    }
}

//MARK: - Alert
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}