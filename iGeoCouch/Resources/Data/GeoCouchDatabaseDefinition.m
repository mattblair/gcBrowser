//
//  GeoCouchDatabaseDefinition.m
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "GeoCouchDatabaseDefinition.h"

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
        
    }
    
    return self;
}


- (void)dealloc {

    [name release];
    [collection release];
    
    [databaseURL release];
    [pathForBrowserDesignDoc release];
    
    [initialRegion release];
    [keysToDisplay release];
    [keyForTitle release];
    [keyForSubtitle release];
    
    [requiredKeys release];
    [desiredKeys release];
    
    
    [super dealloc];
}

@end
