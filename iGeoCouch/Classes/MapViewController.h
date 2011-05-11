//
//  MapViewController.h
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>  // needed to test if it's on before adding to map

#import "CouchListViewController.h" // or just declare the protocol?
#import "GeoCouchDatabaseDefinition.h"

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
    Reachability* internetReach;
	
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

// UI - iPhone only for now. Move here? Do it all in the nib?
//- (void)addToolbarItems;

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
