//
//  GeoCouchDatabaseDefinition.h
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//
//  Copyright (c) 2011, Elsewise LLC
//  All rights reserved.
// 
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this 
//     list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//     this list of conditions and the following disclaimer in the documentation 
//     and/or other materials provided with the distribution.
//  * Neither the name of Elsewise LLC nor the names of its contributors may be 
//     used to endorse or promote products derived from this software without 
//     specific prior written permission.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//



#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeoCouchDatabaseDefinition : NSObject {
    
    NSString *name;
    NSString *collection;
    
    // fetching data
    NSString *databaseURL;
    NSString *pathForBrowserDesignDoc; 
    BOOL includeDocs; 
    BOOL local; 
    
    MKCoordinateRegion initialRegion;
    NSArray *keysToDisplay;     
    NSString *keyForTitle;
    NSString *keyForSubtitle; 
    
    // for databases that accept submissions
    BOOL writable;
    NSArray *requiredKeys;
    NSArray *desiredKeys;
    BOOL allowArbitraryKeys;
    BOOL allowAttachments;
    
}



@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *collection;

// fetching data
@property (nonatomic, retain) NSString *databaseURL; 
@property (nonatomic, retain) NSString *pathForBrowserDesignDoc; // if nil, flip includeDocs to YES?
@property (nonatomic) BOOL includeDocs; // default NO

// if YES, will fetch details immediately, won't call Reachability, etc.
// not used...yet...
@property (nonatomic) BOOL local;


// Display

// Convert to NSDictionary with NSNumbers holding doubles for easy JSON i/o with
// keys: latitude, longitude, latitudeDelta, longitudeDelta
@property (nonatomic) MKCoordinateRegion initialRegion;

// Order matters. This will be used to iterate through keys for display.
@property (nonatomic, retain) NSArray *keysToDisplay; 

// used if include_docs is YES, instead of using a gcBrowser compatible design doc
@property (nonatomic, retain) NSString *keyForTitle;
@property (nonatomic, retain) NSString *keyForSubtitle;

// for databases that accept submissions
@property (nonatomic) BOOL writable;
@property (nonatomic, retain) NSArray *requiredKeys;
@property (nonatomic, retain) NSArray *desiredKeys;
@property (nonatomic) BOOL allowArbitraryKeys;
@property (nonatomic) BOOL allowAttachments;



// add methods for toJSON and initFromJSON, and translate initialRegion into an NSDictionary, etc.

@end
