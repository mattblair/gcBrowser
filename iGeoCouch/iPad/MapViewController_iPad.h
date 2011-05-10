//
//  MapViewController_iPad.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface MapViewController_iPad : MapViewController {
    
    UIPopoverController *couchListPVC;
    UIPopoverController *mapCalloutPVC;
    
}

@property (nonatomic, retain) UIPopoverController *couchListPVC;
@property (nonatomic, retain) UIPopoverController *mapCalloutPVC;

- (IBAction)showCouchList:(id)sender;

@end
