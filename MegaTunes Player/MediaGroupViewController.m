//
//  MediaGroupViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/19/12.
//
//

#import "MediaGroupViewController.h"
#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "MediaGroup.h"
#import "MediaGroupCell.h"
#import "SongViewController.h"
#import "CollectionItem.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"

@interface MediaGroupViewController ()

@end

@implementation MediaGroupViewController

@synthesize delegate;
@synthesize collection;
@synthesize groupingData;
@synthesize selectedGroup;
@synthesize musicPlayer;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

-(void) loadGroupingData
{
    MediaGroup* group0 = [[MediaGroup alloc] initWithName:@"Playlists" andQueryType: [MPMediaQuery playlistsQuery]];
    
    MediaGroup* group1 = [[MediaGroup alloc] initWithName:@"Artists" andQueryType: [MPMediaQuery artistsQuery]];
    
    MediaGroup* group2 = [[MediaGroup alloc] initWithName:@"Songs" andQueryType: [MPMediaQuery songsQuery]];
    
    MediaGroup* group3 = [[MediaGroup alloc] initWithName:@"Albums" andQueryType: [MPMediaQuery albumsQuery]];

    MediaGroup* group4 = [[MediaGroup alloc] initWithName:@"Compilations" andQueryType: [MPMediaQuery compilationsQuery]];
    
    MediaGroup* group5 = [[MediaGroup alloc] initWithName:@"Composers" andQueryType: [MPMediaQuery composersQuery]];
    
    MediaGroup* group6 = [[MediaGroup alloc] initWithName:@"Genres" andQueryType: [MPMediaQuery genresQuery]];
    
    MediaGroup* group7 = [[MediaGroup alloc] initWithName:@"Podcasts" andQueryType: [MPMediaQuery podcastsQuery]];

    
    self.groupingData = [NSArray arrayWithObjects:group0, group1, group2, group3, group4, group5, group6, group7, nil];
    
    return;
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadGroupingData];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.groupingData count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	MediaGroupCell *cell = (MediaGroupCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"MediaGroupCell"];
    MediaGroup *group = [self.groupingData objectAtIndex:indexPath.row];
    cell.nameLabel.text = group.name;
    
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;
    
    return cell;
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

#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
//    LogMethod();

	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    self.selectedGroup = [self.groupingData objectAtIndex:indexPath.row];
    if (selectedGroup.name == @"Songs") {
        [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
    } else
        if (selectedGroup.name == @"Compilations") {
            [self performSegueWithIdentifier: @"ViewSongCollection" sender: self];
        } else
        {
            [self performSegueWithIdentifier: @"ViewCollections" sender: self];
    }
//    NSLog (@"group.name is %@", group.name);

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
	if ([segue.identifier isEqualToString:@"ViewCollections"])
	{
		CollectionViewController *collectionViewController = segue.destinationViewController;

        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [myCollectionQuery collections];
		collectionViewController.collection = self.collection;
        collectionViewController.title = selectedGroup.name;

	}
    
    if ([segue.identifier isEqualToString:@"ViewSongCollection"])
	{
        SongViewController *songViewController = segue.destinationViewController;
        
        MPMediaQuery *myCollectionQuery = selectedGroup.queryType;
        
        self.collection = [myCollectionQuery collections];
        
        NSMutableArray *songMutableArray = [[NSMutableArray alloc] init];
        long playlistDuration = 0;
        
        for (MPMediaPlaylist *mediaPlaylist in self.collection) {
            
            NSArray *songs = [mediaPlaylist items];

            for (MPMediaItem *song in songs) {
                [songMutableArray addObject: song];
                playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
//                NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//                NSLog (@"\t\t%@", songTitle);
            }
        }
        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = selectedGroup.name;
        collectionItem.duration = [NSNumber numberWithLong: playlistDuration];
        

        songViewController.title = collectionItem.name;
        songViewController.collectionItem = collectionItem;
        
        songViewController.itemCollection = [MPMediaItemCollection collectionWithItems: songMutableArray];
	}
//    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
//	{
//		MainViewController *mainViewController = segue.destinationViewController;
//        
////        if ([musicPlayer nowPlayingItem]) {
//            CollectionItem *collectionItem = [CollectionItem alloc];
//        NSString *titleIDKey = [self.musicPlayer.nowPlayingItem valueForProperty: MPMediaGroupingTitle];
//
//        collectionItem.name = self.musicPlayer.nowPlayingItem titlePropertyForGroupingType: (MPMediaGrouping) groupingType;
//
//            collectionItem.duration = [self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
//            mainViewController.collectionItem = collectionItem;
//            NSArray *fakeArray = [[NSArray alloc] initWithObjects: [self.musicPlayer nowPlayingItem], nil];
//            mainViewController.userMediaItemCollection = [MPMediaItemCollection collectionWithItems: fakeArray];
////            }
//        }
//
}

@end
