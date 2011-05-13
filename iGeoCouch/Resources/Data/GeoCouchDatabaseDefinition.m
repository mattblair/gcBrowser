//
//  GeoCouchDatabaseDefinition.m
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
        // for a big dataset. Just make centroid required for general release.
        
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
