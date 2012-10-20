//
//  MainViewController.m
//  MegaTunes Player
//
//  Created by Lori Hill on 9/23/12.
//
//

#import "MainViewController.h"
#import "CollectionItem.h"
#import "TextMagnifierViewController.h"
#import "TimeMagnifierViewController.h"
#import "AppDelegate.h"



#pragma mark Audio session callbacks_______________________

// Audio session callback function for responding to audio route changes. If playing
//		back application audio when the headset is unplugged, this callback pauses
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
	// This callback, being outside the implementation block, needs a reference to the
	//		MainViewController object, which it receives in the inUserData parameter.
	//		You provide this reference when registering this callback (see the call to
	//		AudioSessionAddPropertyListener).
	MainViewController *controller = (__bridge MainViewController *) inUserData;
	
	// if application sound is not playing, there's nothing to do, so return.
	if (controller.appSoundPlayer.playing == 0 ) {
        
		NSLog (@"Audio route change while application audio is stopped.");
		return;
		
	} else {
        
		// Determines the reason for the route change, to ensure that it is not
		//		because of a category change.
		CFDictionaryRef	routeChangeDictionary = inPropertyValue;
		
		CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
		SInt32 routeChangeReason;
		
		CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
		
		// "Old device unavailable" indicates that a headset was unplugged, or that the
		//	device was removed from a dock connector that supports audio output. This is
		//	the recommended test for when to pause audio.
		if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
			[controller.appSoundPlayer pause];
			NSLog (@"Output device removed, so application audio was paused.");
            
			UIAlertView *routeChangeAlertView =
            [[UIAlertView alloc]	initWithTitle: NSLocalizedString (@"Playback Paused", @"Title for audio hardware route-changed alert view")
                                       message: NSLocalizedString (@"Audio output was changed", @"Explanation for route-changed alert view")
                                      delegate: controller
                             cancelButtonTitle: NSLocalizedString (@"StopPlaybackAfterRouteChange", @"Stop button title")
                             otherButtonTitles: NSLocalizedString (@"ResumePlaybackAfterRouteChange", @"Play button title"), nil];
			[routeChangeAlertView show];
			// release takes place in alertView:clickedButtonAtIndex: method
            
		} else {
            
			NSLog (@"A route change occurred that does not require pausing of application audio.");
		}
	}
}



@implementation MainViewController

@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library
@synthesize navigationBar;				// the application's Navigation bar
@synthesize nowPlayingLabel;			// descriptive text shown on the main screen about the now-playing media item
//@synthesize autoScrollLabel;
@synthesize appSoundPlayer;				// An AVAudioPlayer object for playing application sound
@synthesize soundFileURL;				// The path to the application sound
@synthesize interruptedOnPlayback;		// A flag indicating whether or not the application was interrupted during application audio playback
@synthesize playedMusicOnce;			// A flag indicating if the user has played iPod library music at least one time since application launch.
@synthesize playing;					// An application that responds to interruptions must keep track of its playing not-playing state.
@synthesize playbackTimer;

//these lines came from player view controller

@synthesize currentQueue;
@synthesize elapsedTimeLabel;
@synthesize progressSlider;
@synthesize remainingTimeLabel;
@synthesize previousButton;
@synthesize playPauseButton;
@synthesize nextButton;
@synthesize nextSongLabel;
@synthesize playlist;


#pragma mark Music control________________________________

// A toggle control for playing or pausing iPod library music playback, invoked
//		when the user taps the 'playButton'.
- (IBAction) playOrPauseMusic: (id)sender {
   LogMethod();    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
        [self playMusic];

	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}
}

- (IBAction)skipBack:(id)sender {
    if ([musicPlayer currentPlaybackTime] > 5.0) {
        [musicPlayer skipToBeginning];
    } else {
        [musicPlayer skipToPreviousItem];
    }
}

- (IBAction)skipForward:(id)sender {
    [musicPlayer skipToNextItem];

}

