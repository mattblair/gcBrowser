//
//  MapViewController_iPhone.m
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



#import "MapViewController_iPhone.h"
#import "GeoCouchAnnotation.h"
#import "PointDetailTableViewController.h"
#import "gcBrowserConstants.h"

@implementation MapViewController_iPhone

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
       
    // adding toolbar items programmatically because IB wiring is strange for this situation
    
    [self addToolbarItems];
    
    // add in upper right for now
    
    UIBarButtonItem *addNewButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewPointEditor:)];
    self.navigationItem.rightBarButtonItem = addNewButton;
    [addNewButton release];
    
    // put the couchListButton in the upper left
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showCouchList:)];
    
    self.navigationItem.leftBarButtonItem = listButton;
    
    [listButton release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)addToolbarItems {
	
	// Using ivars so I can easily manage them throughout this VC
	
	// Refresh (system)
	
	self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                       target:self
                                                                       action:@selector(refreshPointsOnMap)]; 
    
	self.locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"74-location"] 
                                                           style:UIBarButtonItemStylePlain 
                                                          target:self 
                                                          action:@selector(goToLocation)];
	
    
    self.settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear"] 
                                                                               style:UIBarButtonItemStylePlain 
                                                                              target:self 
                                                                              action:@selector(showSettings:)];	
	
	
	// re-usable flex space (system)
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:nil];
	
	
	// this method is shown in the docs, but it bunches them all together at the left, so I added spaces
    
	self.toolbarItems = [NSArray arrayWithObjects: 
						 self.refreshButton,
						 flexibleSpace,
						 self.settingsButton,
						 flexibleSpace,
						 self.locationButton,
						 nil];
    
	[flexibleSpace release];
    
}

#pragma mark - Overrides of Button Taps

- (IBAction)showCouchList:(id)sender {

    [super showCouchList:sender];    
    
    CouchListViewController *couchListVC = [[CouchListViewController alloc] initWithNibName:@"CouchListViewController" bundle:nil];
    
    couchListVC.couchSourceList = self.couchSourceList;
    
    couchListVC.title = @"Data Sources";
    
    couchListVC.delegate = self;
    
    couchListVC.currentCouchSourceIndex = self.currentCouchSourceIndex;
    
    [self presentModalViewController:couchListVC animated:YES];

}
    


- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex {
    
    [super couchListViewController:couchListViewController didSelectDatasource:didSelect atIndex:datasourceIndex];    
    
    // do any custom iPhone reaction to change of datasource here
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (IBAction)showAboutPage:(id)sender {
    
    // show the list modally
    
    AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    
    aboutVC.delegate = self;
    
    [self presentModalViewController:aboutVC animated:YES];
    
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)aboutViewController {
    
    [self dismissModalViewControllerAnimated:YES];
    
}


#pragma mark - MapView Delegate

// overrides super
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
	// don't need to call super
	
	// see PDXTrees for an example of using annotation to request full object from Core Data
	// then setting that object for display in a view Controller. 
	
	// get access to the original annotation
	
	GeoCouchAnnotation *selectedPoint = view.annotation;
	//NSLog(@"The ID of the selected point is: %@", [selectedPoint pointID]);
	
    
    // Class-check to guard against random error where pointID is returning a random chunk of memory
    // Only seen twice. See ticket 32 for details.
    if ([[selectedPoint pointID] isKindOfClass:[NSString class]]) {
        PointDetailTableViewController *pointVC = [[PointDetailTableViewController alloc] initWithNibName:@"PointDetailTableViewController" bundle:nil];
        
        pointVC.theDocID = [selectedPoint pointID];
                
        pointVC.currentDatabaseDefinition = self.currentDatabaseDefinition;
        
        // if you keep this approach, switch keys to constants, and explicitly alloc/init/release
        NSDictionary *annotationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [selectedPoint title],@"title",
                                        [selectedPoint subtitle],@"subtitle",
                                        [[selectedPoint latitude] stringValue],@"latitude",
                                        [[selectedPoint longitude] stringValue],@"longitude",
                                        nil];
        
        pointVC.pointDictionary = annotationDict;
        
        pointVC.fetchDetailsOnViewWillAppear = YES;  // FUTURE: NO if include_docs was used in geoquery
        
        [self.navigationController pushViewController:pointVC animated:YES];
        
        [pointVC release];
    }
	
}


@end
