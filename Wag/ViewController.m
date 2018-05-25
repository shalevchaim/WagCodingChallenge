//
//  ViewController.m
//  Wag
//
//  Created by Keith on 5/24/18.
//  Copyright © 2018 Keith. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kFetchJSONDataURL [NSURL URLWithString:@"https://api.stackexchange.com/2.2/users?site=stackoverflow"]

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "Item.h"
#import "AppDelegate.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *itemsArr;
    AppDelegate *appDel;
    NSManagedObjectContext *context;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    itemsArr = [[NSMutableArray alloc] init];
    appDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    context = appDel.persistentContainer.viewContext;
    
    //Load the data from the API endpoint
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:kFetchJSONDataURL];
        [self performSelectorOnMainThread:@selector(fetchData:) withObject:data waitUntilDone:YES];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchData:(NSData *)responseData {
    NSError* error;
    //Check to make sure we have data to parse
    if(responseData == NULL) {
        NSLog(@"We might not have a network connection");
        return;
    }
    
    //parse json data and put into an array of Items
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if(error != nil) {
        NSLog(@"ERROR: %@", error);
        return;
    }
    NSArray* allItems = [json objectForKey:@"items"];
    
    for (NSDictionary *item in allItems) {
        Item *tempItem = [[Item alloc] init];
        for(id key in item) {
            if ([tempItem respondsToSelector:NSSelectorFromString(key)]) {
                [tempItem setValue:[item objectForKey:key] forKey:key];
            }
        }
        
        [itemsArr addObject:tempItem];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return itemsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"customCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLbl.text = [itemsArr[indexPath.row] display_name];
    
    
    [cell.activityInd startAnimating];
    
    NSMutableString *badgeString = [[NSMutableString alloc] init];
    for(id key in [itemsArr[indexPath.row] badge_counts]) {
        [badgeString appendString:[NSString stringWithFormat:@"%@: %@\n", key,[[itemsArr[indexPath.row] badge_counts] objectForKey:key]]];
    }
    NSString * badgeStr = [badgeString substringToIndex:[badgeString length] - 2];
    cell.badgesLbl.text = badgeStr;
    
    cell.tag = indexPath.row;
    
    //Check to see if the image is saved in Core Data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Gravatar"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"profile_src", [itemsArr[indexPath.row] profile_image]]];
    NSArray *tempObjArr = [context executeFetchRequest:request error:nil];
    if(tempObjArr.count > 0) {
        //object saved for offline use
        NSManagedObject *savedObject = [tempObjArr firstObject];
        UIImage *image = [UIImage imageWithData:[savedObject valueForKey:@"profile_img"]];
        cell.gravatarIV.image = image;
        [cell.activityInd stopAnimating];
        [cell.activityInd setHidden:YES];
    } else {
        //Image is not saved in Core Data, so we need to download it.
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[itemsArr[indexPath.row] profile_image]]];
            
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (cell.tag == indexPath.row) {
                        cell.gravatarIV.image = image;
                        [cell.activityInd stopAnimating];
                        [cell.activityInd setHidden:YES];
                        [cell setNeedsLayout];
                        
                        
                        // Create a new managed object
                        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Gravatar" inManagedObjectContext:context];
                        //save both the url AND the NSData object
                        //the url will serve as a key to see if the data has been saved.
                        [newDevice setValue:imageData forKey:@"profile_img"];
                        [newDevice setValue:[itemsArr[indexPath.row] profile_image] forKey:@"profile_src"];
                        
                        NSError *error = nil;
                        // Save the object to persistent store
                        if (![context save:&error]) {
                            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                        }
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                });
            }
            else {
                //The url did not yield an image, keep the default
                NSLog(@"No image returned");
                [cell.activityInd stopAnimating];
                [cell.activityInd setHidden:YES];
            }
        });
    }
    
    return cell;
}


@end
