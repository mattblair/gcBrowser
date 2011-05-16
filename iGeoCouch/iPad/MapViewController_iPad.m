//
//  MapViewController_iPad.m
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
        
    }

    else {

        if (!self.couchListPVC) {
            
            //NSLog(@"couchListPVC does not exist. Creating it...");
            
            CouchListViewController *couchListVC = [[CouchListViewController alloc] initWithNibName:@"CouchListViewController" bundle:nil];
            
            couchListVC.title = @"GeoCouch Data Sources";
            
            couchListVC.delegate = self;
            
            CGSize couchPopoverSize = CGSizeMake(320.0, 550.0);
            
            couchListVC.contentSizeForViewInPopover = couchPopoverSize;
            
            UIPopoverController *couchPopover = [[UIPopoverController alloc] initWithContentViewController:couchListVC];
            
            [couchListVC release];
            
            self.couchListPVC = couchPopover;
            
            [couchPopover release];
        }
        
        
        // update list and index in case these have been changed elsewhere
        CouchListViewController *listVC = (CouchListViewController *)self.couchListPVC.contentViewController;
        
        // pass the array loaded from the plist in super to be the datasource
        listVC.couchSourceList = self.couchSourceList;
        
        listVC.currentCouchSourceIndex = self.currentCouchSourceIndex;
        
        [self.couchListPVC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    
    
}

- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex {
    
    [super couchListViewController:couchListViewController didSelectDatasource:didSelect atIndex:datasourceIndex];
    
    // do any iPad specific configuration to new datasource here
    
    [self.couchListPVC dismissPopoverAnimated:YES];
    
}


- (IBAction)showAboutPage:(id)sender {
       
    AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    
    aboutVC.delegate = self;
    
    aboutVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:aboutVC animated:YES];
    
    [aboutVC release];
    
}


// this is in the subclass in case you want to handle it differently from the iPhone handling
- (void)aboutViewControllerDidFinish:(AboutViewController *)aboutViewController {
    
    [self dismissModalViewControllerAnimated:YES];
    
}


#pragma mark - MapView Delegate


// overriding here to omit callout and right accessory
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{

    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView
														  dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
	
	if (!pinView)
	{
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
												   reuseIdentifier:@"CustomPinAnnotationView"] 
				   autorelease];
		pinView.pinColor = MKPinAnnotationColorRed;
		pinView.animatesDrop = YES;

	}
	
	return pinView;
	
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    //NSLog(@"Annotation selected: %@", [view.annotation title]);
    
    if (self.mapCalloutPVC.isPopoverVisible) {
        [self.mapCalloutPVC dismissPopoverAnimated:YES];
        
        // need to deselct the view so this works as a toggle without tap another annotation first
        
        // not working -- it's not getting deselected until another one is tapped
        // see note in docs -- you're supposed to use map view to handle this.
        // [view setSelected:NO animated:YES]; 
        // even using that, there seems to be a delay...
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
                
                CGSize mapPopoverSize = CGSizeMake(320.0, 360.0);
                
                pointVC.contentSizeForViewInPopover = mapPopoverSize;
                
                UIPopoverController *pointPopover = [[UIPopoverController alloc] initWithContentViewController:pointVC];
                
                self.mapCalloutPVC = pointPopover;
                
                [pointVC release];
                
                [pointPopover release];
                
            }
            
            // pass the point's information
            
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
            
            pointDetailVC.fetchDetailsOnViewWillAppear = NO; // might just be glancing at popover
                        
            pointDetailVC.currentDatabaseDefinition = self.currentDatabaseDefinition;
            
            // MKAnnotationPin is 32 x 39, and we want to present from pinhead in top half
            // Also, pin shaft and head are not centered because of the shadow
            // It probably makes sense to use fixed values here rather than calculate
            
            CGRect pinRect = CGRectMake((view.frame.size.width / 2.0) - 12.0, (view.frame.size.height / 4.0) -7.0, 8.0, 12.0);
            
            [self.mapCalloutPVC presentPopoverFromRect:pinRect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }
        
        
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    // dismiss popover here, too?
    NSLog(@"Annotation deselected: %@", [view.annotation title]);
    
}


// This code assumes a callout is shown, but it looks weird to have a popover coming from a callout

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
