//
//  GeoCouchDatabaseDefinition.m
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "GeoCouchDatabaseDefinition.h"
#import "gcBrowserConstants.h"

@implementation GeoCouchDatabaseDefinition

@synthesize name, collection, databaseURL, pathForBrowserDesignDoc, includeDocs, local;
@synthesize initialRegion, keysToDisplay, keyForTitle, keyForSubtitle;
@synthesize writable, requiredKeys, desiredKeys, allowArbitraryKeys, allowAttachments;

- (id)init {
    
    if ((self = [super init])) {
        
        // Set defaults
        self.includeDocs = NO;
        self.local = NO;       // for now...

        self.writable = NO;
        self.allowArbitraryKeys = YES;
        self.allowAttachments = NO;
        
        self.keyForTitle = @"title";
        self.keyForSubtitle = @"subtitle";
        
        // default inital region for MKMapView
        
        // Approximately walking distance in most places.
        // Intentionally small for big datasets.
        // NOTE: these are not used at the moment, but that's subject to change.
        // See reloadDatabaseDefinition of Map VC, where they are currently set.
        initialRegion.span.latitudeDelta = 0.011;
        initialRegion.span.longitudeDelta = 0.014;
        
        // Does it make sense to have a default centroid? 
        // Seems like that would be useless given the close zoom
        // Could calculate a centroid, but that could be problematic
        // for a big dataset. Just make centroid required.
        
    }
    
    return self;
}


- (void)dealloc {

    [name release];
    [collection release];
    
    [databaseURL release];
    [pathForBrowserDesignDoc release];
    
    [keysToDisplay release];
    [keyForTitle release];
    [keyForSubtitle release];
    
    [requiredKeys release];
    [desiredKeys release];
    
    
    [super dealloc];
}

@end
