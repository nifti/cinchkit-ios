//
//  CinchKit.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// CinchKit errors
public let CinchKitErrorDomain = "com.cinchkit.error"

public class CinchClient {
    
    private let manager : Alamofire.Manager
    public let server : CNHServer
    
    internal let responseQueue = dispatch_queue_create("cinchkit.response", DISPATCH_QUEUE_CONCURRENT)
    
    public var rootResources : [String : ApiResource]?
    
    private(set) public var session = CNHSession()
    
    public convenience init() {
        self.init(server: CNHServer.dotComServer())
    }
    
    public required init(server : CNHServer) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 20
        manager = Alamofire.Manager(configuration: configuration)
        self.server = server
    }
    
    public func start() {
        return start(nil)
    }
    
    public func start(completionHandler : (() -> ())?) {
        var ongoing = 2
        
        let handler : ( () -> () ) = { () in
            ongoing--
            
            if ongoing == 0 {
                completionHandler?()
            }
        }
        
        var queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)

        dispatch_async(queue) {
            self.refreshSession { (_) in handler() }
        }
        
        dispatch_async(queue) {
            self.refreshRootResource { handler() }
        }
    }
    
    func refreshRootResource(completionHandler : (() -> ())?) {
        let serializer = ApiResourcesSerializer()
        request(.GET, self.server.baseURL)
            .responseCinchJSON(serializer) { (_, _, resources, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
                } else {
                    self.rootResources  = self.authServerResourcesHack(resources)
                }
                
                completionHandler?()
        }
    }
    
    func authServerResourcesHack(resources: [String : ApiResource]?) -> [String : ApiResource]? {
        var result = resources
        
        // temporary hack
        if let r = resources?["accounts"] {
            var accResource : ApiResource = ApiResource(id: r.id, href: NSURL(string: "\(self.server.authServerURL)/accounts")!, title: r.title)
            result?.updateValue(accResource, forKey: "accounts")
        }
        
        if let r = resources?["tokens"] {
            var accResource : ApiResource = ApiResource(id: r.id, href: NSURL(string: "\(self.server.authServerURL)/tokens")!, title: r.title)
            result?.updateValue(accResource, forKey: "tokens")
        }
        
        return result
    }
    
    func clientNotConnectedError() -> NSError {
        return NSError(domain: CinchKitErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Cinch Client not connected"])
    }
    
    func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, headers : [String : String]? = nil, encoding: Alamofire.ParameterEncoding = .JSON) -> Alamofire.Request {
        println("request - \(method.rawValue) - \(URLString.URLString)")
        
        var path = NSURL(string: URLString.URLString)!
        var mutableURLRequest = NSMutableURLRequest(URL: path)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let head = headers {
            for (field, value) in head {
                mutableURLRequest.setValue(value, forHTTPHeaderField: field)
            }    
        }
        
        
        let finalRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        
//        mutableURLRequest.setValue("\(token.type) \(token.refresh)", forHTTPHeaderField: "Authorization")

        return manager.request(finalRequest)
    }
    
    func request<T : JSONObjectSerializer>( method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, headers : [String : String]? = nil,  encoding: Alamofire.ParameterEncoding = .JSON,
        serializer : T, completionHandler : ((T.ContentType?, NSError?) -> Void)? ) {
            
            let start = CACurrentMediaTime()
            
            request(method, URLString, parameters: parameters, headers: headers, encoding: encoding)
                .responseCinchJSON(serializer) { (_, httpResponse, response, error) in
                    CNHUtils.logResponseTime(start, response : httpResponse,  message : "response: \(method.rawValue) \(URLString.URLString)")
                    
                    if(error != nil) {
                        NSLog("Error: \(error)")
                        completionHandler?(nil, error)
                    } else {
                        completionHandler?(response, nil)
                    }
            }
    }
}
