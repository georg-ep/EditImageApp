//
//  ImagePicker.swift
//  FilterImageApp
//
//  Created by George Patterson on 17/03/2021.
//

import SwiftUI


//THIS PROCESS IS CALLED WRAPPING A UIKIT CONTROLLER VIEW FOR USE INSIDE SWIFT

//UIViewControllerRepresentabke means that ImagePicker is already a swiftui view and we can place that into our view heirarchy.
struct ImagePicker: UIViewControllerRepresentable {

    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    //wrap uikit uiimagepickercontroller which lets the user select something from the lib
    //this function is actomatically called when we make an image picker instance.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        //our coordinator class conforms to UIImagePickerControllerDelegate, we can make it the delegate of the UIKit image picker
        picker.delegate = context.coordinator //done here
        return picker
    }
    
    //tells swiftUI to use the coordinator class for the image picker coordinator.
    //this function controls how the coordinator is made.
    func makeCoordinator() -> Coordinator {
        //Coordinator class has a single property let parent: ImagePicker.
        //we need to create it with reference to the image picker that it owns so the coordinator can pass on interesting events.
        Coordinator(self)
    }
    
    //this is the class that gets informed when any actions are taken. Acts as the delegate for UIKIt components
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        //called when the user selects an image and is given a dictionary of info about the selected image.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                //sets the image property of its parent ImagePicker
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    
    

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
}
