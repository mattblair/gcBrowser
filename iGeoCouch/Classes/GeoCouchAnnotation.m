//
//  GeoCouchAnnotation.m
//  iGeoCouch
//
//  Created by Matt Blair on 1/16/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "GeoCouchAnnotation.h"


@implementation GeoCouchAnnotation

@synthesize title, subtitle, pointID, latitude, longitude;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}


- (CLLocationCoordinate2D)coordinate
{
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}


- (void)dealloc {
	
	[title release];
	[subtitle release];
	[pointID release];
	[latitude release];
	[longitude release];
	
    [super dealloc];
}


@end
