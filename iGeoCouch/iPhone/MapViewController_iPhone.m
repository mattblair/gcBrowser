//
//  MapViewController_iPhone.m
//  iGeoCouch
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "MapViewController_iPhone.h"


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
       
    // adding toolbar items programmatically because IB wiring is strange for this situation.
    
    [self addToolbarItems];
    
    // add in upper right for now
    
    UIBarButtonItem *addNewButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewPointEditor:)];
    self.navigationItem.rightBarButtonItem = addNewButton;
    [addNewButton release];
    
    // put the couchListButton in the upper left
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showCouchList:)];
    
    self.navigationItem.leftBarButtonItem = listButton;
    
    [listButton release];
    
    // add the infoButton here, too?
    
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
	
	// I use ivars for refresh and location, so I can easily manage them throughout this VC
	
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
						 self.refreshButton, // used self. in public art app, as did location...
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
    
    // show the list modally
    
    CouchListViewController *couchListVC = [[CouchListViewController alloc] initWithNibName:@"CouchListViewController" bundle:nil];
    
    // pass the array loaded from the plist in super to be the datasource
    couchListVC.couchSourceList = self.couchSourceList;
    
    couchListVC.title = @"Data Sources";
    
    couchListVC.delegate = self;
    
    couchListVC.currentCouchSource = self.currentCouchSource;
    
    [self presentModalViewController:couchListVC animated:YES];

}
    


- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex {
    
    [super couchListViewController:couchListViewController didSelectDatasource:didSelect atIndex:datasourceIndex];    
    
    // do any custom iPhone reaction to change of datasource here
    
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
