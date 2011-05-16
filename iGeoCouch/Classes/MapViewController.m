//
//  MapViewController.m
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

#import "MapViewController.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "GeoCouchAnnotation.h"
#import "gcBrowserConstants.h"

#pragma mark - 
#pragma mark Constants


// legacy constants: most of this stuff is overridden by now
// this section should probably be weeded out

// region for default view
#define kDefaultRegionLatitude 45.518978
#define kDefaultRegionLongitude -122.676001

#define kDefaultRegionLatitudeDelta 0.020743 // 0.013832
#define kDefaultRegionLongitudeDelta 0.026834// 0.013733

// should be a walkable distance:
#define kCurrentLocationLatitudeDelta 0.011
#define kCurrentLocationLongitudeDelta 0.014


// from pdxPublicArt project, not yet used:
// These are zoom-out increments when nothing is found on the map
#define kSearchResultsLatitudeDeltaMultiplier 1.15
#define kSearchResultsLongitudeDeltaMultiplier 1.2

#define kLatitudeDeltaThreshold 0.03
#define kWidenMapViewIncrement 1.2


@implementation MapViewController


@synthesize infoButton, refreshButton, locationButton, addButton, couchListButton, settingsButton;
@synthesize theMapView, locationManager, locationReallyEnabled, pointsFoundInRegion, mapPointsRequest, theHUD;
@synthesize couchSourceList, currentCouchSourceIndex, currentDatabaseDefinition;

// Core Data - can delete if not used
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // loading couchlist from plist -- will be replaced by JSON soon
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CouchSources" ofType:@"plist"];
    
    NSDictionary *sourceDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSLog(@"Loaded Couch datasource list last edited on %@", [sourceDict objectForKey:@"lastModified"]);
    
    self.couchSourceList = [sourceDict objectForKey:kCouchSourceArrayKey]; 
    

    // last viewed should be read-from/persisted-to user defaults
    self.currentCouchSourceIndex = 0; 
    
    // temporary method to setup database definition - update when switching to JSON
    
    self.currentDatabaseDefinition = [[GeoCouchDatabaseDefinition alloc] init];

    [self reloadDatabaseDefinition];
   
    
    // end of code that needs updating during switch to JSON
    
    
     
    // set delegate here instead of in XIB so it's obvious
    self.theMapView.delegate = self;
    
    
    // Start the location manager and put the user on the map
	if ([CLLocationManager locationServicesEnabled]) {
		// NSLog(@"About to turn Location on...");
		[[self locationManager] startUpdatingLocation];  		
		self.theMapView.showsUserLocation = YES;
		self.locationReallyEnabled = YES;  // to handle CL behavior in iOS 4.1
	}
	else {
		// NSLog(@"Location not available, turning it off for the map.");
		self.theMapView.showsUserLocation = NO;
		self.locationReallyEnabled = NO;  // to handle CL behavior in iOS 4.1
		
	}
	
	// center on the default view:
	
	[self setInitialMapRegion];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.infoButton = nil;
    self.refreshButton = nil;
    self.locationManager = nil;
    self.addButton = nil;
    self.couchListButton = nil;
    self.settingsButton = nil;
    
    self.theHUD = nil;
    
    self.couchSourceList = nil;
    
    self.theMapView = nil;
    self.locationManager = nil;
}


// addToolbarItems is only in the iPhone subclass for now. Might move it up here.

// do you want to support landscape on iPhone? If so, override to YES here, rather than in iPad subclass
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Memory Management

- (void)dealloc
{
    
    [infoButton release];
    [refreshButton release];
    [locationButton release];
    [addButton release];
    [couchListButton release];
    [settingsButton release];
    
    [theHUD release];
    
    [theMapView release];
    [locationManager release];
    
    [couchSourceList release];
    [currentDatabaseDefinition release];
    
    [fetchedResultsController_ release];
    [managedObjectContext_ release];
    
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    //[pointsFoundInRegion release];
    //[mapPointsRequest release];
    
}


#pragma mark -
#pragma mark Button Taps

