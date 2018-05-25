//
//  CustomTableViewCell.h
//  Wag
//
//  Created by Keith on 5/24/18.
//  Copyright © 2018 Keith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *gravatarIV;
@property (weak, nonatomic) IBOutlet UILabel *badgesLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInd;

@end
