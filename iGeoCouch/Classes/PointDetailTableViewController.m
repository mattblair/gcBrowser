//
//  PointDetailTableViewController.m
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "PointDetailTableViewController.h"
#import "gcBrowserConstants.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@implementation PointDetailTableViewController

@synthesize databaseURL, theDocID, lastRevID, pointDictionary, sortedRowNames;
@synthesize fetchDetailsOnView, theDocumentRequest;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    
    [databaseURL release]; // might be replaced if database def is used instead
    [sortedRowNames release];
    
    [theDocID release];
    [lastRevID release];

    // also add to mem warning?
    [pointDictionary release]; 
    
    
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // set the default order of the rows -- use constants if you keep this method
    self.sortedRowNames = [NSArray arrayWithObjects:@"title",@"subtitle", @"latitude", @"longitude", nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // load currently available values
    [self.tableView reloadData];
    
    // start the process of fetching the rest of the doc, if needed

    if (fetchDetailsOnView) {
        
        [self fetchFullDocument];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self killRequest];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pointDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    NSString *keyName = [self.sortedRowNames objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [keyName capitalizedString];
    
    // check for NSString?
    cell.detailTextLabel.text = [[self.pointDictionary objectForKey:keyName] description]; 
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // place holder if you push a detail view here...
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Requesting Data from Couch

- (void)fetchFullDocument {
    
    // Check Reachability first
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    
    if (status == kReachableViaWiFi || status == kReachableViaWWAN) { 
        
        
        // NSLog(@"TDVC: Internet Reachable. Preparing request for details...");
        
        // Update UI
        
        //fetchingLabel.text = @"Fetching Images...";
        
        //[fetchingSpinner startAnimating];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.databaseURL, self.theDocID];
        
        NSLog(@"Generated Photo Request URL is: %@", urlString);
        
        NSURL *theURL = [NSURL URLWithString:urlString];
        
        self.theDocumentRequest = [ASIHTTPRequest requestWithURL:theURL];
        
        [self.theDocumentRequest setDelegate:self];
        
        [self.theDocumentRequest setDidFinishSelector:@selector(documentRequestFinished:)];
        
        [self.theDocumentRequest setDidFailSelector:@selector(documentRequestFailed:)];
                
        [self.theDocumentRequest startAsynchronous];
        
    }
    else {
        // no connection
        NSLog(@"Detail Request won't be made: no connection.");
        
        // Update UI
        //fetchingLabel.text = @"Images not available. (Offline)";
        //[fetchingSpinner stopAnimating];
    }

    
    
}

- (void)documentRequestFinished:(ASIHTTPRequest *)request {

    
    NSLog(@"Document Request HTTP Status code was: %d", [request responseStatusCode]);
	NSLog(@"Document Request response was: %@", [request responseString]);
    
    if ([request responseStatusCode] == 200) {
        
        NSString *responseString = [request responseString];
        
        if ([[responseString JSONValue] isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *documentDict = [responseString JSONValue];
 
            // quick and dirty way to show them all:
            //self.pointDictionary = documentDict;
            //self.sortedRowNames = [documentDict allKeys];
            
            
            // parsing the dictionary -- what really needs to happen:
            
            // All valid document requests return an id, else it wasn't found.
            if ([documentDict objectForKey:@"_id"]) {
                
                // set aside _id and _rev
                self.theDocID = [documentDict objectForKey:@"_id"];
                
                self.lastRevID = [documentDict objectForKey:@"_rev"];
                
                // put strings for the rest of keys into a dictionary to display
                
                NSMutableDictionary *theFullDocument = [[NSMutableDictionary alloc] initWithCapacity:10];
                NSArray *receivedDocumentKeys = [documentDict allKeys];
                
                for (NSString *theKey in receivedDocumentKeys) {
                    
                    if (!([theKey isEqualToString:@"_id"] || [theKey isEqualToString:@"_rev"])) {
                        // add to theFullDocument
                        
                        // handle strings, numbers, dictionaries, arrays, etc.
                    }
                    
                    
                }
                
                // reset value of pointDictionary and sortedRowNames
                
                self.pointDictionary = theFullDocument;
                self.sortedRowNames = [documentDict allKeys]; // or read from database def, if defined there
                
                [theFullDocument release];

                
            }
            else { // A Couch '404' looks like: {"error":"not_found","reason":"missing"}
                
                self.pointDictionary = documentDict; 
                self.sortedRowNames = [NSArray arrayWithObjects:@"error", @"reason", nil];
                            
            }
         
            
            // reload table
            
            [self.tableView reloadData];
        }
        
        else {
            
            // update UI to say document fetch was not successful
            
            NSLog(@"Unexpected result: retrieved document was not a dictionary.");
            
        }
    }
    
    // Update fetch-related UI
    
    self.theDocumentRequest = nil;
    
}
    
- (void)documentRequestFailed:(ASIHTTPRequest *)request {

    NSLog(@"Document Request failed with HTTP status code : %d", [request responseStatusCode]);
	NSLog(@"Document Request failed with response: %@", [request responseString]);
    
    // update UI to indicate failure
    
    self.theDocumentRequest = nil;
    
}

- (void)killRequest {
    
    //
    
    if ([self.theDocumentRequest inProgress]) {
        
        [self.theDocumentRequest cancel];
        
        // update UI in case this is called by Reachability failure.
        
        
        self.theDocumentRequest = nil; // does documentRequestFailed handle this?
        
    }

}

@end