- (IBAction)showSettings:(id)sender {
	
	// alert only for now...
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setting" 
													message:@"I haven't made the settings yet..." 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	
	[alert release];
	
	
}

- (IBAction)showAboutPage:(id)sender {
	
	// alert -- overridden in subclassses

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" 
													message:@"I haven't made the about page yet..." 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	
	[alert release];
	
}


- (IBAction)showCouchList:(id)sender {
	
    
    // Example code: conditional behavior based on device idiom
    // In most cases, I'm definining presentation in device-specific subclasses
    
    // is there any reason to use one of these over the other?
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
        NSLog(@"It's an iPad -- handled by subclass.");    
        
    }
    else {
        
        NSLog(@"It's not an iPad");
        
    }
    
	
}

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex {
    
    if (didSelect) {
        self.currentCouchSourceIndex = datasourceIndex;
        
        [self reloadDatabaseDefinition];
        
        [self setInitialMapRegion]; // move and reload the map to initial region specified in db def
    }
    
    // subclasses should call super, do anything special they'd like to do, then dismiss as appropriate
    
}

// may be replaced/dratsically altered on switch to JSON
- (void)reloadDatabaseDefinition {
    
    NSDictionary *defDict = [self.couchSourceList objectAtIndex:[self currentCouchSourceIndex]];
    
    // set properties for newly select database def -- object types in flux until RC
    
    self.currentDatabaseDefinition.databaseURL = [defDict objectForKey:kCouchSourceDatabaseURLKey];
    self.currentDatabaseDefinition.pathForBrowserDesignDoc = [defDict objectForKey:kCouchSourcePathKey];
    
    self.currentDatabaseDefinition.name = [defDict objectForKey:kCouchSourceNameKey];
    self.currentDatabaseDefinition.collection = [defDict objectForKey:kCouchSourceCollectionKey];
    
    self.currentDatabaseDefinition.includeDocs = NO; // not implemented yet
    
    // Set initialRegion conditionally. There are default values for span deltas.
    
    NSDictionary *regionDict = [defDict objectForKey:kCouchSourceRegionKey];
    
    CLLocationCoordinate2D newCentroid = CLLocationCoordinate2DMake(
                                [[regionDict objectForKey:kCouchSourceLatitudeKey] doubleValue], 
                                [[regionDict objectForKey:kCouchSourceLongitudeKey] doubleValue]);
    
    MKCoordinateSpan newSpan;
    
    // Should check value, not just class. Also, check whether it's in a range?
    if ([[regionDict objectForKey:kCouchSourceLatitudeDeltaKey] isKindOfClass:[NSNumber class]] && 
        [[regionDict objectForKey:kCouchSourceLongitudeDeltaKey] isKindOfClass:[NSNumber class]]) {
        
        newSpan = MKCoordinateSpanMake(
                            [[regionDict objectForKey:kCouchSourceLatitudeDeltaKey] doubleValue], 
                            [[regionDict objectForKey:kCouchSourceLongitudeDeltaKey] doubleValue]);
        
    }
    else { // defaults set here, overriding object's init
        
        newSpan = MKCoordinateSpanMake(kCurrentLocationLatitudeDelta, kCurrentLocationLongitudeDelta);
    }
    
    self.currentDatabaseDefinition.initialRegion = MKCoordinateRegionMake(newCentroid, newSpan);
    
    
#warning Incomplete: doesn't read all the properties yet, but I'm waiting until JSON conversion to finish it
}


- (IBAction)showNewPointEditor:(id)sender {
	
	// alert only for now...
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add New Point" 
													message:@"I haven't made the point editor yet..." 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	
	[alert release];
	
}

#pragma mark -
#pragma mark Interacting with GeoCouch

