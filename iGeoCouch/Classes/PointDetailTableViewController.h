//
//  PointDetailTableViewController.h
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
NOTE: I called this one PointDetailTableViewController because
it is a subclass of UITableViewController. This allows use of the
name PointDetailViewController for a UIViewController subclass, if
it makes sense to go that route at some point in the future.
 
*/
 
@interface PointDetailTableViewController : UITableViewController {
    
    NSString *theDocID;
    
}

@property (nonatomic, retain) NSString *theDocID;

@end
