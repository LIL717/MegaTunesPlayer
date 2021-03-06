//
//  TaggedSongViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/28/13.
//
//

@class CollectionItem;
@class TaggedSectionIndexData;

#import "InfoTabBarController.h"


@interface TaggedSongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, InfoTabBarControllerDelegate, MPMediaPickerControllerDelegate, UISearchControllerDelegate,  UISearchDisplayDelegate> {
    
    NSManagedObjectContext *managedObjectContext_;
    
}

@property (strong, nonatomic) IBOutlet UITableView *songTableView;

@property (strong, nonatomic)   IBOutlet UIView *shuffleView;
@property (strong, nonatomic)   IBOutlet UIButton *shuffleButton;

@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)   CollectionItem *collectionItem;
@property (nonatomic, strong)   MPMediaItemCollection *collectionOfOne;

@property (nonatomic, strong)	MPMusicPlayerController	*musicPlayer;
@property (nonatomic, strong)   MPMediaItem *mediaItemForInfo;
@property (nonatomic, strong)   MPMediaItem *itemToPlay;
@property (readwrite)           BOOL iPodLibraryChanged;
//@property (readwrite)           BOOL listIsAlphabetic;
@property (nonatomic, retain)   MPMediaItemCollection *songCollection;
@property (nonatomic, strong)   UIBarButtonItem *playBarButton;
@property (nonatomic, strong)   UIBarButtonItem *tagBarButton;
@property (nonatomic, strong)   UIBarButtonItem *colorTagBarButton;
@property (nonatomic, strong)   UIBarButtonItem *noColorTagBarButton;

@property (nonatomic, strong)   MPMediaQuery *collectionQueryType;
@property (nonatomic, strong)   CollectionItem *collectionItemToSave;
@property (readwrite)           BOOL showTagButton;
@property (readwrite)           BOOL showTags;
@property (nonatomic, strong)   NSString *songViewTitle;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftRight;
@property (nonatomic)           BOOL collectionContainsICloudItem;
@property (readwrite)           BOOL cellScrolled;
@property (readwrite)           BOOL songShuffleButtonPressed;
@property (nonatomic, strong)   NSMutableArray *taggedSongArray;
@property (nonatomic, strong)   NSArray *sortedTaggedArray;
@property (nonatomic, strong)   TaggedSectionIndexData *taggedSectionIndexData;
//140220 1.2 iOS 7 begin
@property (nonatomic, strong)   UIButton *tempPlayButton;
@property (nonatomic, strong)   UIButton *tempColorButton;
@property (nonatomic, strong)   UIButton *tempNoColorButton;
//140220 1.2 iOS 7 end







- (void) infoTabBarControllerDidCancel:(InfoTabBarController *)controller;
- (IBAction)playWithShuffle:(id)sender;


@end