- (IBAction)refreshPointsOnMap {
	
	/*
	 
	 Coordinates for bounding box should be lower left, upper right:
	 
	 westLongitude, southLatitude, eastLongitude, northLatitude
	 
	 i.e. for Portland metro area, we can use:
	 
	 -122.776626,45.436756,-122.482245,45.649049
	 
	 */
	
	// make sure refresh button is disabled
	refreshButton.enabled = NO;
	
	//get coordinates for current map view
	
	MKCoordinateRegion region = theMapView.region;
	
	NSNumber *southLatitude = [NSNumber numberWithDouble:region.center.latitude - region.span.latitudeDelta/2.0];
    NSNumber *northLatitude = [NSNumber numberWithDouble:region.center.latitude + region.span.latitudeDelta/2.0];
    NSNumber *westLongitude = [NSNumber numberWithDouble:region.center.longitude - region.span.longitudeDelta/2.0];
    NSNumber *eastLongitude = [NSNumber numberWithDouble:region.center.longitude + region.span.longitudeDelta/2.0];
    
    NSString *databaseURL = self.currentDatabaseDefinition.databaseURL;
      
    NSString *pathForMapSearch = self.currentDatabaseDefinition.pathForBrowserDesignDoc;
    
	//construct the URL -- trim the floats?
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@,%@,%@,%@", 
						   databaseURL, pathForMapSearch, westLongitude, southLatitude, eastLongitude, northLatitude];
	
	
	// initiate a request to GeoCouch
	
	NSLog(@"The request URL will be: %@", urlString);
	
	// Check Reachability first
	// don't use a host check on the main thread because of possible DNS delays...
	
	/*
	 enum {
	 
	 // Apple NetworkStatus Constant Names.
	 NotReachable     = kNotReachable,
	 ReachableViaWiFi = kReachableViaWiFi,
	 ReachableViaWWAN = kReachableViaWWAN
	 
	 };
	 */
	
	NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	
	// Testing: can be commented before release
	if (status == ReachableViaWiFi) {
		// wifi connection
		NSLog(@"Map View Geoquery Request: Wi-Fi is available.");
	}
	if (status == ReachableViaWWAN) {
		// wwan connection (could be GPRS, 2G or 3G)
		NSLog(@"Map View Geoquery Request: Only network available is 2G or 3G");	
	}
	
	if (status == kReachableViaWiFi || status == kReachableViaWWAN) { 
		
		
		// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
		// method "reachabilityChanged" will be called. 
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) 
													 name: kReachabilityChangedNotification 
												   object: nil];
		
		internetReach = [[Reachability reachabilityForInternetConnection] retain];
		[internetReach startNotifier];
		
		// need to show status to user somewhere?
		
		NSURL *url = [NSURL URLWithString:urlString];
		
		//start request
		self.mapPointsRequest = [ASIHTTPRequest requestWithURL:url];
		
		[[self mapPointsRequest] setDelegate:self];
		[[self mapPointsRequest] startAsynchronous];
		
        // Update UI
        
        self.theHUD = [MBProgressHUD showHUDAddedTo:self.theMapView animated:YES];      
        self.theHUD.labelText = @"Requesting Points...";
        self.theHUD.alpha = 0.8;
		
	} // end of if reachable by wifi or wwan
	
	else {
		
		// no wifi or wwan
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" 
														message:@"The Internet is not available." 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		// load from core data? Or from local Couchbase eventually
		
	}
	
	
	// release url string here, or only create it if internet is reachable
	
	[urlString release];
	
	
}

