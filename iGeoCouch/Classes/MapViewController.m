//
//  MapViewController.m
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "MapViewController.h"
#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"
#import "GeoCouchAnnotation.h"
#import "gcBrowserConstants.h"

#pragma mark - 
#pragma mark Constants

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
@synthesize theMapView, locationManager, locationReallyEnabled, pointsFoundInRegion, mapPointsRequest;
@synthesize couchSourceList, currentCouchSource, currentDatabaseDefinition;

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
    
    // load couchlist from plist -- will be replaced by JSON
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CouchSources" ofType:@"plist"];
    
    NSDictionary *sourceDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSLog(@"Loaded Couch datasource list last edited on %@", [sourceDict objectForKey:@"lastModified"]);
    
    self.couchSourceList = [sourceDict objectForKey:kCouchSourceArrayKey]; 
    

    // last viewed should be read-from/persist-to user defaults
    self.currentCouchSource = 0; 
    
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
    [pointsFoundInRegion release];
    [mapPointsRequest release];
    
    // release Core Data here? Or hang on to it?
    
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
	
	// alert only for now...
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"About" 
													message:@"I haven't made the about page yet..." 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	
	[alert release];
	
	
}


- (IBAction)showCouchList:(id)sender {
	
    
    // place holder for subclass overrides, if needed
    
    // is there any reason to use one of these over the other?
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    
        // do this...
        NSLog(@"It's an iPad -- handled by subclass.");
        
        
    }
    else {
        
        NSLog(@"It's not an iPad");
        
    }
    
	
}

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex {
    
    if (didSelect) {
        self.currentCouchSource = datasourceIndex;
        
        [self reloadDatabaseDefinition];
        
        [self setInitialMapRegion]; // move and reload the map
    }
    
    // subclasses should call super, do anything special they'd like to do, then dismiss as appropriate
    
}

// may be replaced/dratsically altered on switch to JSON
- (void)reloadDatabaseDefinition {
    
    NSDictionary *defDict = [self.couchSourceList objectAtIndex:[self currentCouchSource]];
    
    // set properties for newly select database def -- object types in flux until RC
    
    self.currentDatabaseDefinition.databaseURL = [defDict objectForKey:kCouchSourceDatabaseURLKey];
    self.currentDatabaseDefinition.pathForBrowserDesignDoc = [defDict objectForKey:kCouchSourcePathKey];
    
    self.currentDatabaseDefinition.name = [defDict objectForKey:kCouchSourceNameKey];
    self.currentDatabaseDefinition.collection = [defDict objectForKey:kCouchSourceCollectionKey];
    
    self.currentDatabaseDefinition.includeDocs = NO; // not implemented yet
    
    // initial region -- it expects NSNumbers in an NSDictionary at the moment
    
    self.currentDatabaseDefinition.initialRegion = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defDict objectForKey:kCouchSourceLatitudeKey], kCouchSourceLatitudeKey,
                            [defDict objectForKey:kCouchSourceLongitudeKey], kCouchSourceLongitudeKey,
                            [defDict objectForKey:kCouchSourceLatitudeKey], kCouchSourceLatitudeKey,
                            [defDict objectForKey:kCouchSourceLongitudeKey], kCouchSourceLongitudeKey,
                            nil];
    
#warning Incomplete: doesn't read all the properties yet, but I'm waiting until JSON conversion to finish it
}


- (IBAction)showNewPointEditor:(id)sender {
	
	// alert only for now...
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add New Point" 
													message:@"I haven't made the new point editor yet..." 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	
	[alert release];
	
	
}

#pragma mark -
#pragma mark Interacting with GeoCouch

