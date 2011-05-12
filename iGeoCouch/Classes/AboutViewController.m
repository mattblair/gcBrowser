//
//  AboutViewController.m
//  gcBrowser
//
//  Created by Matt Blair on 5/12/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController
@synthesize closeButton;
@synthesize aboutTextView, titleLabel, versionLabel;
@synthesize delegate;

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
    [aboutTextView release];
    [titleLabel release];
    [versionLabel release];
    
    [delegate release];
    
    [closeButton release];
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
    
    self.aboutTextView.text = @"Details pending. For now, see the read me file on github at: https://github/mattblair/gcbrowser";
    
    
}

- (void)viewDidUnload
{
    [self setAboutTextView:nil];
    [self setTitleLabel:nil];
    [self setVersionLabel:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


- (IBAction)closeAboutView:(id)sender {
    
    [self.delegate aboutViewControllerDidFinish:self];
    
}

@end
