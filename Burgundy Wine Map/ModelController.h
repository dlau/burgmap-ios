//
//  ModelController.h
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 6/6/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end
