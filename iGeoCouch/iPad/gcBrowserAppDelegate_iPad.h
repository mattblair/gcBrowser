//
//  gcBrowserAppDelegate_iPad.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gcBrowserAppDelegate.h"
#import "MapViewController_iPad.h"

@interface gcBrowserAppDelegate_iPad : gcBrowserAppDelegate {
    
    MapViewController_iPad *mapVC;
}

@property (nonatomic, retain) IBOutlet MapViewController_iPad *mapVC;

@end
