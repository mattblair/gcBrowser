//
//  CouchListViewController.h
//  iGeoCouch
//
//  Created by Matt Blair on 5/3/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CouchListDelegate;

@interface CouchListViewController : UITableViewController {
    
    NSArray *couchSourceList;
    id <CouchListDelegate> delegate;
    NSUInteger currentCouchSource;
    
}

@property (nonatomic, retain) NSArray *couchSourceList;

@property (nonatomic, assign) id <CouchListDelegate> delegate;

@property (nonatomic) NSUInteger currentCouchSource;

@end

@protocol CouchListDelegate <NSObject>
// datasource is -1 on cancel
- (void)couchListViewController:(CouchListViewController *)couchListViewController didSelectDatasource:(BOOL)didSelect atIndex:(NSUInteger)datasourceIndex;

@end