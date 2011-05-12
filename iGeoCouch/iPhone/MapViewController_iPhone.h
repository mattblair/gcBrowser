//
//  MapViewController_iPhone.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "AboutViewController.h"

@interface MapViewController_iPhone : MapViewController <AboutViewControllerDelegate> {
    
}

// UI
-(void)addToolbarItems;

- (IBAction)showCouchList:(id)sender;

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex;

- (void)aboutViewControllerDidFinish:(AboutViewController *)aboutViewController;

@end
