//
//  MapViewController_iPhone.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface MapViewController_iPhone : MapViewController {
    
}

// UI
-(void)addToolbarItems;

- (IBAction)showCouchList:(id)sender;

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex;

@end
