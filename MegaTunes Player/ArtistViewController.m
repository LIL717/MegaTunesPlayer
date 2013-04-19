//
//  CollectionViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 10/1/12.
//
//

#import "ArtistViewController.h"
#import "CollectionItemCell.h"
#import "CollectionItem.h"
#import "SongViewController.h"
#import "DTCustomColoredAccessory.h"
#import "MainViewController.h"
//#import "InCellScrollView.h"
#import "AlbumViewcontroller.h"


@interface ArtistViewController ()

@end

@implementation ArtistViewController

@synthesize collectionTableView;
@synthesize collection;
@synthesize collectionType;
@synthesize collectionQueryType;
@synthesize managedObjectContext;
@synthesize saveIndexPath;
@synthesize iPodLibraryChanged;         //A flag indicating whether the library has been changed due to a sync
@synthesize musicPlayer;
@synthesize artistsDataArray;
@synthesize albumCollection;
@synthesize selectedIndexPath;

- (void) viewDidLoad {
    
    [super viewDidLoad];
	
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: @"background.png"]]];
    
    
    self.navigationItem.hidesBackButton = YES; // Important
    //initWithTitle cannot be nil, must be @""
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(goBackClick)];
    
    UIImage *menuBarImage48 = [[UIImage imageNamed:@"arrow_left_48_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *menuBarImage58 = [[UIImage imageNamed:@"arrow_left_58_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage48 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.leftBarButtonItem setBackgroundImage:menuBarImage58 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];

    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    [self registerForMediaPlayerNotifications];
    
    //add an NSString @"All Songs" object to the beginning of the collection array, then use albumDataArray as data source for table
    
    self.artistsDataArray = [[NSMutableArray alloc] initWithCapacity: 20];
    [self.artistsDataArray addObjectsFromArray: self.collection];
    [self.artistsDataArray insertObject: @"All Albums" atIndex: 0];

}

- (void) viewWillAppear:(BOOL)animated
{
    //    LogMethod();
    [super viewWillAppear: animated];
    
    self.navigationItem.titleView = [self customizeTitleView];
  
    NSString *playingItem = [[musicPlayer nowPlayingItem] valueForProperty: MPMediaItemPropertyTitle];
    
    if (playingItem) {
        //initWithTitle cannot be nil, must be @""
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(viewNowPlaying)];
        
        UIImage *menuBarImageDefault = [[UIImage imageNamed:@"redWhitePlay57.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImage *menuBarImageLandscape = [[UIImage imageNamed:@"redWhitePlay68.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageDefault forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.navigationItem.rightBarButtonItem setBackgroundImage:menuBarImageLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    } else {
        self.navigationItem.rightBarButtonItem= nil;
    }
    [self updateLayoutForNewOrientation: self.interfaceOrientation];

    return;
}

- (UILabel *) customizeTitleView
{
    CGRect frame = CGRectMake(0, 0, [self.title sizeWithFont:[UIFont systemFontOfSize:44.0]].width, 48);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    label.font = newFont;
    label.textColor = [UIColor yellowColor];
    label.text = self.title;
    
    return label;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval)duration {
    
    [self updateLayoutForNewOrientation: orientation];
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(11,0,0,0)];
    } else {
        [self.collectionTableView setContentInset:UIEdgeInsetsMake(23,0,0,0)];
        //if rotating to landscape and row 0 will be visible, need to scrollRectToVisible to align it correctly
        NSArray *indexes = [self.collectionTableView indexPathsForVisibleRows];
        for (NSIndexPath *index in indexes) {
            if (index.row == 0) {
                [self.collectionTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

            }
        }
    }
    [self.collectionTableView reloadData];
}
- (void) viewWillLayoutSubviews {
        //need this to pin portrait view to bounds otherwise if start in landscape, push to next view, rotate to portrait then pop back the original view in portrait - it will be too wide and "scroll" horizontally
    self.collectionTableView.contentSize = CGSizeMake(self.collectionTableView.frame.size.width, self.collectionTableView.contentSize.height);
    [super viewWillLayoutSubviews];
}