- (IBAction)moveSlider:(id)sender {
    LogMethod();
    [musicPlayer setCurrentPlaybackTime: [self.progressSlider value]];
}
- (void) playMusic {
    
    [musicPlayer play];
    [self updateTime];
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateTime)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void) updateTime
{
    long playbackSeconds = musicPlayer.currentPlaybackTime;
    long songDuration = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    
    long playlistDuration = [self.playlist.duration longValue];
        
    long songRemainingSeconds = songDuration - playbackSeconds;
    
    long playlistElapsed = [[self calculatePlaylistElapsed] longValue] + playbackSeconds;
    long playlistRemainingSeconds = playlistDuration - playlistElapsed;
    
    NSString *elapsed = [NSString stringWithFormat:@"%02lu:%02lu",playbackSeconds/60,playbackSeconds-(playbackSeconds/60)*60];
    NSString *songRemaining = [NSString stringWithFormat:@"%02lu:%02lu",songRemainingSeconds/60,songRemainingSeconds-(songRemainingSeconds/60)*60];
    NSString *playlistRemaining = [NSString stringWithFormat:@"%02lu:%02lu",playlistRemainingSeconds/60,playlistRemainingSeconds-(playlistRemainingSeconds/60)*60];
        
    //Use NSDateFormatter to get seconds and minutes from the time string:
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"m:ss";
    NSDate *elapsedTime = [formatter dateFromString:elapsed];
    NSDate *songRemainingTime = [formatter dateFromString:songRemaining];
    NSDate *playlistRemainingTime = [formatter dateFromString:playlistRemaining];
    
    self.elapsedTimeLabel.text = [formatter stringFromDate:elapsedTime];
    self.elapsedTimeLabel.textColor = [UIColor whiteColor];
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:songRemainingTime]];
    self.remainingTimeLabel.textColor = [UIColor whiteColor];

    
    NSString *playlistRemainingLabel = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:playlistRemainingTime]];
    
