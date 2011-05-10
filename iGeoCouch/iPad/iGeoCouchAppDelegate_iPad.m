//
//  iGeoCouchAppDelegate_iPad.m
//  iGeoCouch
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "iGeoCouchAppDelegate_iPad.h"

@implementation iGeoCouchAppDelegate_iPad

@synthesize mapVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self.window addSubview:mapVC.view];
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)dealloc
{
    [mapVC release];
    
	[super dealloc];
}

@end
