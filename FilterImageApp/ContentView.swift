//
//  ContentView.swift
//  FilterImageApp
//
//  Created by George Patterson on 17/03/2021.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? //stores the image the user selected
    
    //here were saying that the currentFilter must conform to CIFilter but doesnt have to conform to the sepiaTone.
    //the .sepiaTone() means that FIlter conforms to sepiaTone
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    //rendering CIImage to CGImage
    //converts recipe for an image into a series of pixels we can work with
    
    @State private var processedImage: UIImage?
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        //this is a custom binding which returns filterIntensity when its read but when its written it will both update filterintensity and call apply processing so that the latest intensity setting is immediately used in our filter.
        //custom bindings which rely on properties in the view need to be created inside the body.
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle().fill(Color.secondary)
                    if image != nil {
                        image?.resizable().scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true //shows the image lib
                }
                HStack {
                    Text("Intensity")
                    Slider(value: intensity) //change the slider value to the binding, because intensity is already a binding, there is no need for the $. We defined it as a binding in the body.
                }.padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        self.showingFilterSheet = true
                        
                    }.actionSheet(isPresented: $showingFilterSheet) {
                        ActionSheet(title: Text("Select Filter"), message: Text("Please Choose a Filter"),
                                    buttons: [
                                        .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()) },
                                            .default(Text("Edges")) { self.setFilter(CIFilter.edges()) },
                                            .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()) },
                                            .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()) },
                                            .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()) },
                                            .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()) },
                                            .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()) },
                                            .cancel()
                                    ])
                    }
                    Spacer()
                    Button("Save") {
                        guard let processedImage = self.processedImage else { return }
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        imageSaver.writePhotoToAlbum(image: processedImage)
                    }
                }
            }.padding([.horizontal, .bottom])
            .navigationBarTitle("FilterPhoto")
        }.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func applyProcessing() {
        //Reads all the keys
        //Sets different key values based on whether its supported by the current filter
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        //kCIInputIntensity is another core image constant value
        //it has the same effect as setting intensity param of the sepia tone filter
        guard let outputImage = currentFilter.outputImage else { return }
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage //UIImage stored for later use
        }
    }
    
    //this method is called when the image viewer is dismissed (when a photo is selected from the lib.)
    func loadImage() {
        guard let inputImage = inputImage else { return } //unwraps optional
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