#pragma mark -
#pragma mark Handle GeoCouch Response

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	// test the response
	
	if ([request responseStatusCode] == 200) {  // only checking for GET right now
		
		// parse the JSON
		
		NSString *responseString = [request responseString];
		
		if ([[responseString JSONValue] isKindOfClass:[NSDictionary class]]) {
			
			//NSLog(@"Response is a dictionary");
			
			NSDictionary *pointsJSON = [responseString JSONValue];
			
			// test if the rows key is an array
			
			if ([[pointsJSON objectForKey:@"rows"] isKindOfClass:[NSArray class]]) {
				
                //NSLog(@"Rows key is an array");
				
				NSArray *pointsArray = [pointsJSON objectForKey:@"rows"];
				
				if ([pointsArray count] > 0) {
					if ([[pointsArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
						
						//NSLog(@"Dictionary for object 0: %@", [[pointsArray objectAtIndex:0] description]);
						
						// emitted by standard gcBrowser design doc:
						// keys: bbox, id, value: { title, subtitle }
						
						
						/*
                         
                         Sample code from PublicArtPDX:
                         
						 NSDictionary *anArtwork = [artworkArray objectAtIndex:0];
						 
						 NSLog(@"The artwork %@ is a %@ with id %@", 
						 [[anArtwork valueForKey:@"value"] valueForKey:@"name"], 
						 [[anArtwork valueForKey:@"value"] valueForKey:@"discipline"], 
						 [anArtwork valueForKey:@"id"]);
						 
						 NSLog(@"Coordinates are lat %@ and long %@", 
						 [[anArtwork valueForKey:@"bbox"] objectAtIndex:1],
						 [[anArtwork valueForKey:@"bbox"] objectAtIndex:0]);
						 
						 */
						
                        // create annotations from the dictionary objects
						
						NSLog(@"Number of points retrieved from GeoCouch: %d", [pointsArray count]);
						
						//NSLog(@"Clearing and refilling the annotations array");
                        
                        // explicit release at the end was causing bad access on iPhone but not iPad
                        // b/c of MKMapView pokiness?
                        //NSMutableArray *pointAnnotationArray = [[[NSMutableArray alloc] initWithCapacity:12] autorelease]; 
                        // switching to ivar mutable array
                        
                        if (self.pointsFoundInRegion) {
                            [self.pointsFoundInRegion removeAllObjects];
                        }
                        else {
                            NSMutableArray *pointAnnotationArray = [[NSMutableArray alloc] initWithCapacity:12];
                            self.pointsFoundInRegion = pointAnnotationArray;
                            [pointAnnotationArray release];
                        }
                        
						GeoCouchAnnotation *ga = nil;
                        
						// Created an annotation for each point returned
						
						for (NSDictionary *aPoint in pointsArray) {
							
							// create an annotation
							
							ga = [[GeoCouchAnnotation alloc] init];
							
                            [ga setTitle:[[aPoint valueForKey:@"value"] 
                                          valueForKey:self.currentDatabaseDefinition.keyForTitle]];
							
                            [ga setSubtitle:[[aPoint valueForKey:@"value"] 
                                             valueForKey:self.currentDatabaseDefinition.keyForSubtitle]];
							
							// make this less ugly? The problem is it's originally an NSString
							[ga setLatitude:[NSNumber numberWithDouble:[[[aPoint valueForKey:@"bbox"] objectAtIndex:1] doubleValue]]];
							[ga setLongitude:[NSNumber numberWithDouble:[[[aPoint valueForKey:@"bbox"] objectAtIndex:0] doubleValue]]];
							
							[ga setPointID:[aPoint valueForKey:@"id"]];
							
                            [self.pointsFoundInRegion addObject:ga];
							
							[ga release];
							
						}
						
                        NSLog(@"self.pointsFoundInRegion has %d points in it.", [self.pointsFoundInRegion count]);
						
						// want to clear out old annotations but keep the user's location
                        // because it can take a while to come back
						
						NSArray *oldAnnotations = theMapView.annotations;
						
						NSPredicate *userLocationPredicate = [NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]];
						
						NSArray *annotationsToRemove = [oldAnnotations filteredArrayUsingPredicate:userLocationPredicate];
                        
						[theMapView removeAnnotations:annotationsToRemove];
						
                        [theMapView addAnnotations:self.pointsFoundInRegion];
						                        
					}
					else {
						NSLog(@"requestFinished: No dictionary objects found that represent points.");
					}
				}
				else {
					NSLog(@"requestFinished: No points found for this search.");
				}
				
			}
			else {
				NSLog(@"requestFinished: Unexpected results. Rows key is NOT an array");
			}
			
			
			
			
		}
		
		else {
			
			
			// TESTING ONLY Shouldn't happen in real life. (Like all bugs...)
			
			NSLog(@"requestFinished: Unexpected results. Response is not a dictionary");
            
			NSLog(@"No points found for this region search...");
			
			// notify user?
            
            
		}
		
		
		
		
	}
	
	else {
		// handle the error
		
		NSLog(@"Geo-search HTTP Status code was: %d", [request responseStatusCode]);
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" 
														message:@"Sorry, unexpected reponse from the server. Please try again in a few moments." 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
    
    [self.theHUD hide:YES afterDelay:1.0];
    
    self.mapPointsRequest = nil;
	
	
}


- (void)requestFailed:(ASIHTTPRequest *)request {
	
	// handle the failure
	
	NSLog(@"Search request failed: %d", [request responseStatusCode]);
	
	NSError *error = [request error];
	
    // not really an error
	if (([error code] == 4) && ([[error domain] isEqualToString:@"ASIHTTPRequestErrorDomain"])) {  
		NSLog(@"Cancellation initiated by Reachability notification.");
		
	}
	else {
		NSLog(@"The HTTP Status code was: %d", [request responseStatusCode]);
		
		NSLog(@"Error requesting art: %@", [error description]);	
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Problem" 
														message:@"Sorry, the list of points is temporarily unavailable. Please try again in a few moments." 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
    [self.theHUD hide:YES afterDelay:1.0];
    
    self.mapPointsRequest = nil;
    
}


// if you need to find a region for an arbitrary set of points, see this method in PublicArtPDX:
// -(MKCoordinateRegion)makeRegionForAnnotationArray:(NSArray *)annotationArray {


#pragma mark -
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)map regionDidChangeAnimated:(BOOL)animated {
	
	//enable the refresh button to make a new search request possible
    
	refreshButton.enabled = YES;
	
	// uncomment this to see every region change in the console
    // this is helpful for determing an initial view for a dataset
	
    NSLog(@"Map view changed to new region...");
    NSLog(@"This region's latitude is: %f", map.region.center.latitude);
    NSLog(@"This region's longitude is: %f", map.region.center.longitude);
    NSLog(@"This region's latitude delta is: %f", map.region.span.latitudeDelta);
    NSLog(@"This region's longitude delta is: %f", map.region.span.longitudeDelta);
	
}

// override in iPad version if you don't want to use the callout
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // Don't alter the current location
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	// Try to dequeue an existing pin view first.
	MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView
														  dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
	
	if (!pinView)
	{
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
												   reuseIdentifier:@"CustomPinAnnotationView"] 
				   autorelease];
		pinView.pinColor = MKPinAnnotationColorRed;
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		pinView.rightCalloutAccessoryView = rightButton;
	}
	
	return pinView;
	
}


