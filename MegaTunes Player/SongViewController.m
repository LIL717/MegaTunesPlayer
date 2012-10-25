//
//  SongViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//
#import "MainViewController.h"
#import "NotesViewController.h"
#import "SongViewController.h"
#import "SongCell.h"
#import "CollectionItem.h"
#import "AppDelegate.h"

@implementation SongViewController

@synthesize itemCollection;
@synthesize collectionItem;


- (id)initWithStyle:(UITableViewStyle)style
{
    LogMethod();
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
//    LogMethod();
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];

//    self.currentQueue = self.mainViewController.userMediaItemCollection;
    
//    NSArray *returnedQueue = [self.currentQueue items];
//    
//    for (MPMediaItem *song in returnedQueue) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"\t\t%@", songTitle);
//    }

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
    //    LogMethod();
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog (@"song count %d", [[self.currentQueue items] count]);
    
    return [[self.itemCollection items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SongCell *cell = (SongCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"SongCell"];
    
    MPMediaItem *song = [[self.itemCollection items] objectAtIndex:indexPath.row];

    cell.nameLabel.text = [song valueForProperty:  MPMediaItemPropertyTitle];
    
    long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];
    int playbackHours = (playbackDuration / 3600);                         // returns number of whole hours fitted in totalSecs
    int playbackMinutes = ((playbackDuration / 60) - playbackHours*60);     // Whole minutes
    int playbackSeconds = (playbackDuration % 60);                        // seconds
    cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playbackMinutes, playbackSeconds];

    MPMediaItemArtwork *artWork = [song valueForProperty:MPMediaItemPropertyArtwork];    
    cell.imageView.image = [artWork imageWithSize:CGSizeMake(30, 30)];
    
//    NSString *songTitle =[song valueForProperty: MPMediaItemPropertyTitle];
//    NSNumber *duration = [song valueForProperty: MPMediaItemPropertyPlaybackDuration];
//    NSLog (@"\t\t%@,%@", songTitle,duration);
    
    return cell;
}
#pragma mark - Table view delegate

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
    
	if ([segue.identifier isEqualToString:@"ViewNotes"])
	{
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        NotesViewController *notesViewController = segue.destinationViewController;
        
        MPMediaItem *song = [[self.itemCollection items] objectAtIndex:indexPath.row];
        
        NSString *notesTitle = [NSString stringWithFormat: @"%@ - Notes",[song valueForProperty:  MPMediaItemPropertyTitle]];
        notesViewController.title = notesTitle;
//        long playbackDuration = [[song valueForProperty: MPMediaItemPropertyPlaybackDuration] longValue];

	}
    	if ([segue.identifier isEqualToString:@"LaunchPlayer"])
	{
        MainViewController *mainViewController = segue.destinationViewController;

        mainViewController.userMediaItemCollection = self.itemCollection;
        mainViewController.collectionItem = self.collectionItem;
    }
}

- (void)viewDidUnload {

    [super viewDidUnload];
}

@end