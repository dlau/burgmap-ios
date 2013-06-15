//
//  RootViewController.h
//  MGSplitView
//
//  Created by Matt Gemmell on 26/07/2010.
//  Copyright Instinctive Code 2010.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
    UILabel *lblCommuneName;
}


@property (nonatomic, strong) IBOutlet UILabel *lblCommuneName;
- (void) setFromDictionary:(NSDictionary *) dictFromPoint;

@end
