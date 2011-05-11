//
//  PointDetailTableViewController.h
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "GeoCouchDatabaseDefinition.h"

/*
NOTE: I called this one PointDetailTableViewController because
it is a subclass of UITableViewController. This allows use of the
name PointDetailViewController for a UIViewController subclass, if
it makes sense to go that route at some point in the future.
 
*/
 
@interface PointDetailTableViewController : UITableViewController {
    
    
    GeoCouchDatabaseDefinition *currentDatabaseDefinition;
    
    NSString *theDocID; // stored separately b/c not presented in UI
    NSString *lastRevID; // stored separately b/c not presented in UI
    NSDictionary *pointDictionary;
    NSArray *sortedRowNames;
    
    // Defaults to use: 
    // YES on the iPhone, because they've already seen a callout, and this is shown as a full screen transition
    // NO on the iPad, because this is shown in a popover, and the user may only want a peek
    // Exception: if the database def is set to include documents in the geoquery, don't fetch again
    BOOL fetchDetailsOnView; 
    
    ASIHTTPRequest *theDocumentRequest;
    
}

@property (nonatomic, retain) GeoCouchDatabaseDefinition *currentDatabaseDefinition;

@property (nonatomic, retain) NSString *theDocID;
@property (nonatomic, retain) NSString *lastRevID;
@property (nonatomic, retain) NSDictionary *pointDictionary;
@property (nonatomic, retain) NSArray *sortedRowNames;

@property (nonatomic) BOOL fetchDetailsOnView;
@property (nonatomic, retain) ASIHTTPRequest *theDocumentRequest;

- (void)fetchFullDocument;
- (void)killRequest;



@end
