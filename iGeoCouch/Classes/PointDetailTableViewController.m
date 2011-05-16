//
//  PointDetailTableViewController.m
//  gcBrowser
//
//  Created by Matt Blair on 5/10/11.
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



#import "PointDetailTableViewController.h"
#import "gcBrowserConstants.h"
#import "Reachability.h"
#import "NSString+SBJSON.h"

@implementation PointDetailTableViewController

@synthesize currentDatabaseDefinition, theDocID, lastRevID, pointDictionary, sortedRowNames;
@synthesize fetchDetailsOnViewWillAppear, theDocumentRequest, fetchView, fetchButton;

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
    
    [currentDatabaseDefinition release]; 
    
    [theDocID release];
    [lastRevID release];

    // also add to mem warning?
    [pointDictionary release]; 
    [sortedRowNames release];
    
    [fetchView release];
    [fetchButton release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    self.fetchView = nil;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    
    // set the default order of the rows
    self.sortedRowNames = [NSArray arrayWithObjects:@"title",@"subtitle", @"latitude", @"longitude", nil];
    
    // start the process of fetching the rest of the doc, if needed
    if (fetchDetailsOnViewWillAppear) {
        
        [self fetchFullDocument];
        
    }
    else {  // set up fetch UI -- subclass for iPhone to use nav bar or toolbar?
        
        if (!self.fetchView) {
            
            CGRect fetchFrame = CGRectMake(0.0, 0.0, 320.0, 64.0);
            
            self.fetchView = [[UIView alloc] initWithFrame:fetchFrame];
            
            self.fetchView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
            
            //should be localized
            NSString *fetchText = [[NSString alloc] initWithString:@"Tap to Fetch Details..."];
            
            self.fetchView.accessibilityHint = @"Will download more details about this location.";
            
            self.fetchView.accessibilityLabel = fetchText;
            
            CGRect labelFrame = CGRectMake(40.0, 10.0, 240.0, 44.0);
            
            UILabel *fetchLabel = [[UILabel alloc] initWithFrame:labelFrame];
            
            fetchLabel.textColor = [UIColor whiteColor];
            
            fetchLabel.backgroundColor = [UIColor clearColor];
            
            fetchLabel.font = [UIFont systemFontOfSize:17.0];
            
            fetchLabel.textAlignment = UITextAlignmentCenter;
            
            fetchLabel.text = fetchText;
            
            [self.fetchView addSubview:fetchLabel];
            
            [fetchText release];
            [fetchLabel release];
            
            UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchFullDocument)];
            [self.fetchView addGestureRecognizer:recognizer];

            [recognizer release];
            
        }
        
        self.fetchView.frame = CGRectMake(0.0, 0.0, 320.0, 64.0);        
        self.tableView.tableHeaderView = self.fetchView;
        
    }
    
    // load currently available values
    [self.tableView reloadData];
    
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
    // pointDictionary should have same count, but sortedRowNames is safer b/c it's used to generate cells
    //return [self.pointDictionary count];
    return [self.sortedRowNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    NSString *keyName = [self.sortedRowNames objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [keyName capitalizedString];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    
    // get rid of description once the parsing code is returning strings reliably
    cell.detailTextLabel.text = [[self.pointDictionary objectForKey:keyName] description]; 
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
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
       
    // Update UI
    
    // one-shot -- they don't get to try again unless they come back to this view
    
    [UIView animateWithDuration:0.4 
                     animations:^ (void) {
                         
                         self.fetchView.frame = CGRectMake(0.0, 0.0, 320.0, 0.0);
                         
                     } completion:^(BOOL finished) {
                         
                         self.tableView.tableHeaderView = nil; // w/o nil here, it leaves empty space
                         
                     }];
    

    // Check Reachability first
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    
    if (status == kReachableViaWiFi || status == kReachableViaWWAN) { 
        
        
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", 
                               self.currentDatabaseDefinition.databaseURL, self.theDocID];
        
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
        
    }

    
    
}

