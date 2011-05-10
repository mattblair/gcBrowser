//
//  GeoCouchAnnotation.h
//  gcBrowser
//
//  Created by Matt Blair on 1/16/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface GeoCouchAnnotation : NSObject <MKAnnotation> {

	NSString *title;
	NSString *subtitle;
	NSString *pointID;
	NSNumber *latitude;
	NSNumber *longitude;
    CLLocationCoordinate2D coordinate;
	
	// can declare other ivars here, too, e.g.
	
	//NSString *scientificName;
	
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *pointID;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;


- (id)initWithLocation:(CLLocationCoordinate2D)coord;


@end
