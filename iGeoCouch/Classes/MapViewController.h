//
//  MapViewController.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//
//  Copyright (c) 2011, Elsewise LLC
//  All rights reserved.
// 
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this 
//     list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//     this list of conditions and the following disclaimer in the documentation 
//     and/or other materials provided with the distribution.
//  * Neither the name of Elsewise LLC nor the names of its contributors may be 
//     used to endorse or promote products derived from this software without 
//     specific prior written permission.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>  // to test if CL's enabled before adding to map

#import "CouchListViewController.h" // or just declare the protocol
#import "GeoCouchDatabaseDefinition.h"
#import "MBProgressHUD.h"

@class ASIHTTPRequest;
@class Reachability;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, CouchListDelegate> {
	
	// UI
	UIButton *infoButton;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *locationButton;
    UIBarButtonItem *addButton;
    UIBarButtonItem *couchListButton;
    UIBarButtonItem *settingsButton;
	
	// Manage requests and connection
	ASIHTTPRequest *mapPointsRequest;
    Reachability *internetReach;
    MBProgressHUD *theHUD;
	
	// Mapping and location
	MKMapView *theMapView;
	CLLocationManager *locationManager;		
	BOOL locationReallyEnabled;  // to handle CL behavior in iOS 4.1
	NSMutableArray *pointsFoundInRegion; 
    
    NSUInteger currentCouchSourceIndex;
    NSArray *couchSourceList; // make mutable for editing? Or just nil and reload?
    GeoCouchDatabaseDefinition *currentDatabaseDefinition;
    
	// Core Data
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;	
    
}

// UI
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *locationButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *couchListButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;

// Mapping  and location
@property (nonatomic, retain) IBOutlet MKMapView *theMapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationReallyEnabled;
@property (nonatomic, retain) NSMutableArray *pointsFoundInRegion; 


// Database list

@property (nonatomic) NSUInteger currentCouchSourceIndex; 
@property (nonatomic, retain) NSArray *couchSourceList;
@property (nonatomic, retain) GeoCouchDatabaseDefinition *currentDatabaseDefinition;


// Core Data
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (retain) ASIHTTPRequest *mapPointsRequest;
@property (nonatomic, retain) MBProgressHUD *theHUD;

// to kill requests on Reachability failure
- (void)killRequest;

// map management
- (void)setInitialMapRegion;

// add this if you need to calculate a display region for an arbitrary set of points
//-(MKCoordinateRegion)makeRegionForAnnotationArray:(NSArray *)annoArray;

// User-initiated

- (IBAction)refreshPointsOnMap; // called by UI and other methods
- (IBAction)goToLocation; // called on init or load of new data source? Add region as argument?

// Would you ever call these programmatically?
- (IBAction)showSettings:(id)sender;
- (IBAction)showAboutPage:(id)sender;
- (IBAction)showCouchList:(id)sender;
- (IBAction)showNewPointEditor:(id)sender;

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex;

- (void)reloadDatabaseDefinition;

@end