//    NSLog (@" playlistRemaining %@", playlistRemainingLabel);

    UIBarButtonItem *durationButton = [[UIBarButtonItem alloc] initWithTitle:playlistRemainingLabel style:UIBarButtonItemStyleBordered target:self action: @selector(magnify)];
    
    self.navigationItem.rightBarButtonItem=durationButton;
    
    [self actualizeSlider];
}
- (void) updatePlaylistRemaining {
    
}
- (NSNumber *)calculatePlaylistElapsed {
        
    NSArray *returnedQueue = [self.userMediaItemCollection items];
    NSUInteger count = [musicPlayer indexOfNowPlayingItem];
    long playlistElapsed = 0;
    
    for (NSUInteger i = 0; i < count; i++) {
#pragma mark TODO aborts on this line on reload
        playlistElapsed = (playlistElapsed + [[[returnedQueue objectAtIndex: i] valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue]);
    }

    return [NSNumber numberWithLong: playlistElapsed];
}
- (void)actualizeSlider {
    self.progressSlider.value = musicPlayer.currentPlaybackTime;
    self.progressSlider.minimumValue = 0;
    
    NSNumber *duration = [self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    float totalTime = [duration floatValue];
    
    self.progressSlider.maximumValue = totalTime;
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
   LogMethod();    
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped && userMediaItemCollection) {
		
		if (playedMusicOnce == NO) {
            
			[self setPlayedMusicOnce: YES];
			[self playMusic];
		}
	}
    
}

#pragma mark Music notification handlers__________________

// When the now-playing item changes, update the now-playing label and the next label.
- (void) handle_NowPlayingItemChanged: (id) notification {
//   LogMethod();    
	MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
	
	// Display the song name for the now-playing media item and next-playing media item with duration
    // scroll marquee style if too long for field

    self.nowPlayingLabel.text = [currentItem valueForProperty:  MPMediaItemPropertyTitle];
    self.nowPlayingLabel.textColor = [UIColor whiteColor];
    UIFont *font = [UIFont systemFontOfSize:12];
    UIFont *newFont = [font fontWithSize:44];
    self.nowPlayingLabel.font = newFont;

    
    NSUInteger nextPlayingIndex = [musicPlayer indexOfNowPlayingItem] + 1;
    
    if (nextPlayingIndex >= userMediaItemCollection.count) {
        self.nextSongLabel.text = [NSString stringWithFormat: @"%@",
                                   NSLocalizedString (@"End of Playlist Instructions", @"Label for Next song title when last song is playing")];
    } else {
        long nextDuration = [[[[self.userMediaItemCollection items] objectAtIndex: nextPlayingIndex] valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
        NSString *formattedNextDuration = [NSString stringWithFormat:@"%2lu:%02lu",nextDuration/60,nextDuration -(nextDuration/60)*60];
        self.nextSongLabel.text = [NSString stringWithFormat: @"%@  %@",[[[self.userMediaItemCollection items] objectAtIndex: nextPlayingIndex] valueForProperty:  MPMediaItemPropertyTitle], formattedNextDuration];
                                   ;
    }
    self.nextSongLabel.textColor = [UIColor whiteColor];
    self.nextSongLabel.font = newFont;
    self.nextSongLabel.textAlignment = NSTextAlignmentLeft;

//	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
//		// Provide a suitable prompt to the user now that their chosen music has
//		//		finished playing.
//		[nowPlayingLabel setText: [
//                                   NSString stringWithFormat: @"%@",
//                                   NSLocalizedString (@"Music-ended Instructions", @"Label for prompting user to play music again after it has stopped")]];
//        
//	}
}

// When the playback state changes, set the play/pause button in the Navigation bar
//		appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
//   LogMethod();    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
	
	if (playbackState == MPMusicPlaybackStatePaused) {
        
        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
		
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
        
        [playPauseButton setImage: [UIImage imageNamed:@"bigpause.png"] forState:UIControlStateNormal];
        
	} else if (playbackState == MPMusicPlaybackStateStopped) {
        
        [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
		
		// Even though stopped, invoking 'stop' ensures that the music player will play
		//		its queue from the start.
		[musicPlayer stop];
        [playbackTimer invalidate];
        
	}
}

- (void) handle_iPodLibraryChanged: (id) notification {
   LogMethod();    
	// Implement this method to update cached collections of media items when the
	// user performs a sync while your application is running. This sample performs
	// no explicit media queries, so there is nothing to update.
}



#pragma mark Application playback control_________________

// delegate method for the audio route change alert view; follows the protocol specified
//	in the UIAlertViewDelegate protocol.
- (void) alertView: routeChangeAlertView clickedButtonAtIndex: buttonIndex {
    
	if ((NSInteger) buttonIndex == 1) {
		[appSoundPlayer play];
	} else {
		[appSoundPlayer setCurrentTime: 0];
	}
	
}



#pragma mark AV Foundation delegate methods____________

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag {
   LogMethod();    
	playing = NO;
}

- (void) audioPlayerBeginInterruption: player {
    LogMethod();   
	NSLog (@"Interrupted. The system has paused audio playback.");
	
	if (playing) {
        
		playing = NO;
		interruptedOnPlayback = YES;
	}
}

- (void) audioPlayerEndInterruption: player {
   LogMethod();    
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	// Reactivates the audio session, whether or not audio was playing
	//		when the interruption arrived.
	[[AVAudioSession sharedInstance] setActive: YES error: nil];
	
	if (interruptedOnPlayback) {
        
		[appSoundPlayer prepareToPlay];
		[appSoundPlayer play];
		playing = YES;
		interruptedOnPlayback = NO;
	}
}


#pragma mark Application setup____________________________

#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: iPod library access works only when running on a device.
#endif

//- (void) setupApplicationAudio {
//	LogMethod();
//	// Gets the file system path to the sound to play.
//	NSString *soundFilePath = [[NSBundle mainBundle]	pathForResource:	@"sound"
//                                                              ofType:				@"caf"];
//    
//	// Converts the sound's file path to an NSURL object
//	NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
//	self.soundFileURL = newURL;
//    
//	// Registers this class as the delegate of the audio session.
//	[[AVAudioSession sharedInstance] setDelegate: self];
//	
//	// The AmbientSound category allows application audio to mix with Media Player
//	// audio. The category also indicates that application audio should stop playing
//	// if the Ring/Siilent switch is set to "silent" or the screen locks.
//	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
//    /*
//     // Use this code instead to allow the app sound to continue to play when the screen is locked.
//     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
//     
//     UInt32 doSetProperty = 0;
//     AudioSessionSetProperty (
//     kAudioSessionProperty_OverrideCategoryMixWithOthers,
//     sizeof (doSetProperty),
//     &doSetProperty
//     );
//     */
//    
//	// Registers the audio route change listener callback function
//	AudioSessionAddPropertyListener (
//                                     kAudioSessionProperty_AudioRouteChange,
//                                     audioRouteChangeListenerCallback,
//                                     (__bridge void *)(self)
//                                     );
//    
//	// Activates the audio session.
//	
//	NSError *activationError = nil;
//	[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
//    
//	// Instantiates the AVAudioPlayer object, initializing it with the sound
//	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
//	self.appSoundPlayer = newPlayer;
//	
//	// "Preparing to play" attaches to the audio hardware and ensures that playback
//	//		starts quickly when the user taps Play
//	[appSoundPlayer prepareToPlay];
//	[appSoundPlayer setVolume: 1.0];
//	[appSoundPlayer setDelegate: self];
//}


// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications {
      LogMethod(); 
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [notificationCenter addObserver: self
     selector: @selector (handle_iPodLibraryChanged:)
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
     */
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}


// To learn about the Settings bundle and user preferences, see User Defaults Programming Topics
//		for Cocoa and "The Settings Bundle" in iPhone Application Programming Guide

// Returns whether or not to use the iPod music player instead of the application music player.
- (BOOL) useiPodPlayer {
      LogMethod(); 
	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
		return YES;
	} else {
		return NO;
	}
}

// Configure the application.

- (void) viewDidLoad {
      LogMethod();
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[AppDelegate instance].colorSwitcher processImageWithName:@"background.png"]]];

    //not sure, but think this is only needed to play sounds not music