// override this in the subclasses for device-specific presentation
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
	
	// show alert view with details in superclass 
    
    // device-specific subclasses should override this to show PointDetailViewController
	// sub-classes do not need to call super
	
	// see PDXTrees for an example of using annotation to request full object from Core Data
	// then setting that object for display in a view controller. 
	
	// get access to the original annotation
	GeoCouchAnnotation *selectedPoint = view.annotation;
	NSLog(@"The ID of the selected point is: %@", [selectedPoint pointID]);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Point ID" 
													message:[selectedPoint pointID]
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	
	[alert release];
	
}

#pragma mark -
#pragma mark Map Move and Load

// this method should be run in viewDidLoad and after changing datasources
// because they might not have an accurate coordinate from CL yet

- (void)setInitialMapRegion { 
	
	MKCoordinateRegion newRegion;
    
    // If you always want the user to return to the initial map region:
    
    /*
	newRegion.center.latitude = kDefaultRegionLatitude;
	newRegion.center.longitude = kDefaultRegionLongitude;
	
	newRegion.span.latitudeDelta = kDefaultRegionLatitudeDelta;
	newRegion.span.longitudeDelta = kDefaultRegionLongitudeDelta;
    */
    
    
    // or read values specific to the selected database instead
    
    newRegion = self.currentDatabaseDefinition.initialRegion;
	
	// correct the aspect ratio -- does not work well across devices and orientations yet
	MKCoordinateRegion fitRegion = [theMapView regionThatFits:newRegion];
	
    [theMapView setRegion:fitRegion animated:YES];
	
	[self refreshPointsOnMap];
	
	// Update UI to prevent accidental search requests that would return the same results
	self.refreshButton.enabled = NO;
	
}


