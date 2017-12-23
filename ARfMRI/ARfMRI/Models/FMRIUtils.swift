//
//  fMRIUtils.swift
//  ARfMRI
//
//  Created by Bliss Chapman on 12/22/17.
//  Copyright © 2017 Bliss Chapman. All rights reserved.
//

import Foundation

struct FMRIUtils {
    static func processImageForVolumeRendering(_ inputImage: inout RGBAImage) {
        for i in 0..<inputImage.pixels.count {
            print("RED: \(inputImage.pixels[i].red) GREEN: \(inputImage.pixels[i].green) BLUE: \(inputImage.pixels[i].blue) ALPHA: \(inputImage.pixels[i].alpha)")
            inputImage.pixels[i].alpha = 128
//            inputImage.pixels[i].red = 0
//            inputImage.pixels[i].green = 0
//            inputImage.pixels[i].blue = 0
        }
    }
}
