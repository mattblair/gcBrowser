//
//  GeoCouchDatabaseDefinition.h
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GeoCouchDatabaseDefinition : NSObject {
    
    // Display
    NSString *name;
    NSString *collection;
    
    // Order matters. This will be used to iterate through keys for display.
    NSArray *keysToDisplay; 
    
    // Use NSDictionary with NSNumbers holding doubles for easy JSON to/fro?
    NSDictionary *initialRegion; 
    
    // keys for NSNumbers: latitude, longitude, latitudeDelta, longitudeDelta
    
    // fetching data
    NSString *databaseURL; // or use NSURL? which is easier elsewhere
    NSString *pathForBrowserDesignDoc; // if nil, flip includeDocs to YES
    
    BOOL includeDocs; // default NO
    
    // usable if all docs included
    NSString *keyForTitle;
    NSString *keyForSubtitle; 
    
    BOOL local; // not used...yet...
    
    
    // for databases that accept submissions
    BOOL writable;
    NSArray *requiredKeys;
    NSArray *desiredKeys;
    BOOL allowArbitraryKeys;
    BOOL allowAttachments;
    
}

@end