#pragma mark Table view methods________________________
// Configures the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
        
    return [self.artistsDataArray count];
}
//#pragma - TableView Index Scrolling
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    
////    if(searching)
////        return nil;
//    
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//    [tempArray addObject:@"A"];
//    [tempArray addObject:@"B"];
//    [tempArray addObject:@"C"];
//    [tempArray addObject:@"D"];
//    [tempArray addObject:@"E"];
//    [tempArray addObject:@"F"];
//    [tempArray addObject:@"G"];
//    [tempArray addObject:@"H"];
//    [tempArray addObject:@"I"];
//    [tempArray addObject:@"J"];
//    [tempArray addObject:@"K"];
//    [tempArray addObject:@"L"];
//    [tempArray addObject:@"M"];
//    [tempArray addObject:@"N"];
//    [tempArray addObject:@"O"];
//    [tempArray addObject:@"P"];
//    [tempArray addObject:@"Q"];
//    [tempArray addObject:@"R"];
//    [tempArray addObject:@"S"];
//    [tempArray addObject:@"T"];
//    [tempArray addObject:@"U"];
//    [tempArray addObject:@"V"];
//    [tempArray addObject:@"W"];
//    [tempArray addObject:@"Y"];
//    [tempArray addObject:@"X"];
//    [tempArray addObject:@"Z"];
//    
//    return tempArray;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    
////    if(searching)
////        return -1;
////    
////    return index % 2;
//}
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    if (indexPath.row == 0) {
        // dequeue and configure my static cell for indexPath.row
        NSString *cellIdentifier = @"allAlbumsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor blueColor];
        cell.textLabel.text = @"All Albums";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:44];
        cell.textLabel.textColor = [UIColor whiteColor];
        DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.textLabel.textColor];
        accessory.highlightedColor = [UIColor blueColor];
        cell.accessoryView = accessory;
        
        return cell;
    }

	CollectionItemCell *cell = (CollectionItemCell *)[tableView
                                          dequeueReusableCellWithIdentifier:@"CollectionItemCell"];
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);

//    if ([self.collectionType isEqualToString: @"Playlists"]) {
//        MPMediaPlaylist  *mediaPlaylist = [self.collectionDataArray objectAtIndex:indexPath.row];
//        cell.nameLabel.text = [mediaPlaylist valueForProperty: MPMediaPlaylistPropertyName];
//    }
    
    cell.durationLabel.text = @"";

    if ([[self.artistsDataArray objectAtIndex:indexPath.row] count] > 0) {

        MPMediaItemCollection *currentQueue = [MPMediaItemCollection collectionWithItems: [[self.artistsDataArray objectAtIndex:indexPath.row] items]];

        if ([self.collectionType isEqualToString: @"Artists"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyArtist];
        }
        if ([self.collectionType isEqualToString: @"Composers"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyComposer];
        }
        if ([self.collectionType isEqualToString: @"Genres"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyArtist];
        }
        if ([self.collectionType isEqualToString: @"Podcasts"]) {
            cell.nameLabel.text = [[currentQueue representativeItem] valueForProperty: MPMediaItemPropertyPodcastTitle];
        }
        if (cell.nameLabel.text == nil) {
            cell.nameLabel.text = @"Unknown";
        }
        
        //get the duration of the the playlist
        if (isPortrait) {
            cell.durationLabel.hidden = YES;
        } else {
            cell.durationLabel.hidden = NO;
            
            NSNumber *playlistDurationNumber = [self calculatePlaylistDuration: currentQueue];
            long playlistDuration = [playlistDurationNumber longValue];
            
            int playlistMinutes = (playlistDuration / 60);     // Whole minutes
            int playlistSeconds = (playlistDuration % 60);                        // seconds
            cell.durationLabel.text = [NSString stringWithFormat:@"%2d:%02d", playlistMinutes, playlistSeconds];
//            [cell.textLabel addSubView:cell.durationLabel];
        }

    }
    //set the textLabel to the same thing - it is used if the text does not need to scroll
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    cell.textLabel.font = newFont;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor blueColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.textLabel.lineBreakMode = NSLineBreakByClipping;
    cell.textLabel.text = cell.nameLabel.text;
    
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.nameLabel.textColor];
    accessory.highlightedColor = [UIColor blueColor];
    cell.accessoryView = accessory;
