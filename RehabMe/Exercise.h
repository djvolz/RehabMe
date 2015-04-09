//
//  Exercise.m
//  RehabMe
//
//  Created by Dan Volz on 4/9/15 (at the Istanbul airport).
//  Copyright (c) 2015 Dan Volz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <ParseUI/ParseUI.h>

@interface Exercise : NSObject

@property (nonatomic, strong) NSString *name; // name of recipe
@property (nonatomic, strong) NSString *prepTime; // preparation time
@property (nonatomic, strong) PFFile *imageFile; // image of recipe
@property (nonatomic, strong) NSArray *ingredients; // ingredients
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger timeRequired;
@property (nonatomic, copy)   NSString *displayName;
@property (nonatomic, assign) NSString *instructions;
@property (nonatomic)         BOOL enabled;

@end
