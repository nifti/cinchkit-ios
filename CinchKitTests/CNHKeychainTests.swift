//
//  CNHKeychainTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit

class CinchKeychainSpec: QuickSpec {
    override func spec() {
        var keychain : CNHKeychain?
        
        beforeEach {
            keychain = CNHKeychain()
            keychain!.clear()
        }
        
        describe("save") {
            
            it("should save token data") {
                let err = keychain!.save(CinchKitTestsHelper.validAuthToken())
                
                expect(err).to(beNil())
            }
            
        }
        
        describe("load") {
            
            it("should load saved token data") {
                let savedToken = CinchKitTestsHelper.validAuthToken()
                let err = keychain!.save(savedToken)
                
                expect(err).to(beNil())
                
                let data = keychain!.load()
                expect(data).toNot(beNil())
                
                expect(data!.accountID).to(equal(savedToken.accountID))
                expect(data!.access).to(equal(savedToken.access))
                expect(data!.refresh).to(equal(savedToken.refresh))
                expect(data!.type).to(equal(savedToken.type))
                expect(data!.href).to(equal(savedToken.href))
                expect(data!.cognitoId).to(equal(savedToken.cognitoId))
                expect(data!.cognitoToken).to(equal(savedToken.cognitoToken))
                
//                expect(savedToken.expires.timeIntervalSince1970).to(equal(data!.expires.timeIntervalSince1970))
            }
            
            it("should return nil after clearing keychain") {
                let err = keychain!.save(CinchKitTestsHelper.validAuthToken())
                expect(err).to(beNil())
                
                keychain!.clear()
                
                let data = keychain!.load()
                expect(data).to(beNil())
            }
        }
    }
}