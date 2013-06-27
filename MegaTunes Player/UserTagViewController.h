//
//  UserTagViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 6/8/13.
//
//
@class MTSearchBar;
@class UserDataForMediaItem;
@class UserTagViewController;
#import "FMMoveTableView.h"
#import "AddTagViewController.h"

@protocol UserTagViewControllerDelegate <NSObject>

- (void)userTagViewControllerDidCancel: (UserTagViewController *)controller;

@end

@interface UserTagViewController : UIViewController <AddTagViewControllerDelegate, NSFetchedResultsControllerDelegate, FMMoveTableViewDataSource, FMMoveTableViewDelegate> {

    NSManagedObjectContext *managedObjectContext_;
    
}

@property (strong, nonatomic) IBOutlet FMMoveTableView *userTagTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain)   NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id <UserTagViewControllerDelegate> userTagViewControllerDelegate;
@property (nonatomic, strong)   UserDataForMediaItem *userDataForMediaItem;

//@property (readwrite)           BOOL iPodLibraryChanged;

- (void)addTagViewControllerDidCancel:(AddTagViewController *)controller;


@end