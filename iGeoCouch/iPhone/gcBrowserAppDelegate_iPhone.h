//
//  gcBrowserAppDelegate_iPhone.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gcBrowserAppDelegate.h"

@interface gcBrowserAppDelegate_iPhone : gcBrowserAppDelegate {
    
    UINavigationController *navigationController;
    
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end
