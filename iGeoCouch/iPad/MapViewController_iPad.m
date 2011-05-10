//
//  MapViewController_iPad.m
//  gcBrowser
//
//  Created by Matt Blair on 5/2/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "MapViewController_iPad.h"
#import "CouchListViewController.h"


@implementation MapViewController_iPad

@synthesize couchListPVC;


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
            
            couchListVC.currentCouchSource = self.currentCouchSource;
            
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


@end
