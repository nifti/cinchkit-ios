//
//  ApiResource.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

public struct ApiResource {
    let id: String
    let href: NSURL
    let title: String?
    
    public init(id : String, href: NSURL, title : String?) {
        self.id = id
        self.href = href
        self.title = title
    }
}