//    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //size of duration Label is set at 130 to match the fixed size that it is set in interface builder
    // note that cell.durationLabel.frame.size.width) = 0 here
    //    NSLog (@"************************************width of durationLabel is %f", cell.durationLabel.frame.size.width);

    // if want to make scrollview width flex with width of duration label, need to set it up in code rather than interface builder - not doing that now, but don't see any problem with doing it
    
//    CGSize durationLabelSize = [cell.durationLabel.text sizeWithFont:cell.durationLabel.font
//                                                   constrainedToSize:CGSizeMake(135, CGRectGetHeight(cell.durationLabel.bounds))
//                                                       lineBreakMode:NSLineBreakByClipping];
    //cell.durationLabel.frame.size.width = 130- have to hard code because not calculated yet at this point
    
    //this is the constraint from scrollView to Cell  needs to just handle accessory in portrait and handle duration and accessory in landscape
    CGFloat contraintConstant = isPortrait ? 30 : (30 + 130 + 5);

    
    cell.scrollViewToCellConstraint.constant = contraintConstant;

    NSUInteger scrollViewWidth;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //14 just is the number that was needed to make the label scroll correctly within the scrollView
        scrollViewWidth = (tableView.frame.size.width -28 - cell.accessoryView.frame.size.width);
    } else {
//        scrollViewWidth = (tableView.frame.size.width - durationLabelSize.width - cell.accessoryView.frame.size.width);
        // and 145 is the number that makes the scroll work right in landscape - don't try to figure it out
        scrollViewWidth = (tableView.frame.size.width - 145 - cell.accessoryView.frame.size.width);

    }
    [cell.scrollView removeConstraint:cell.centerXInScrollView];

    //calculate the label size to fit the text with the font size
    CGSize labelSize = [cell.nameLabel.text sizeWithFont:cell.nameLabel.font
                                       constrainedToSize:CGSizeMake(INT16_MAX,tableView.rowHeight)
                                           lineBreakMode:NSLineBreakByClipping];
    
