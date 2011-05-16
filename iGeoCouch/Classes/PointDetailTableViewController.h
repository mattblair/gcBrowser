//
//  PointDetailTableViewController.h
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



#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "GeoCouchDatabaseDefinition.h"

/*
NOTE: I called this one PointDetailTableViewController because
it is a subclass of UITableViewController. This allows use of the
name PointDetailViewController for a UIViewController subclass, if
it makes sense to go that route in the future.
 
*/
 
@interface PointDetailTableViewController : UITableViewController {
    
    
    GeoCouchDatabaseDefinition *currentDatabaseDefinition;
    
    NSString *theDocID; // stored separately b/c not presented in UI
    NSString *lastRevID; // stored separately b/c not presented in UI
    NSDictionary *pointDictionary;
    NSArray *sortedRowNames;
    
    // Defaults to use: 
    // YES on the iPhone, because they've already seen a callout, 
    //    and this is shown as a full screen transition
    // NO on the iPad, because this is shown in a popover, and the 
    //    user may only want a peek
    // Exception: if the database def is set to include documents in 
    //    the geoquery, don't fetch again
    BOOL fetchDetailsOnViewWillAppear; 
    
    ASIHTTPRequest *theDocumentRequest;
    
    UIView *fetchView;
    UIButton *fetchButton;  // ditch
}

@property (nonatomic, retain) GeoCouchDatabaseDefinition *currentDatabaseDefinition;

@property (nonatomic, retain) NSString *theDocID;
@property (nonatomic, retain) NSString *lastRevID;
@property (nonatomic, retain) NSDictionary *pointDictionary;
@property (nonatomic, retain) NSArray *sortedRowNames;

@property (nonatomic) BOOL fetchDetailsOnViewWillAppear;
@property (nonatomic, retain) ASIHTTPRequest *theDocumentRequest;

@property (nonatomic, retain) UIView *fetchView;
@property (nonatomic, retain) UIButton *fetchButton;

- (void)fetchFullDocument;
- (void)killRequest;



@end
