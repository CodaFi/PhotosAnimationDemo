//
//  CFIViewController.m
//  PhotosAnimationDemo
//
//  Created by Robert Widmann on 8/10/12.
//  Copyright (c) 2012 CodaFi Inc. All rights reserved.
//

#import "CFIViewController.h"
#import "NSData+Base64.h"

@interface CFIViewController ()

@end

@implementation CFIViewController
@synthesize imageView = imageView_;
@synthesize animatedImageView = animatedImageView_;
@synthesize sheetView = sheetView_;

- (void)viewDidLoad
{
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    //load the imageview, set its mode to aspect fill!!!
    imageView_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SamplePhoto.jpg"]];
    [imageView_ setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44.0f)];
    [imageView_ setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview: imageView_];
    
    //load the toolbar, setup throwaway toolbar button item instance in array literal
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-88.0f, self.view.bounds.size.width, 44.0f)];
    [toolbar setItems:@[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(animatePhotoToMail)]]];
    [self.view addSubview: toolbar];
    
    //create a second image view (i.e. cheat)
    animatedImageView_ = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])+CGRectGetHeight(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height- CGRectGetHeight(self.navigationController.navigationBar.frame))];
    [animatedImageView_ setContentMode:UIViewContentModeScaleAspectFit];
    
    //cheat harder
    sheetView_ = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, self.view.bounds.size.width, 300)];
    [sheetView_ setBackgroundColor:[UIColor whiteColor]];
    
}

-(void)animatePhotoToMail {
    [animatedImageView_ setImage:imageView_.image];
    [imageView_ setAlpha:0.0f];
    
    //add sheetview first, which is offscreen
    [self.view.window addSubview:sheetView_];
    //add animating image view next
    [self.view.window addSubview: animatedImageView_];
    
    [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //close enough for now.  Will tweak later
        [animatedImageView_ setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.5, 0.5), CGAffineTransformMakeTranslation(0, -88))];
        
    }completion:^(BOOL finished){
        if([MFMailComposeViewController canSendMail])
        {
            
            NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
            //Get the image
            UIImage *emailImage = animatedImageView_.image;
            //Convert the image into data
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(emailImage, 0.7)];
            //Create a base64 string representation of the data using NSData+Base64
            NSString *base64String = [imageData base64EncodedString];
            //Add the encoded string to the emailBody string
            [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='data:image/png;base64,%@' width=\"100%%\" height=\"100%%\"></b></p>",base64String]];
            //close the HTML formatting
            [emailBody appendString:@"</body></html>"];

            //Create the mail composer window
            MFMailComposeViewController *emailDialog = [[MFMailComposeViewController alloc] init];
            emailDialog.mailComposeDelegate = self;
            [emailDialog setMessageBody:emailBody isHTML:YES];
            //hard coded guess.  Should calculate actual delay in a subclass, but too lazy.
            [UIView animateWithDuration:0.5 delay:0.35 options:UIViewAnimationOptionCurveEaseOut  animations:^{
                //sheet view animates in with the view controller to disguise the HTML image and the siggy.  See, cheating.
                [sheetView_ setFrame:CGRectMake(0, 200, self.view.bounds.size.width, 260)];
            }
             completion:NULL
            ];
            [self.navigationController presentViewController:emailDialog animated:YES completion:^{
                [UIView animateWithDuration:0.75 delay:0.35 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    //hard coded guess.  Should calculate actual image frames, but laziness should suffice for now.
                    [animatedImageView_ setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.938, 0.938), CGAffineTransformMakeTranslation(0, 52))];
                }completion:^(BOOL finished){
                    //cleanup.
                    [animatedImageView_ removeFromSuperview];
                    [sheetView_ removeFromSuperview];
                    [animatedImageView_ setTransform:CGAffineTransformIdentity];
                    [animatedImageView_ setFrame: CGRectMake(0, CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])+CGRectGetHeight(self.navigationController.navigationBar.frame), self.view.bounds.size.width, self.view.bounds.size.height)];
                    NSLog(@"%@ %@", NSStringFromCGRect(imageView_.frame), NSStringFromCGRect(animatedImageView_.frame));
                    [sheetView_ setFrame:CGRectMake(0, self.view.bounds.size.height+66, self.view.bounds.size.width, 300)];
                    [imageView_ setAlpha:1.0f];
                    
                }];
            }];
        }
    }];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_5_0
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //do absolutely nothing
    }];
#else 
    [self dismissModalViewControllerAnimated:YES];
#endif
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

@end