//    //build a new label that will hold all the text
//    UILabel *newLabel = [[UILabel alloc] initWithFrame: cell.nameLabel.frame];
//    CGRect frame = newLabel.frame;
////    frame.size.height = CGRectGetHeight(cell.nameLabel.bounds);
//    frame.size.width = labelSize.width;
//    newLabel.frame = frame;
//
//    //set the UIOutlet label's frame to the new sized frame
//    cell.nameLabel.frame = newLabel.frame;
    
    //    NSLog (@"size of newLabel is %f", frame.size.width);
    
    //***********add constaint to line up Y of nameLabel and scrollView
    
    //Make sure that label is aligned with scrollView
    [cell.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    

    if (labelSize.width>scrollViewWidth) {
        cell.scrollView.hidden = NO;
        cell.textLabel.hidden = YES;
    }
    else {
        cell.scrollView.hidden = YES;
        cell.textLabel.hidden = NO;
    }
    
    return cell;
}
- (NSNumber *)calculatePlaylistDuration: (MPMediaItemCollection *) currentQueue {

    NSArray *returnedQueue = [currentQueue items];
    
    long playlistDuration = 0;
    long songDuration = 0;

    for (MPMediaItem *song in returnedQueue) {
        songDuration = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
        //if the  song has been deleted during a sync then pop to rootViewController

        if (songDuration == 0 && self.iPodLibraryChanged) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSLog (@"BOOM");
        }
//        playlistDuration = (playlistDuration + [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
        playlistDuration = (playlistDuration + songDuration);

    }
    return [NSNumber numberWithLong: playlistDuration];
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
//    LogMethod();
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    //if there is more than one album, display albums, otherwise display songs in the album in song order
    if (!indexPath.row == 0) {
        CollectionItemCell *cell = (CollectionItemCell*)[self.collectionTableView cellForRowAtIndexPath:indexPath];
        
        NSString *mediaItemProperty = [[NSString alloc] init];
        
        if ([self.collectionType isEqualToString: @"Artists"] || [self.collectionType isEqualToString: @"Genres"]) {
            mediaItemProperty = MPMediaItemPropertyAlbumArtist;
        } else {
            if ([self.collectionType isEqualToString: @"Composers"]) {
                 mediaItemProperty = MPMediaItemPropertyComposer;
            }
        }
        
        MPMediaQuery *myCollectionQuery = [[MPMediaQuery alloc] init];
//        MPMediaQuery *myCollectionQuery = self.collectionQueryType;

        
        [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                predicateWithValue: cell.nameLabel.text
                                                forProperty: mediaItemProperty]];
        
        if ([self.collectionType isEqualToString: @"Genres"]) {
            [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                    predicateWithValue: self.title
                                                    forProperty: MPMediaItemPropertyGenre]];
        }
        // Sets the grouping type for the media query
        [myCollectionQuery setGroupingType: MPMediaGroupingAlbum];
        
//        self.collectionQueryType = myCollectionQuery;
        self.albumCollection = [myCollectionQuery collections];
        
