//
//  BMSearchSuggestionControllerViewController.h
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/11/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMSearchSuggestionControllerViewController;

@protocol SearchSuggestDelegate
// Sent when the user selects a row in the recent searches list.
- (void)searchSuggestController:(BMSearchSuggestionControllerViewController *)controller didSelectName:(NSString *)name displayName: (NSString*) displayName  lat:(double) lat lng:(double) lng;
@end

@interface BMSearchSuggestionControllerViewController : UITableViewController <UIActionSheetDelegate>
@property (nonatomic, weak) id <SearchSuggestDelegate> delegate;

- (void)filterResultsUsingString:(NSString *)filterString;


@end
