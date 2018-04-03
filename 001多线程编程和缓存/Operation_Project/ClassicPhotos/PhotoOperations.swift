//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by admin on 23/11/2017.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import Foundation
import UIKit


class  PendingOperation {
    lazy var dowdloadProgeres = [IndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue  = OperationQueue()
        queue.name = "download-queue"
        queue.maxConcurrentOperationCount = 10;
        return queue;
    }()
    
    lazy var filterProgeres = [IndexPath:Operation]()
    lazy var filterQueue:OperationQueue = {
        var queue  = OperationQueue()
        queue.name = "filter-queue"
        queue.maxConcurrentOperationCount = 10;
        return queue;
    }()

}


class DownLoader: Operation {
    let photoRecord: PhotoRecord
    init(photoRecord:PhotoRecord) {
        self.photoRecord = photoRecord;
    }
    
    override func main() {
        if self.isCancelled == true {
            return;
        }
        guard let imageData = NSData(contentsOf:self.photoRecord.url)  else {
            self.photoRecord.image = UIImage(named: "Failed")
            self.photoRecord.state = .Failed
            
            return;
        }
        
        if self.isCancelled {
            return;
        }
        self.photoRecord.image = UIImage(data: imageData as Data);
        self.photoRecord.state = .Downloaded
    }
}


class ImageFiltration: Operation {
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if self.isCancelled == true {
            return;
        }
        if self.photoRecord.state !=  .Downloaded {
            return;
        }
        if let filteredImage =  applySepiaFilter(image: self.photoRecord.image!){
            self.photoRecord.image = filteredImage;
            self.photoRecord.state = .Filtered;
        }
    }
    

    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        if self.isCancelled {
            return nil
        }
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter?.outputImage
        
        if self.isCancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        return returnImage
    }
}
