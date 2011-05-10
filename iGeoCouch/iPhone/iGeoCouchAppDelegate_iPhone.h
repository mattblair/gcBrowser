//
//  iGeoCouchAppDelegate_iPhone.h
//  iGeoCouch
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iGeoCouchAppDelegate.h"

@interface iGeoCouchAppDelegate_iPhone : iGeoCouchAppDelegate {
    
    UINavigationController *navigationController;
    
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end
