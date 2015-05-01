//
//  CinchClient+Comments.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 5/1/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import SwiftyJSON

extension CinchClient {
    public func fetchComments(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHCommentsResponse?, NSError?) -> ()) {
        let serializer = CommentsResponseSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}