//    [self setupApplicationAudio];
    
    [self setPlayedMusicOnce: NO];
            
        // Instantiate the music player. If you specied the iPod music player in the Settings app,
        //		honor the current state of the built-in iPod app.
    if ([self useiPodPlayer]) {
        
        [self setMusicPlayer: [MPMusicPlayerController iPodMusicPlayer]];
        
    } else {
        
        [self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
        
        // By default, an application music player takes on the shuffle and repeat modes
        //		of the built-in iPod app. Here they are both turned off.
        [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
    }
    if ([musicPlayer nowPlayingItem]) {
        
        // Update the UI to reflect the now-playing item.
        [self handle_NowPlayingItemChanged: nil];
        
        if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
            [playPauseButton setImage: [UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
//            [nowPlayingLabel setText: NSLocalizedString (@"Instructions", @"Brief instructions to user, shown at launch")];

        }
    }
    [self registerForMediaPlayerNotifications];
    
//    self.currentQueue = userMediaItemCollection;
//    
//    NSArray *returnedQueue = [self.currentQueue items];
//    
//    for (MPMediaItem *song in returnedQueue) {
//        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
//        NSLog (@"\t\t%@", songTitle);
//    }
//    
    [musicPlayer setQueueWithItemCollection: userMediaItemCollection];
    [self setPlayedMusicOnce: YES];
    [self playMusic];
    
}

#pragma mark Application state management_____________

- (void) didReceiveMemoryWarning {
       LogMethod();
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self setNowPlayingLabel:nil];
    [self setElapsedTimeLabel:nil];
    [self setProgressSlider:nil];
    [self setRemainingTimeLabel:nil];
    [self setPreviousButton:nil];
    [self setPlayPauseButton:nil];
    [self setNextButton:nil];
    [self setNextSongLabel:nil];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
       LogMethod();
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [[NSNotificationCenter defaultCenter] removeObserver: self
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
     
     */
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
	[musicPlayer endGeneratingPlaybackNotifications];
    
}
#pragma mark Prepare for Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;

	if ([segue.identifier isEqualToString:@"MagnifyRemainingTime"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        timeMagnifierViewController.textToMagnify = self.remainingTimeLabel.text;
        timeMagnifierViewController.timeType = segue.identifier;
	}
    
    if ([segue.identifier isEqualToString:@"MagnifyElapsedTime"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        timeMagnifierViewController.textToMagnify = self.elapsedTimeLabel.text;
        timeMagnifierViewController.timeType = segue.identifier;

	}
    
    if ([segue.identifier isEqualToString:@"MagnifyNowPlaying"])
	{
        TextMagnifierViewController *textMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        textMagnifierViewController.delegate = self;
        textMagnifierViewController.textToMagnify = self.nowPlayingLabel.text;
	}
    
    if ([segue.identifier isEqualToString:@"MagnifyPlaylistRemaining"])
	{
        TimeMagnifierViewController *timeMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        timeMagnifierViewController.delegate = self;
        timeMagnifierViewController.textToMagnify = self.navigationItem.rightBarButtonItem.title;
        timeMagnifierViewController.timeType = segue.identifier;

	}
    
    if ([segue.identifier isEqualToString:@"MagnifyNextSong"])
	{
        TextMagnifierViewController *textMagnifierViewController = [[navigationController viewControllers] objectAtIndex:0];
        textMagnifierViewController.delegate = self;
        textMagnifierViewController.textToMagnify = self.nextSongLabel.text;
	}
    

}
- (IBAction)magnify {

    [self performSegueWithIdentifier: @"MagnifyPlaylistRemaining" sender: self];
}

//#pragma mark - TextMagnifierViewControllerDelegate

- (void)textMagnifierViewControllerDidCancel:(TextMagnifierViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}
//#pragma mark - TextMagnifierViewControllerDelegate

- (void)timeMagnifierViewControllerDidCancel:(TimeMagnifierViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
