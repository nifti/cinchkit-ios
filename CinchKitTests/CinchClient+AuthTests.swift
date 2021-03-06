//
//  CinchClient+AuthTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit
import Nocilla

class CinchClientAuthSpec: QuickSpec {
    override func spec() {
        describe("Cinch Client Auth") {
            var client: CinchClient?
            var accountsResource : ApiResource?
            var tokensResource : ApiResource?
            
            beforeEach {
                LSNocilla.sharedInstance().start()
                LSNocilla.sharedInstance().clearStubs()
                client = CinchClient()
                
                let authServerURL = NSURL(string: "http://auth-service-jgjfpv9gvy.elasticbeanstalk.com")!
                accountsResource = ApiResource(id: "accounts", href: NSURL(string: "\(authServerURL)/accounts")!, title: "get and create accounts")
                tokensResource = ApiResource(id: "tokens", href: NSURL(string: "\(authServerURL)/tokens")!, title: "Create and refresh authentication tokens")
                client!.rootResources = ["accounts" : accountsResource!, "tokens" : tokensResource!]
            }
            
            afterEach {
                LSNocilla.sharedInstance().clearStubs()
                LSNocilla.sharedInstance().stop()
            }
            
            describe("fetch Accounts matching ids") {
                it("should return single account") {
                    let path : NSString = "\(accountsResource!.href.absoluteString)/.+"
                    let data = CinchKitTestsHelper.loadJsonData("fetchAccount")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(200).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingIds(["c49ef0c0-8610-491d-9bb2-c494d4a52c5c"]) { (accounts, error) in
                            expect(accounts).toNot(beEmpty())
                            expect(error).to(beNil())
                            
                            if let acc = accounts {
                                expect(acc.count).to(equal(1))
                            }
                            
                            done()
                        }
                    }
                }
                
                it("should return 404 not found error") {
                    waitUntil(timeout: 1) { done in
                        let path : NSString = "\(accountsResource!.href.absoluteString)/.+"
                        let data = CinchKitTestsHelper.loadJsonData("accountNotFound")
                        
                        stubRequest("GET", path.regex())
                            .andReturn(404).withHeader("Content-Type", "application/json").withBody(data)

                        client!.fetchAccountsMatchingIds(["c49ef0c0-8610-491d-9bb2-c494d4a52c5d"]) { (accounts, error) in
                            expect(accounts).to(beNil())
                            expect(error).toNot(beNil())
                            
                            if let err = error {
                                expect(err.domain).to(equal(CinchKitErrorDomain))
                                expect(err.code).to(equal(404))
                            }
                            
                            
                            done()
                        }
                    }
                }
            }
            
            describe("fetch Accounts matching email") {
                
                it("should return single account") {
                    let path : NSString = "\(accountsResource!.href.absoluteString)\\?email\\=.*"
                    let data = CinchKitTestsHelper.loadJsonData("fetchAccount")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(200).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingEmail("foo@bar.com") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).toNot(beEmpty())
                            expect(accounts!.count).to(equal(1))
                            expect(accounts!.first!.links!.count).to(equal(3))
                            done()
                        }
                    }
                }
                
                it("should return 404 not found error") {
                    let path : NSString = "\(accountsResource!.href.absoluteString)\\?email\\=.*"
                    let data = CinchKitTestsHelper.loadJsonData("accountNotFound")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(404).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingEmail("asdfasdfasdf") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(accounts).to(beNil())
                            
                            expect(error!.code).to(equal(404))
                            done()
                        }
                    }
                }
                
                it("should return error when accounts resource doesnt exist") {
                    let c = CinchClient()
                    
                    waitUntil(timeout: 1) { done in
                        c.fetchAccountsMatchingEmail("foo@bar.com") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(error!.domain).to(equal(CinchKitErrorDomain))
                            expect(accounts).to(beNil())
                            
                            done()
                        }
                    }
                }
            }
            
            describe("fetch Accounts matching username") {
                
                it("should return single account") {
                    let path : NSString = "\(accountsResource!.href.absoluteString)\\?username\\=.*"
                    let data = CinchKitTestsHelper.loadJsonData("fetchAccount")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(200).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingUsername("foobar") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).toNot(beEmpty())
                            expect(accounts!.count).to(equal(1))
                            done()
                        }
                    }
                }
                
                it("should return 404 not found") {
                    let path : NSString = "\(accountsResource!.href.absoluteString)\\?username\\=.*"
                    let data = CinchKitTestsHelper.loadJsonData("accountNotFound")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(404).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingUsername("asdfasdfasdf") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(accounts).to(beNil())
                            
                            expect(error!.code).to(equal(404))
                            done()
                        }
                    }
                }
                
                it("should return error when accounts resource doesnt exist") {
                    let c = CinchClient()
                    
                    waitUntil(timeout: 5) { done in
                        c.fetchAccountsMatchingUsername("foobar") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(error!.domain).to(equal(CinchKitErrorDomain))
                            expect(accounts).to(beNil())
                            
                            done()
                        }
                    }
                }
            }
            
            describe("create account") {
                
                it("should return created account") {
                    let str : NSString = accountsResource!.href.absoluteString
                    let data = CinchKitTestsHelper.loadJsonData("createAccount")

                    stubRequest("POST", str).andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.createAccount(["email" : "foo23@bar.com", "username" : "foobar23", "name" : "foobar"]) { (account, error) in
                            expect(error).to(beNil())
                            expect(account).toNot(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            expect(account!.roles).toNot(beEmpty())
                            
                            done()
                        }
                    }
                }
            }
            
            describe("refreshSession") {
                
                it("should return new session") {
                    let data = CinchKitTestsHelper.loadJsonData("createToken")

                    let token = CinchKitTestsHelper.validAuthToken()
                    
                    client!.session.accessTokenData = token
                    
                    stubRequest("POST", token.href.absoluteString).withHeader("Authorization", "Bearer \(token.refresh)")
                        .andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.refreshSession { (account, error) in
                            expect(error).to(beNil())
                            expect(account).to(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            expect(client!.session.accessTokenData!.expires.timeIntervalSince1970).to(equal(1425950710.000))
                            
                            done()
                        }
                    }
                }
                
                it("should return new session with account") {
                    let data = CinchKitTestsHelper.loadJsonData("createTokenIncludeAccount")
                    
                    let token = CinchKitTestsHelper.validAuthToken()
                    
                    client!.session.accessTokenData = token
                    
                    let path : NSString = "\(token.href.absoluteString)?include=account"
                    stubRequest("POST", path).withHeader("Authorization", "Bearer \(token.refresh)")
                        .andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.refreshSession(true) { (account, error) in
                            expect(error).to(beNil())
                            expect(account).toNot(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            expect(client!.session.accessTokenData!.expires.timeIntervalSince1970).to(equal(1425950710.000))
                            
                            done()
                        }
                    }
                }
                
                it("should create a session") {
                    let data = CinchKitTestsHelper.loadJsonData("createTokenIncludeAccount")
                    
                    let path : NSString = tokensResource!.href.absoluteString
                    stubRequest("POST", path.regex())
                        .andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.createSession(["facebookAccessToken" : "123"], headers: nil) { (account, error) in
                            expect(error).to(beNil())
                            expect(account).toNot(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            expect(client!.session.accessTokenData!.expires.timeIntervalSince1970).to(equal(1425950710.000))
                            
                            done()
                        }
                    }
                }
            }
        }
    }
}

class CinchBlockedAccountsSpec: QuickSpec {
    override func spec() {
        describe("check blocked user") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            it("should return blocked user") {
                waitUntil(timeout: 105) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://auth-service-jgjfpv9gvy.elasticbeanstalk.com/accounts/72d25ff9-1d37-4814-b2bd-bc149c222220/blockedAccounts/0fc27cf5-0965-427a-a617-101cf987fe42")!

                        c.checkBlockedAccount(atURL: url, queue: nil, completionHandler: { (blocked, error) -> () in
                            expect(error).to(beNil())

                            done()
                        })
                    }
                }
            }
        }
    }
}
