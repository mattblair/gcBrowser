//
//  iGeoCouchAppDelegate_iPhone.m
//  iGeoCouch
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "iGeoCouchAppDelegate_iPhone.h"

@implementation iGeoCouchAppDelegate_iPhone

@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc
{
	
    [navigationController release];
    
    [super dealloc];
}

@end
