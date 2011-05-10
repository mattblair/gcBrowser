//
//  MapViewController_iPad.h
//  iGeoCouch
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface MapViewController_iPad : MapViewController {
    
    UIPopoverController *couchListPVC;
    
}

@property (nonatomic, retain) UIPopoverController *couchListPVC;

- (IBAction)showCouchList:(id)sender;

@end
