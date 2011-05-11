//
//  MapViewController_iPad.m
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "MapViewController_iPad.h"
#import "CouchListViewController.h"
#import "GeoCouchAnnotation.h"
#import "PointDetailTableViewController.h"
#import "gcBrowserConstants.h"


@implementation MapViewController_iPad

@synthesize couchListPVC, mapCalloutPVC;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [couchListPVC release];
    [mapCalloutPVC release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.couchListPVC = nil;
    self.mapCalloutPVC = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Overrides of Button Taps

- (IBAction)showCouchList:(id)sender {
 
    [super showCouchList:sender];
    
    if (self.couchListPVC.isPopoverVisible) {
        
        [self.couchListPVC dismissPopoverAnimated:YES];
        NSLog(@"dismissed couchListPVC");
        
    }

    else {

        if (!self.couchListPVC) {
            
            NSLog(@"couchListPVC does not exist");
            
            CouchListViewController *couchListVC = [[CouchListViewController alloc] initWithNibName:@"CouchListViewController" bundle:nil];
            
            // pass the array loaded from the plist in super to be the datasource
            couchListVC.couchSourceList = self.couchSourceList;
            
            couchListVC.title = @"GeoCouch Data Sources";
            
            couchListVC.delegate = self;
            
            couchListVC.currentCouchSourceIndex = self.currentCouchSourceIndex;
            
            CGSize couchPopoverSize = CGSizeMake(320.0, 550.0);
            
            couchListVC.contentSizeForViewInPopover = couchPopoverSize;
            
            UIPopoverController *couchPopover = [[UIPopoverController alloc] initWithContentViewController:couchListVC];
            
            [couchListVC release];
            
            self.couchListPVC = couchPopover;
            
            [couchPopover release];
        }
        
        [self.couchListPVC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    
    
}

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex {
    
    [super couchListViewController:couchListViewController didSelectDatasource:didSelect atIndex:datasourceIndex];
    
    // do any iPad specific configuration to new datasource here
    
    [self.couchListPVC dismissPopoverAnimated:YES];
    
}


#pragma mark - MapView Delegate


// overriding here to omit callout and right accessory
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

	}
	
	return pinView;
	
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    // show popover here instead?
    NSLog(@"Annotation selected: %@", [view.annotation title]);
    
    if (self.mapCalloutPVC.isPopoverVisible) {
        [self.mapCalloutPVC dismissPopoverAnimated:YES];
        
        // need to deselct the view so this works as a toggle without tap another annotation first
        
        // not working -- it's not getting deselected until another one is tapped
        // see note in docs -- you're supposed to use map view to handle this.
        //[view setSelected:NO animated:YES]; 
        [self.theMapView deselectAnnotation:view.annotation animated:YES];
    }
    else {
        
        GeoCouchAnnotation *selectedPoint = view.annotation;
        NSLog(@"The ID of the selected point is: %@", [selectedPoint pointID]);
        
        // class-check to guard against random error where pointID is returning a random chunk of memory
        if ([[selectedPoint pointID] isKindOfClass:[NSString class]]) {
            
            if (!self.mapCalloutPVC) {
                
                // set it up here
                
                NSLog(@"Building the point popover");
                
                PointDetailTableViewController *pointVC = [[PointDetailTableViewController alloc] initWithNibName:@"PointDetailTableViewController" bundle:nil];
                
                
                // if you keep this approach, switch keys to constants, and explicitly alloc/init/release
                NSDictionary *annotationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [selectedPoint title],@"title",
                                                [selectedPoint subtitle],@"subtitle",
                                                [[selectedPoint latitude] stringValue],@"latitude",
                                                [[selectedPoint longitude] stringValue],@"longitude",
                                                nil];
                
                pointVC.pointDictionary = annotationDict;
                
                CGSize mapPopoverSize = CGSizeMake(320.0, 220.0);
                
                pointVC.contentSizeForViewInPopover = mapPopoverSize;
                
                UIPopoverController *pointPopover = [[UIPopoverController alloc] initWithContentViewController:pointVC];
                
                self.mapCalloutPVC = pointPopover;
                
                [pointVC release];
                
                [pointPopover release];
                
            }
            
            // pass the new information -- tis kind of ugly at the moment?
            
            PointDetailTableViewController *pointDetailVC = (PointDetailTableViewController *)[self.mapCalloutPVC contentViewController];
            
            // if you keep this approach, switch keys to constants, and explicitly alloc/init/release
            NSDictionary *annotationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [selectedPoint title],@"title",
                                            [selectedPoint subtitle],@"subtitle",
                                            [[selectedPoint latitude] stringValue],@"latitude",
                                            [[selectedPoint longitude] stringValue],@"longitude",
                                            nil];
            
            pointDetailVC.pointDictionary = annotationDict;
            
            pointDetailVC.theDocID = [selectedPoint pointID];
            
            pointDetailVC.fetchDetailsOnView = NO; // might just be glancing at popover
            
            // delete after testing
            //pointDetailVC.databaseURL = [[self.couchSourceList objectAtIndex:[self currentCouchSourceIndex]] 
            //                             objectForKey:kCouchSourceDatabaseURLKey];
            
            pointDetailVC.currentDatabaseDefinition = self.currentDatabaseDefinition;
            
            // needs to be offest -- try x-10 and y+10 for starters
            
            [self.mapCalloutPVC presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }
        
        
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    // dismiss popover here?
    NSLog(@"Annotation deselected: %@", [view.annotation title]);
    
}


// This code assumes a callout, but it looks weird, to have a popover coming from a callout

/*

// overrides super, and don't need to call it
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
    if (self.mapCalloutPVC.isPopoverVisible) {
        [self.mapCalloutPVC dismissPopoverAnimated:YES];
    }
    else {
        
        GeoCouchAnnotation *selectedPoint = view.annotation;
        NSLog(@"The ID of the selected point is: %@", [selectedPoint pointID]);
        
        // class-check to guard against random error where pointID is returning a random chunk of memory
        if ([[selectedPoint pointID] isKindOfClass:[NSString class]]) {
            
            if (!self.mapCalloutPVC) {
                
                // set it up here
                
                PointDetailTableViewController *pointVC = [[PointDetailTableViewController alloc] initWithNibName:@"PointDetailTableViewController" bundle:nil];
                
                pointVC.theDocID = [selectedPoint pointID];
                
                CGSize mapPopoverSize = CGSizeMake(320.0, 350.0);
                
                pointVC.contentSizeForViewInPopover = mapPopoverSize;
                
                UIPopoverController *pointPopover = [[UIPopoverController alloc] initWithContentViewController:pointVC];
                
                self.mapCalloutPVC = pointPopover;
                
                [pointVC release];
                
                [pointPopover release];
                
            }
            
            // view presents it from the pin, which looks weird if you are using callouts
            
            [self.mapCalloutPVC presentPopoverFromRect:control.bounds inView:control permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }
        
    }
    
}

*/


@end
