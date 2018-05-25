//
//  Item.h
//  Wag
//
//  Created by Keith on 5/24/18.
//  Copyright © 2018 Keith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
@property (nonatomic) NSInteger user_id;
@property (strong, nonatomic) NSString *display_name;
@property (strong, nonatomic) NSString *profile_image;
@property (strong, nonatomic) NSDictionary *badge_counts;
@end
