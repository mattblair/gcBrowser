//
//  GeoCouchDatabaseDefinition.h
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeoCouchDatabaseDefinition : NSObject {
    
    NSString *name;
    NSString *collection;
    
    // fetching data
    NSString *databaseURL; // or use NSURL? which is easier elsewhere
    NSString *pathForBrowserDesignDoc; // if nil, flip includeDocs to YES
    BOOL includeDocs; // default NO
    BOOL local; // not used...yet...
    
    //NSDictionary *initialRegion; 
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
@property (nonatomic, retain) NSString *pathForBrowserDesignDoc;
@property (nonatomic) BOOL includeDocs;
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



// add methods for toJSON and initFromJSON and then store initial region as MapKit natives?

@end