//        NSLog(@"album Collection count is %d", [self.albumCollection count]);
        
        self.selectedIndexPath = indexPath;
        
        if ([self.albumCollection count] > 1) {
            [self performSegueWithIdentifier: @"AlbumCollections" sender: self];
        } else {
            [self performSegueWithIdentifier: @"ViewSongs" sender: self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    LogMethod();
//    NSIndexPath *indexPath = [ self.collectionTableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"ViewAllAlbums"])
	{
		AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
        
        MPMediaQuery *myCollectionQuery = [[MPMediaQuery alloc] init];

        if ([self.collectionType isEqualToString: @"Genres"]) {
            
            [myCollectionQuery addFilterPredicate: [MPMediaPropertyPredicate
                                                    predicateWithValue: self.title
                                                    forProperty: MPMediaItemPropertyGenre]];
            // Sets the grouping type for the media query
            [myCollectionQuery setGroupingType: MPMediaGroupingAlbum];
        } else {
            myCollectionQuery = [MPMediaQuery albumsQuery];
        }
        
        self.collection = [myCollectionQuery collections];
		albumViewController.collection = self.collection;
        albumViewController.collectionType = @"Albums";
        albumViewController.collectionQueryType = myCollectionQuery;
        albumViewController.title = NSLocalizedString(@"Albums", nil);
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
	}
    //this is called if there is only one album - the songs for that album are displayed in track order
	if ([segue.identifier isEqualToString:@"ViewSongs"])
	{
        NSIndexPath *indexPath = self.selectedIndexPath;

        SongViewController *songViewController = segue.destinationViewController;
        songViewController.managedObjectContext = self.managedObjectContext;

        CollectionItemCell *cell = (CollectionItemCell*)[self.collectionTableView cellForRowAtIndexPath:indexPath];

        CollectionItem *collectionItem = [CollectionItem alloc];
        collectionItem.name = cell.nameLabel.text;
//        collectionItem.duration = [self calculatePlaylistDuration: [self.collectionDataArray objectAtIndex:indexPath.row]];
        collectionItem.duration = [self calculatePlaylistDuration: [self.albumCollection objectAtIndex: 0]];

        
//        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.collectionDataArray objectAtIndex:indexPath.row] items]];
        collectionItem.collectionArray = [NSMutableArray arrayWithArray:[[self.albumCollection objectAtIndex:0] items]];

//        collectionItem.collectionArray = [self.albumCollection objectAtIndex:0];


        songViewController.iPodLibraryChanged = self.iPodLibraryChanged;
        
        songViewController.title = collectionItem.name;
//        NSLog (@"collectionItem.name is %@", collectionItem.name);

        songViewController.collectionItem = collectionItem;

	}
    if ([segue.identifier isEqualToString:@"AlbumCollections"])
	{
        NSIndexPath *indexPath = self.selectedIndexPath;

        CollectionItemCell *cell = (CollectionItemCell*)[self.collectionTableView cellForRowAtIndexPath:indexPath];

        AlbumViewController *albumViewController = segue.destinationViewController;
        albumViewController.managedObjectContext = self.managedObjectContext;
        
        albumViewController.title = cell.nameLabel.text;
        albumViewController.collection = self.albumCollection;
        albumViewController.collectionType = self.collectionType;
        albumViewController.collectionQueryType = self.collectionQueryType;
        
        albumViewController.iPodLibraryChanged = self.iPodLibraryChanged;
	}
    if ([segue.identifier isEqualToString:@"ViewNowPlaying"])
	{
		MainViewController *mainViewController = segue.destinationViewController;
        mainViewController.managedObjectContext = self.managedObjectContext;

        mainViewController.playNew = NO;
        mainViewController.iPodLibraryChanged = self.iPodLibraryChanged;

    }
}
- (IBAction)viewNowPlaying {
    
    [self performSegueWithIdentifier: @"ViewNowPlaying" sender: self];
}

#pragma mark Application state management_____________
// Standard methods for managing application state.

- (void)goBackClick
{
    //both actually go back to mediaGroupViewController 
    if (iPodLibraryChanged) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//// this subclassed to prevent scrollView from intrepretting half a tap as a tap (turning cell blue but not actually selecting until next selection
//- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
//{
//    LogMethod();
//    
//    CGPoint currentTouchPosition=[gesture locationInView:self.collectionTableView];
//    NSIndexPath *indexPath = [self.collectionTableView indexPathForRowAtPoint: currentTouchPosition];
//    CollectionItemCell *cell = (CollectionItemCell *)[self.collectionTableView cellForRowAtIndexPath:indexPath];
//    cell.nameLabel.highlighted = YES;
//
//    [self.collectionTableView.delegate tableView:self.collectionTableView didSelectRowAtIndexPath:indexPath];
//    [self performSegueWithIdentifier: @"ViewSongs" sender: [self.collectionTableView cellForRowAtIndexPath:indexPath]];
//}

- (void) registerForMediaPlayerNotifications {
//    LogMethod();
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    [notificationCenter addObserver: self
                           selector: @selector (handle_iPodLibraryChanged:)
                               name: MPMediaLibraryDidChangeNotification
                             object: nil];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    [musicPlayer beginGeneratingPlaybackNotifications];

}
- (void) handle_iPodLibraryChanged: (id) changeNotification {
//    LogMethod();
	// Implement this method to update cached collections of media items when the
	// user performs a sync while application is running.
    [self setIPodLibraryChanged: YES];
    
}
// When the playback state changes, if stopped remove nowplaying button
- (void) handle_PlaybackStateChanged: (id) notification {
    LogMethod();
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
    if (playbackState == MPMusicPlaybackStateStopped) {
        self.navigationItem.rightBarButtonItem= nil;
	}
    
}
- (void)dealloc {
//    LogMethod();
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMediaLibraryDidChangeNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];

    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
    [musicPlayer endGeneratingPlaybackNotifications];

}
- (void)didReceiveMemoryWarning {
        
    [super didReceiveMemoryWarning];
	

}
@end
