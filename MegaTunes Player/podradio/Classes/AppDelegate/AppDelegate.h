//
//  AppDelegate.h
//  podradio
//
//  Created by Tope on 28/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorSwitcher.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) ColorSwitcher *colorSwitcher;

+ (AppDelegate*)instance;

- (void)customizeGlobalTheme;

-(void)iPadInit;

@end