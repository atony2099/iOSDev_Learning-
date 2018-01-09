//
//  PhotoRecord.swift
//  ClassicPhotos
//
//  Created by admin on 22/11/2017.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import UIKit

enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
}


class PhotoRecord {
    let name:String
    let url:URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
}
