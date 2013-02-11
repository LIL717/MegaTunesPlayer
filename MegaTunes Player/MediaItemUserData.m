//
//  MediaItemUserData.m
//  MegaTunes Player
//
//  Created by Lori Hill on 2/6/13.
//
//

#import "MediaItemUserData.h"
#import "UserDataForMediaItem.h"

@implementation MediaItemUserData

@dynamic title;
@dynamic userClassification;
@dynamic userNotes;
@dynamic persistentID;
@dynamic lastPlayedDate;
@dynamic bpm;

@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;

@synthesize fetchedObjects;

- (void)addMediaItemToCoreData:(UserDataForMediaItem *) mediaItem {

    //LogMethod();
    
//    [self removeMediaItemFromCoreData];
    
    NSError * error = nil;
    
    // insert the user data for MediaItem into Core Data
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MediaItemUserData" inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue: mediaItem.title forKey:@"title"];
    [newManagedObject setValue: mediaItem.userClassification forKey: @"userClassification"];
    [newManagedObject setValue: mediaItem.userNotes forKey: @"userNotes"];
    [newManagedObject setValue: mediaItem.persistentID forKey:@"persistentID"];
    [newManagedObject setValue: mediaItem.lastPlayedDate forKey: @"lastPlayedDate"];
    [newManagedObject setValue: mediaItem.bpm forKey: @"bpm"];

    NSLog(@" newManagedObject is %@", newManagedObject);
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
    }
    
}

- (UserDataForMediaItem *) containsItem: (NSNumber *) currentItem {

//    BOOL itemFound;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaItemUserData"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *persistentIDString = [currentItem stringValue];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"persistentID == %@", persistentIDString];
    [fetchRequest setPredicate:pred];
    
    NSLog(@"entity retrieved is %@", entity);

    NSError *error = nil;
    self.fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (self.fetchedObjects == nil) {
        // Handle the error
        NSLog (@"fetch error");
    }
    
//    itemFound = NO;
    if ([self.fetchedObjects count] == 0) {
        NSLog (@"no objects fetched");
//        itemFound = NO;
        return nil;
    } else {
        // if there is an object, need to return it
//        itemFound = YES;
        NSLog(@" fetchedObject is %@", [self.fetchedObjects objectAtIndex:0]);
        return [self.fetchedObjects objectAtIndex:0];
        
        //for nslog
        UserDataForMediaItem *userDataForMediaItem = [self.fetchedObjects objectAtIndex:0];
        NSLog(@"persistentID fetched from Core Data %@", userDataForMediaItem.persistentID);

    }
}
- (void) updateLastPlayedDateForItem: (NSNumber *) currentItem {
    
    if ([self containsItem: currentItem]) {
        [[self.fetchedObjects objectAtIndex:0] setValue: [NSDate date] forKey: @"lastPlayedDate"];

        NSError * error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%s: Problem saving: %@", __PRETTY_FUNCTION__, error);
        }
            NSLog(@" updatedManagedObject is %@", [self.fetchedObjects objectAtIndex:0]);
    } else {
        UserDataForMediaItem *userDataForMediaItem = [[UserDataForMediaItem alloc] init];
        userDataForMediaItem.persistentID = currentItem;
        userDataForMediaItem.lastPlayedDate = [NSDate date];
        [self addMediaItemToCoreData:userDataForMediaItem];
        
        NSLog(@"persistnentID inserted into Core Data %@", userDataForMediaItem.persistentID);
    }
}

@end