// this method is run when the user requests a move by tapping the location button
- (IBAction)goToLocation {
	
	MKCoordinateRegion newRegion;
	
    
    // add accuracy/timestamp test here? See PDX Trees for an example
	if ([CLLocationManager locationServicesEnabled] && self.locationReallyEnabled) {
		
		newRegion.center = [[[self locationManager] location] coordinate]; // handles lat/long
        
		newRegion.span.latitudeDelta = kCurrentLocationLatitudeDelta;
        
		newRegion.span.longitudeDelta = kCurrentLocationLongitudeDelta; 
		
	}
	
	else {
		
		// default region
		NSLog(@"Location not available. Returning to default for this database.");
        
        newRegion = self.currentDatabaseDefinition.initialRegion;		
	}
	
	
	// correct the aspect ratio -- not working across all devices
	MKCoordinateRegion fitRegion = [self.theMapView regionThatFits:newRegion];
	
    [self.theMapView setRegion:fitRegion animated:YES];
	
	// Reload the art for the newly-set region
	[self refreshPointsOnMap];
	
	// disable the refresh button if needed
	self.refreshButton.enabled = NO;
	
}


#pragma mark -
#pragma mark Location Manager Delegate

// based on Photo Locations sample code and Location Awareness PG

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters]; // or kCLLocationAccuracyNearestTenMeters if you need accuracy more than battery life
	[locationManager setDelegate:self];
	
	return locationManager;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	// check how recent the location is
	
	NSDate *newLocationDate = newLocation.timestamp;
	NSTimeInterval timeDiff = [newLocationDate timeIntervalSinceNow];
	
	// For Troubleshooting
	// NSLog(@"Coordinate received with accuracy radius of %f meters.", newLocation.horizontalAccuracy);
	
	// horizontal accuracy is a radius in meters. Is 100 too much? 
	// a negative value indicates an invalid coordinate
	
	// changed accuracy check to greater than 2 because of erratic behavior in 4.1
	
	if ((abs(timeDiff) < 15.0) && (newLocation.horizontalAccuracy < 100.0) && (newLocation.horizontalAccuracy >= 2.0))
	{
		
		
		// turn this on as needed for troubleshooting
		//NSLog(@"Recent and accurate location received...");
		//NSLog(@"The new location's latitude is: %f", newLocation.coordinate.latitude);
		//NSLog(@"The new location's longitude is: %f", newLocation.coordinate.longitude);
		
		
		locationReallyEnabled = YES;  // to handle CL behavior in iOS 4.1
		
		
	}	
	
	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
	// handle location failure -- with user notification? Or silently?
	
	/*
	 NSLog(@"Location Failure.");
	 NSLog(@"Error: %@", [error localizedDescription]);
	 NSLog(@"Error code %d in domain: %@", [error code], [error domain]);
	 */
	
	
	// because locationServicesEnabled class method is erratic in 4.1, need to handle this here
	// set a BOOL on the VC that tells it location has failed.
	
	if (([error code] == 1) && ([[error domain] isEqualToString:@"kCLErrorDomain"])) {
		locationReallyEnabled = NO;  // to handle CL behavior in iOS 4.1
		
		// does it stop updating automatically? Just in case...
		
		[[self locationManager] stopUpdatingLocation];
		
	}
	
}




#pragma mark -
#pragma mark Reachability Handling

-(void)reachabilityChanged: (NSNotification* )note {
	
	// respond to changes in reachability
	
	Reachability *currentReach = [note object];
	
	NetworkStatus status = [currentReach currentReachabilityStatus];
	
	if (status == NotReachable) {  
		[self killRequest];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost" 
														message:@"Please try again when you have an internet connection." 
													   delegate:self 
											  cancelButtonTitle:@"Cancel" 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		
		
	}
	
}


- (void)killRequest {
	
	if ([[self mapPointsRequest] inProgress]) {
		
		[[self mapPointsRequest] cancel];
		
		NSLog(@"Request cancelled by killRequest");
        
        if (self.theHUD) {
            
            self.theHUD = nil; // or does request failure handle this?
            
        }
		
	}
	
}



@end