- (void)documentRequestFinished:(ASIHTTPRequest *)request {

    
    NSLog(@"Document Request HTTP Status code was: %d", [request responseStatusCode]);
	NSLog(@"Document Request response was: %@", [request responseString]);
    
    if ([request responseStatusCode] == 200) {
        
        NSString *responseString = [request responseString];
        
        if ([[responseString JSONValue] isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *documentDict = [responseString JSONValue];
 
            // Quick and dirty way to show them all:
            //self.pointDictionary = documentDict;
            //self.sortedRowNames = [documentDict allKeys];
            
            
            // parsing the dictionary -- what really needs to happen:
            
            // All valid document requests return an id, else the document wasn't found.
            if ([documentDict objectForKey:@"_id"]) {
                
                // set aside _id and _rev
                self.theDocID = [documentDict objectForKey:@"_id"];
                
                self.lastRevID = [documentDict objectForKey:@"_rev"];
                
                // put strings for the rest of keys into a dictionary to display
                NSMutableDictionary *theFullDocument = [[NSMutableDictionary alloc] initWithCapacity:10];
                
                // get array of keys to display
                NSArray *documentDisplayKeys = nil;
                
                if (self.currentDatabaseDefinition.keysToDisplay) {
                    documentDisplayKeys = [[NSArray alloc] initWithArray:self.currentDatabaseDefinition.keysToDisplay];
                }
                else {
                    
                    // no defined list, so just read all keys, ditch id and rev, etc.
                    // remove _attachment until you add special handling for it?
                    
                    NSMutableArray *keyList = [[NSMutableArray alloc] initWithArray:[documentDict allKeys]];
                    
                    // alloc/init array to remove, too?
                    [keyList removeObjectsInArray:[NSArray arrayWithObjects:@"_id", @"_rev", nil]];
                    
                    documentDisplayKeys = [[NSArray alloc] initWithArray:keyList];
                     
                    [keyList release];
                    
                }
                
                // for verification:
                NSLog(@"This will process keys for: %@", documentDisplayKeys);
                
                // create another array to hold new keys unpacked from geometry, properties, etc.
                // capacity = display keys - geometry + latitude + longitude? best guess?
                NSMutableArray *newDisplayKeys = [[NSMutableArray alloc] initWithCapacity:[documentDisplayKeys count] + 1]; 
                
                // Make a list of special cases of nested keys like geometry, properties, 
                // _attachements, etc. and put them in an enum so that you can 
                // use switch to avoid if-elseif ad nauseum...
                for (NSString *theKey in documentDisplayKeys) {
                    
                    if ([theKey isEqualToString:@"geometry"]) {

                        // Don't need to validate type, because if it wasn't valid, 
                        // it wouldn't be in a geoquery result. True? Too risky?
                        
                        NSArray *coordinateArray = 
                            [[documentDict objectForKey:theKey] objectForKey:@"coordinates"];
                        
                        [theFullDocument setObject:[[coordinateArray objectAtIndex:1] stringValue] 
                                            forKey:@"latitude"];
                        [newDisplayKeys addObject:@"latitude"];
                        
                        [theFullDocument setObject:[[coordinateArray objectAtIndex:0] stringValue] 
                                            forKey:@"longitude"];
                        [newDisplayKeys addObject:@"longitude"];
                        
                    }
                    else if ([theKey isEqualToString:@"properties"] && 
                             [[documentDict objectForKey:theKey] isKindOfClass:[NSDictionary class]]) {
                        
                        // iterate properties dict -- no way to order or specify these at the moment
                        // if you keep this structure, alloc/init/release explicitly
                        
                        NSDictionary *propertiesDict = [documentDict objectForKey:theKey];
                        
                        NSArray *propKeys = [propertiesDict allKeys];
                        
                        // dumb string conversion
                        for (NSString *thePropKey in propKeys) {
                            [theFullDocument setObject:[[propertiesDict objectForKey:thePropKey] description]
                                                forKey:thePropKey];
                            [newDisplayKeys addObject:thePropKey];
                        }
                        
                        
                    }
                    
                    else {
                        
                        // enumerate for type-specific formatting in the future
                        // needs to handle numbers, objects, arrays, etc.
                        // this version just does dumb conversion to NSString for now
                        [theFullDocument setObject:[[documentDict objectForKey:theKey] description]
                                            forKey:theKey];
                        [newDisplayKeys addObject:theKey];
                        
                    }
                    
                    
                }
                
                // reset value of pointDictionary and sortedRowNames
                
                self.pointDictionary = theFullDocument;
                self.sortedRowNames = newDisplayKeys;
                
                [theFullDocument release];
                [documentDisplayKeys release];
                [newDisplayKeys release];
                
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
            
            NSLog(@"Unexpected result: Retrieved document was not a dictionary.");
            
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
    
    if ([self.theDocumentRequest inProgress]) {
        
        [self.theDocumentRequest cancel];
        
        // update UI in case this is called by Reachability failure.
        
        
        self.theDocumentRequest = nil; // does documentRequestFailed handle this?
        
    }

}

@end
