//
//  BMSearchSuggestionControllerViewController.m
//  Burgundy Wine Map
//
//  Created by Daryl Lau on 9/11/13.
//  Copyright (c) 2013 Daryl Lau. All rights reserved.
//

#import "BMSearchSuggestionControllerViewController.h"
#import "BMMapManager.h"

@interface BMSearchSuggestionControllerViewController ()

@end

@implementation BMSearchSuggestionControllerViewController

NSArray *m_SearchResults;


#pragma mark - Search results controller delegate method

- (void)recentSearchesController:(BMSearchSuggestionControllerViewController *)controller didSelectResult:(NSString *)searchString {
    
    /*
     The user selected a row in the recent searches list (UITableView).
     Set the text in the search bar to the search string, and conduct the search.
     */
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_SearchResults = [[NSArray alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)filterResultsUsingString:(NSString *)filterString {
    if ([filterString length] > 0) {
        [[BMMapManager getInstance] getSearchResultsForText:filterString
             callback:^(NSArray* results){
                 m_SearchResults = results;
                 [self.tableView reloadData];
         }
         ];
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_SearchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *searchResult = [m_SearchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [searchResult objectForKey:@"displayName"];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *rowDict = [m_SearchResults objectAtIndex:indexPath.row];
    NSString *name = [rowDict objectForKey:@"regionName"];
    NSString *displayName = [rowDict objectForKey:@"displayName"];
    double lat = [(NSNumber*)[rowDict objectForKey:@"lat"] doubleValue];
    double lng = [(NSNumber*)[rowDict objectForKey:@"lng"] doubleValue];
    // CLLocationCoordinate2D selectionCoords = CLLocationCoordinate2DMake(lat, lng);
     //[m_MapView setCenterCoordinate:selectionCoords  animated:NO];
     
    // [m_MapView removeAllAnnotations];
     //[self addMarkerWithTitle:[rowDict objectForKey:@"regionName"] andCoordinate:&selectionCoords];
    

    // Notify the delegate if a row is selected.
    [self.delegate searchSuggestController:self didSelectName:name displayName:displayName lat:lat lng:lng];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
