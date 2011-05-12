//
//  CouchListViewController.m
//  gcBrowser
//
//  Created by Matt Blair on 5/3/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "CouchListViewController.h"
#import "gcBrowserConstants.h"


@implementation CouchListViewController

@synthesize couchSourceList;
@synthesize currentCouchSourceIndex;
@synthesize delegate;

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
    [couchSourceList release];
    
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.couchSourceList = nil; // here, or better to do it in memory warning?
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData]; // to pick up changes made elsewhere, i.e. by changing lists in settings
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;  // use collections for sections?
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.couchSourceList count]; // update if you use sections
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle     reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    // if you make this an editable table, probably best to move the configuration into something like:
    // - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
    
    cell.textLabel.text = [[self.couchSourceList objectAtIndex:indexPath.row] objectForKey:kCouchSourceNameKey]; 
    
    cell.detailTextLabel.text = [[self.couchSourceList objectAtIndex:indexPath.row] objectForKey:kCouchSourceCollectionKey];
    
    // indicate current selection
    
    if ([self currentCouchSourceIndex] == indexPath.row) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    else {

        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // place holder if you push a detail view here...
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    
    NSLog(@"Selected row %d in the Couch Source List", indexPath.row);
    
    // an example of reloading only changed rows -- but seems like overkill for a short list:
    // http://my.safaribooksonline.com/book/programming/iphone/9781430230212/popovers/128
    
    NSUInteger previousSelected = self.currentCouchSourceIndex;
    
    if (indexPath.row != previousSelected) {
        
        // update the selection in table and reload 
        
        self.currentCouchSourceIndex = indexPath.row; 
        
        [self.tableView reloadData]; // will this even be seen? or just do it in viewWillAppear?
        
        // pass the value back to MapVC, where it sets its currentCouchSourceIndex property and fetches map points
        
        [self.delegate couchListViewController:self didSelectDatasource:YES atIndex:indexPath.row];
        
    }
    else {
        
        [self.delegate couchListViewController:self didSelectDatasource:NO atIndex:indexPath.row];
        
    }
    
    
}

@end
