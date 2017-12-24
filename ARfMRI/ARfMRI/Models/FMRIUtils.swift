//
//  fMRIUtils.swift
//  ARfMRI
//
//  Created by Bliss Chapman on 12/22/17.
//  Copyright © 2017 Bliss Chapman. All rights reserved.
//

import Foundation

struct FMRIUtils {
    
    static func processSlicesForVolumeRendering(_ slices: [RGBAImage]) -> [[[Pixel]]] {
        var voxels = [[[Pixel]]]()
        for slice in slices {
            var voxelsForSlice = [[Pixel]]()
            
            var sampleBoundaryPixel = slice.pixels[1*slice.width + 1]
            let boundaryThreshold = 1
            for y in 0..<slice.height {
                var voxelsForRow = [Pixel]()
                
                for x in 0..<slice.width {
                    var origPixel = slice.pixels[y*slice.width + x]

                    if abs(Int(origPixel.red) - Int(sampleBoundaryPixel.red)) < boundaryThreshold &&
                        abs(Int(origPixel.green) - Int(sampleBoundaryPixel.green)) < boundaryThreshold &&
                        abs(Int(origPixel.blue) - Int(sampleBoundaryPixel.blue)) < boundaryThreshold {
                        origPixel.alpha = 10
                    } else {
                        origPixel.alpha = 30
                    }
                    voxelsForRow.append(origPixel)
                }
                
                voxelsForSlice.append(voxelsForRow)
            }
            
            voxels.append(voxelsForSlice)
        }
        
        return voxels
    }
    
    
}
