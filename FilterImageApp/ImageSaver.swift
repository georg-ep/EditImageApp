//
//  ImageSaver.swift
//  FilterImageApp
//
//  Created by George Patterson on 17/03/2021.
//

import Foundation
import SwiftUI

/*
 In order to save the image we will use UIImageWriteToSavedPhotosAlbum()

 2 constraints:
 
 needs to be a class which inherits from NSObject,
 have a callback method whihc is marked with @objc then
 point to that method using the #selector compiler derivative
 
 What we have done here is equivalent to the format f ImagePicker
 
 We wrapped some uikit functionality in such a way that we get all the behaviour that we want, in a nicer swiftui way.
 
 
*/

class ImageSaver: NSObject {
    
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writePhotoToAlbum(image: UIImage) {
        //NSObject, @objc calback, #selector compiler derivative
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
