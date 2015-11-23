//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Curtis Bridges on 11/21/15.
//  Copyright © 2015 Curtis Bridges. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!

    init(name: String, path: NSURL) {
        filePathUrl = path;
        title = name
    }
}
