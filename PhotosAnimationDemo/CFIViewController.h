//
//  CFIViewController.h
//  PhotosAnimationDemo
//
//  Created by Robert Widmann on 8/10/12.
//  Copyright (c) 2012 CodaFi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CFIViewController : UIViewController <MFMailComposeViewControllerDelegate>{
    
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *animatedImageView;
@property (nonatomic, strong) UIView *sheetView;

@end
