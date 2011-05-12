//
//  AboutViewController.h
//  gcBrowser
//
//  Created by Matt Blair on 5/12/11.
//  Copyright 2011 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AboutViewControllerDelegate;

@interface AboutViewController : UIViewController {
    
    id <AboutViewControllerDelegate> delegate;
    
    UITextView *aboutTextView;
    UILabel *titleLabel;
    UILabel *versionLabel;
    UIButton *closeButton;
}

@property (nonatomic, assign) id <AboutViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextView *aboutTextView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (IBAction)closeAboutView:(id)sender;

@end

@protocol AboutViewControllerDelegate <NSObject>
- (void)aboutViewControllerDidFinish:(AboutViewController *)aboutViewController;
@end