//
//  CollectionViewController.m
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015 August. All rights reserved.
//

#import "TagCollectionViewController.h"

// Data management
#import "DataManagement.h"

// Collection view
#import "ProfileHeaderView.h"
#import "ActivityIndicatorFooterView.h"
#import "MediaCell.h"
#import "PrivateCell.h"

// Networking
#import "InstagramClient.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "InstafollowersClient.h"

#import "MediaViewController.h"

#import "AppDelegate.h"

// Collection cell constants
NSString *ProfileMediaCellIdentifier5 = @"ProfileMediaCellIdentifier1";
NSString *PrivateCellIdentifier5      = @"PrivateCellIdentifier1";
NSString *HeaderIdentifier5           = @"HeaderIdentifier1";
NSString *FooterIdentifier5           = @"FooterIdentifier1";

@interface TagCollectionViewController ()

// User
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) InstagramUser *user;

// Media items arrays for the users items
// that are returned from Instagram API
@property (strong, nonatomic) NSMutableArray *mediaItems;

// Next max identifier is used to paginate
// through the users media items
@property (strong, nonatomic) NSString *nextMaxIdentifier;

// BOOL values used to decide when to
// make requests and when to not
@property (nonatomic) BOOL requestsDone;
@property (nonatomic) BOOL requestsLoading;

//// Collection view header property
//@property (strong, nonatomic) ProfileHeaderView *headerView;

// Relationship for follow button and relationship label
@property (nonatomic) Relationship outgoingRelationship;
@property (nonatomic) Relationship incomingRelationship;

// BOOL private value
@property (nonatomic) BOOL private;


@end

@implementation TagCollectionViewController
{
    BOOL isRunning;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.m_tagName;
    
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    self.collectionView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    /////lgilgilgi
//    [self refresh];
    
    InstagramUser *user = [[DataManagement sharedClient] user];
    self.user = user;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    // Set collection view properties
    self.collectionView.delegate   = self;
    self.collectionView.dataSource = self;
    
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumInteritemSpacing:0.0];
    [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setMinimumLineSpacing:0.0];
    
    // Register collection views
    [self.collectionView registerClass:[ProfileHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:HeaderIdentifier5];
    [self.collectionView registerClass:[ActivityIndicatorFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:FooterIdentifier5];
    [self.collectionView registerClass:[MediaCell class]
            forCellWithReuseIdentifier:ProfileMediaCellIdentifier5];
    [self.collectionView registerClass:[PrivateCell class]
            forCellWithReuseIdentifier:PrivateCellIdentifier5];
    
    [self.view addSubview:self.collectionView];
    
    // Ensure the header view has been intialized by reloading the collection view
    [self.collectionView reloadData];
    
    // Initialize media items object and load media
    self.mediaItems = [[NSMutableArray alloc] init];
    
    [self loadMedia];
}

- (void)refresh
{
    ///lgilgilgi
    [self loadMedia];
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessageArrivedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = self.m_tagName;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data management

- (void)loadMedia
{
    // If all requests are done or a request
    // is currently loading, return
    if(self.requestsDone || self.requestsLoading)
        return;
    
    // Set requests loading to yes
    self.requestsLoading = YES;
    
    [[InstagramClient sharedClient] getTagForName:self.m_tagName
                                                maxIdentifier:self.nextMaxIdentifier
                                                   completion:^(BOOL success, NSArray *mediaItems, NSString *nextMaxIdentifier)
     {
         if(success) {
             
             // Add media items to media
             // items array
             
             ////lgilgilgi
             [self.mediaItems removeAllObjects];
             //////

             [self.mediaItems addObjectsFromArray:mediaItems];
             
             // If there is no next max identifier
             // mark requests as done
             if(nextMaxIdentifier.length == 0) {
                 // Set the requests as done
                 self.requestsDone = YES;
             } else {
                 // Set next max identifier
                 self.nextMaxIdentifier = nextMaxIdentifier;
             }
             
             // Mark requests no longer loading
             self.requestsLoading = NO;
             
         } else {
             
             // Mark request failure
             self.requestsDone = YES;
             
             // Mark requests no longer loading
             self.requestsLoading = NO;
             [self.collectionView reloadData];
             
         }
         
     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If there has been a previous failure, do not attempt load
    if(self.requestsDone || self.requestsLoading)
        return;
    
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Request load if within 5 table view cell heights
    if ((maximumOffset - currentOffset) <= TableViewCellInset * 5.0) {
        [self loadMedia];
    }
}


#pragma mark - BOOL setters

- (void)setRequestsLoading:(BOOL)requestsLoading
{
    _requestsLoading = requestsLoading;
    
    [self.collectionView reloadData];
}

-(NSString *)segmentTitle
{
    return @"Feed";
}

-(void)requestingRefresh
{
    [self refresh];
}

-(void)requestingLoadMedia
{
    [self loadMedia];
}

-(UIScrollView *)streachScrollView
{
    return self.collectionView;
}

#pragma mark - Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.private == NO) {
        ////lgilgilgi
        return self.mediaItems.count;
//        return 20;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.private == NO) {
        MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ProfileMediaCellIdentifier5 forIndexPath:indexPath];
        
//        // Media setup
        InstagramMedia *media = self.mediaItems[indexPath.row];
        
        // Media image
        //[cell.imageView setImageWithURL:media.thumbnailURL placeholderImage:[UIImage new]];
        [cell.imageView sd_setImageWithURL:media.thumbnailURL placeholderImage:[UIImage new]];
        
        /////lgilgilgi
//        [cell.imageView setImage:[UIImage imageNamed:@"listdownload.jpg"]];
        return cell;
    } else {
        PrivateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PrivateCellIdentifier5 forIndexPath:indexPath];
        
        return cell;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize collectionViewHeaderSize = CGSizeMake(0, 0);
    return collectionViewHeaderSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat height;
    
    if(self.requestsLoading) {
        height = 100.0;
    } else {
        height = 0.0;
    }
    
    return CGSizeMake(self.view.bounds.size.width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.private == NO) {
        CGSize boundsSize = self.view.bounds.size;
        
        CGFloat itemSizeWidthHeight = floorf(boundsSize.width/3.0);
        
        return CGSizeMake(itemSizeWidthHeight, itemSizeWidthHeight);
    } else {
        return CGSizeMake(self.view.bounds.size.width, 180.0);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.private == YES) {
        return;
    }
    
    // Media
    InstagramMedia *media = self.mediaItems[indexPath.row];
    
    // View Controller
    MediaViewController *viewController = [[MediaViewController alloc] initWithMediaIdentifier:media.identifier
                                                                ];
    
    // Push View Controller
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