// should this return void, and have a wrapper method to connect ot the button via IBAction?

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
	
    NSString *databaseURL = [[self.couchSourceList objectAtIndex:[self currentCouchSource]] 
                             objectForKey:kCouchSourceDatabaseURLKey];
    
    NSString *pathForMapSearch = [[self.couchSourceList objectAtIndex:[self currentCouchSource]] 
                                  objectForKey:kCouchSourcePathKey];
    
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
		NSLog(@"Map View Point Request: Wi-Fi is available.");
	}
	if (status == ReachableViaWWAN) {
		// wwan connection (could be GPRS, 2G or 3G)
		NSLog(@"Map View Point Request: Only network available is 2G or 3G");	
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
		
		
	} // end of if reachable by wifi or wwan
	
	else {
		
		// no wifi or wwan
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" 
														message:@"The internet is not available." 
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
			
			NSLog(@"Top Level is a dictionary");
			
			NSDictionary *pointsJSON = [responseString JSONValue];
			
			// test if the rows key is an array
			
			if ([[pointsJSON objectForKey:@"rows"] isKindOfClass:[NSArray class]]) {
				NSLog(@"Rows key is an array");
				
				NSArray *pointsArray = [pointsJSON objectForKey:@"rows"];
				
				if ([pointsArray count] > 0) {
					if ([[pointsArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
						
						NSLog(@"Dictionary for object 0: %@", [[pointsArray objectAtIndex:0] description]);
						
						// generic gcBrowser format is:
						// keys: bbox, id, value { title, subtitle }
						
						
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
						
						NSLog(@"Clearing and refilling the annotations array");
                        
                        // explicit release at the end was causing bad access on iPhone but not iPad
                        // b/c of MKMapView pokiness?
                        //NSMutableArray *pointAnnotationArray = [[[NSMutableArray alloc] initWithCapacity:12] autorelease]; 
						
                        // switching to ivar mutable array, which will stick around
                        if (self.pointsFoundInRegion) {
                            [self.pointsFoundInRegion removeAllObjects];
                        }
                        else {
                            NSMutableArray *pointAnnotationArray = [[NSMutableArray alloc] initWithCapacity:12];
                            self.pointsFoundInRegion = pointAnnotationArray;
                            [pointAnnotationArray release];
                        }
                        
						GeoCouchAnnotation *ga = nil;
						
						// loop and add
						
						for (NSDictionary *aPoint in pointsArray) {
							
							// create an annotation
							
							ga = [[GeoCouchAnnotation alloc] init];
							
							[ga setTitle:[[aPoint valueForKey:@"value"] valueForKey:@"title"]];
							
							[ga setSubtitle:[[aPoint valueForKey:@"value"] valueForKey:@"subtitle"]];
							
							// make this less ugly? The problem is it's originally an NSString
							[ga setLatitude:[NSNumber numberWithDouble:[[[aPoint valueForKey:@"bbox"] objectAtIndex:1] doubleValue]]];
							[ga setLongitude:[NSNumber numberWithDouble:[[[aPoint valueForKey:@"bbox"] objectAtIndex:0] doubleValue]]];
							
							[ga setPointID:[aPoint valueForKey:@"id"]];
							
							//[pointAnnotationArray addObject:ga];
                            [self.pointsFoundInRegion addObject:ga];
							
							[ga release];
							
						}
						
                        
						//NSLog(@"pointAnnotationArray has %d points in it.", [pointAnnotationArray count]);
                        NSLog(@"pointAnnotationArray has %d points in it.", [self.pointsFoundInRegion count]);
						
						// want to clear out old annotations but keep the user's location
                        // because it can take a while to come back
						
						NSArray *oldAnnotations = theMapView.annotations;
						
						NSPredicate *userLocationPredicate = [NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]];
						
						NSArray *annotationsToRemove = [oldAnnotations filteredArrayUsingPredicate:userLocationPredicate];
                        
						[theMapView removeAnnotations:annotationsToRemove];
						
						//[theMapView addAnnotations:pointAnnotationArray]; 
                        [theMapView addAnnotations:self.pointsFoundInRegion];
						
                        // causing crash on iPhone but not iPad? autoreleasing the array instead
                        //[pointAnnotationArray release];  
                        
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
			
			
			// TESTING ONLY Shouldn't happen in real life. Like all bugs.
			
			NSLog(@"requestFinished: Unexpected results. Top Level is not a dictionary");
            
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
    
    
    self.mapPointsRequest = nil;
	
	
}


- (void)requestFailed:(ASIHTTPRequest *)request {
	
	// handle the failure
	
	NSLog(@"Search request failed: %d", [request responseStatusCode]);
	
	NSError *error = [request error];
	
	if (([error code] == 4) && ([[error domain] isEqualToString:@"ASIHTTPRequestErrorDomain"])) {  // not an error
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
    // this is helpful for selecting an initial view for a dataset
	
    NSLog(@"Map view changed to new region...");
    NSLog(@"This region's latitude is: %f", map.region.center.latitude);
    NSLog(@"This region's longitude is: %f", map.region.center.longitude);
    NSLog(@"This region's latitude delta is: %f", map.region.span.latitudeDelta);
    NSLog(@"This region's longitude delta is: %f", map.region.span.longitudeDelta);
	
}

// override in iPad version if you don't want to use the callout
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	// Try to dequeue an existing pin view first.
	MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView
														  dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
	
	if (!pinView)
	{
		// If an existing pin view was not available, create one.
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
												   reuseIdentifier:@"CustomPinAnnotationView"] 
				   autorelease];
		pinView.pinColor = MKPinAnnotationColorRed;
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		
		// Add a detail disclosure button to the callout
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
	// then setting that object for display in a view Controller. 
	
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
    
    // read values specific to datasource instead
    /*
	newRegion.center.latitude = kDefaultRegionLatitude;
	newRegion.center.longitude = kDefaultRegionLongitude;
	
	newRegion.span.latitudeDelta = kDefaultRegionLatitudeDelta;
	newRegion.span.longitudeDelta = kDefaultRegionLongitudeDelta;
    */
	
    NSDictionary *currentSource = [self.couchSourceList objectAtIndex:[self currentCouchSource]];
    
    NSLog(@"setInitialMapRegion: %@", currentSource);
    
    NSDictionary *initialRegion = [currentSource objectForKey:kCouchSourceRegionKey]; // collapse this to one dictionary?
    
    newRegion.center.latitude = [[initialRegion objectForKey:kCouchSourceLatitudeKey] doubleValue];
	newRegion.center.longitude = [[initialRegion objectForKey:kCouchSourceLongitudeKey] doubleValue];
	
	newRegion.span.latitudeDelta = [[initialRegion objectForKey:kCouchSourceLatitudeDeltaKey] doubleValue];
	newRegion.span.longitudeDelta = [[initialRegion objectForKey:kCouchSourceLongitudeDeltaKey] doubleValue];
    
	
	// correct the aspect ratio -- does not work well across devices and orientations yet
	MKCoordinateRegion fitRegion = [theMapView regionThatFits:newRegion];
	
    [theMapView setRegion:fitRegion animated:YES];
	
	[self refreshPointsOnMap];
	
	// prevent accidental search requests
	self.refreshButton.enabled = NO;
	
}


// this method is run when the user requests a move by tapping the location button
- (IBAction)goToLocation {
	
	MKCoordinateRegion newRegion;
	
	// temp method to go to default location only...
	NSLog(@"Placeholder adjustMapRegion goes to default region only.");
	
	// default region -- haven't implemented yet
	
	newRegion.center.latitude = kDefaultRegionLatitude;
	newRegion.center.longitude = kDefaultRegionLongitude;
	
	newRegion.span.latitudeDelta = kDefaultRegionLatitudeDelta;
	newRegion.span.longitudeDelta = kDefaultRegionLongitudeDelta;
	
	
	// correct the aspect ratio -- not working
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
	
	
	// set a bool on the VC that tells it location has failed.
	
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
		
	}
	
}



@end
