//
//  iGeoCouchAppDelegate_iPad.h
//  iGeoCouch
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iGeoCouchAppDelegate.h"
#import "MapViewController_iPad.h"

@interface iGeoCouchAppDelegate_iPad : iGeoCouchAppDelegate {
    
    MapViewController_iPad *mapVC;
}

@property (nonatomic, retain) IBOutlet MapViewController_iPad *mapVC;

@end
