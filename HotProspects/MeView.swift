//
//  MeView.swift
//  HotProspects
//
//  Created by Chloe Fermanis on 28/9/20.
//  Copyright © 2020 Chloe Fermanis. All rights reserved.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    
    @State private var name = "Anonymous"
    @State private var emailAddress = "paul@ghackingswift.com"
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.name)
                    .font(.body)
                    .padding()
                
                TextField("Email address", text: $emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .font(.body)
                    .padding([.leading, .trailing, .bottom])
                
                Image(uiImage: generateQRCode(from: "\(name)\n\(emailAddress)"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    
                
                Spacer()
            }
            .navigationBarTitle("Your code", displayMode: .inline)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
