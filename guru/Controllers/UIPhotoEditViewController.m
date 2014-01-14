//
//  UIPhotoEditViewController.m
//  UIPhotoPickerController
//  https://github.com/dzenbot/UIPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "UIPhotoEditViewController.h"
#import "UIPhotoDescription.h"

#import "UIImageView+WebCache.h"

#define kInnerEdgeInset 15.0

static CGFloat _lastZoomScale;

typedef NS_ENUM(NSInteger, UIPhotoAspect) {
    UIPhotoAspectUnknown,
    UIPhotoAspectSquare,
    UIPhotoAspectVerticalRectangle,
    UIPhotoAspectHorizontalRectangle
};


@interface UIPhotoEditViewController () <UIScrollViewDelegate>

/* The photo description data object. */
@property (nonatomic, weak) UIPhotoDescription *photoDescription;
@property (nonatomic, strong) UIImage *editingImage;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation UIPhotoEditViewController
@synthesize photoDescription = _photoDescription;
@synthesize cropMode = _cropMode;
@synthesize cropSize = _cropSize;

- (instancetype)initWithPhotoDescription:(UIPhotoDescription *)description cropMode:(UIPhotoEditViewControllerCropMode)mode;
{
    self = [super init];
    if (self) {
        _photoDescription = description;
        _cropMode = mode;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image cropMode:(UIPhotoEditViewControllerCropMode)mode
{
    self = [super init];
    if (self) {
        _editingImage = [image copy];
        _cropMode = mode;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.bottomView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:[self overlayMask]];
    [self.view insertSubview:maskImageView aboveSubview:_scrollView];
    
    if (!_imageView.image) {
        
        __weak UIButton *_button = _acceptButton;
        _button.enabled = NO;
        
        __weak UIPhotoEditViewController *_self = self;
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.center = CGPointMake(roundf(_bottomView.frame.size.width/2), roundf(_bottomView.frame.size.height/2));
        [activityIndicatorView startAnimating];
        [_bottomView addSubview:activityIndicatorView];
        
        [_imageView setImageWithURL:_photoDescription.fullURL placeholderImage:nil
                            options:SDWebImageCacheMemoryOnly|SDWebImageProgressiveDownload|SDWebImageRetryFailed
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              if (!error) _button.enabled = YES;
                              [activityIndicatorView removeFromSuperview];
                              
                              [_self updateScrollViewContentInset];
                          }];
    }
    else {
        [self updateScrollViewContentInset];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Getter methods

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = _editingImage;
        
        [_scrollView addSubview:_imageView];
        [_scrollView setZoomScale:_scrollView.minimumZoomScale];
    }
    return _scrollView;
}

- (UIView *)bottomView
{
    if (!_bottomView)
    {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-72.0, self.view.bounds.size.width, 72.0)];
        
        _cancelButton = [self buttonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [_cancelButton addTarget:self action:@selector(cancelEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_cancelButton];
        
        _acceptButton = [self buttonWithTitle:NSLocalizedString(@"Choose", nil)];
        [_acceptButton addTarget:self action:@selector(acceptEdition:) forControlEvents:UIControlEventTouchUpInside];
        [_acceptButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        [_bottomView addSubview:_acceptButton];
        
        CGRect rect = _cancelButton.frame;
        rect.origin = CGPointMake(13.0, roundf(_bottomView.frame.size.height/2-_cancelButton.frame.size.height/2));
        [_cancelButton setFrame:rect];
        
        rect = _acceptButton.frame;
        rect.origin = CGPointMake(roundf(_bottomView.frame.size.width-_acceptButton.frame.size.width-13.0), roundf(_bottomView.frame.size.height/2-_acceptButton.frame.size.height/2));
        [_acceptButton setFrame:rect];
        
        
        if (_cropMode == UIPhotoEditViewControllerCropModeCircular) {
            
            UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            topLabel.text = NSLocalizedString(@"Move and Scale", nil);
            topLabel.textColor = [UIColor whiteColor];
            topLabel.font = [UIFont systemFontOfSize:18.0];
            [topLabel sizeToFit];
            
            rect = topLabel.frame;
            rect.origin = CGPointMake(self.view.bounds.size.width/2-rect.size.width/2, 64.0);
            topLabel.frame = rect;
            [self.view addSubview:topLabel];
        }
    }
    return _bottomView;
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 0)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [button sizeToFit];
    return button;
}

- (CGSize)cropSize
{
    CGSize viewSize = self.view.bounds.size;
    
    switch (_cropMode) {
        case UIPhotoEditViewControllerCropModeCustom:
            if (CGSizeEqualToSize(_cropSize, CGSizeZero) ) {
                return CGSizeMake(viewSize.width, viewSize.width);
            }
            else {
                if (viewSize.height > 0 && _cropSize.height > viewSize.height) {
                    _cropSize.height = viewSize.height;
                }
                return _cropSize;
            }
            
        case UIPhotoEditViewControllerCropModeSquare:
        case UIPhotoEditViewControllerCropModeCircular:
        default:
            return CGSizeMake(viewSize.width, viewSize.width);
    }
}

- (CGRect)cropRect
{
    CGSize viewSize = self.navigationController.view.bounds.size;
    CGSize cropSize = [self cropSize];
    CGFloat verticalMargin = (viewSize.height-cropSize.height)/2;
    return CGRectMake(0.0, verticalMargin, cropSize.width, cropSize.height);
}

- (CGFloat)circularDiameter
{
    CGSize viewSize = self.navigationController.view.bounds.size;
    return viewSize.width-(kInnerEdgeInset*2);
}

- (CGSize)imageSize
{
    return CGSizeAspectFit(_imageView.image.size,_imageView.frame.size);
}

CGSize CGSizeAspectFit(CGSize aspectRatio, CGSize boundingSize)
{
    NSLog(@"aspectRatio : %@", NSStringFromCGSize(aspectRatio));
    NSLog(@"boundingSize : %@", NSStringFromCGSize(boundingSize));
    
    float hRatio = boundingSize.width / aspectRatio.width;
    float vRation = boundingSize.height / aspectRatio.height;
    if (hRatio < vRation) {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    }
    else if (vRation < hRatio) {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    }
    return boundingSize;
}

UIPhotoAspect photoAspectFromSize(CGSize aspectRatio)
{
    if (aspectRatio.width > aspectRatio.height) {
        return UIPhotoAspectHorizontalRectangle;
    }
    else if (aspectRatio.width < aspectRatio.height) {
        return UIPhotoAspectVerticalRectangle;
    }
    else if (aspectRatio.width == aspectRatio.height) {
        return UIPhotoAspectSquare;
    }
    else {
        return UIPhotoAspectUnknown;
    }
}

- (UIImage *)overlayMask
{
    switch (_cropMode) {
        case UIPhotoEditViewControllerCropModeSquare:
        case UIPhotoEditViewControllerCropModeCustom:
            return [self squareOverlayMask];
        case UIPhotoEditViewControllerCropModeCircular:
        {
            UIImage *circular = [self circularOverlayMask];
            NSLog(@"circular.size : %@", NSStringFromCGSize(circular.size));
            
            return circular;
        }
        default:
            return nil;
    }
}

/*
 * Created with PaintCode.
 */
- (UIImage *)squareOverlayMask
{
    // Constants
    CGSize size = self.navigationController.view.bounds.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat margin = (height-[self cropSize].height)/2;
    CGFloat lineWidth = 1.0;
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIColor *strokeColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    // Create the bezier path & drawing
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(width, margin)];
    [maskPath addLineToPoint:CGPointMake(0, margin)];
    [maskPath addLineToPoint:CGPointMake(0, 0)];
    [maskPath addLineToPoint:CGPointMake(width, 0)];
    [maskPath addLineToPoint:CGPointMake(width, margin)];
    [maskPath closePath];
    [maskPath moveToPoint:CGPointMake(width, height)];
    [maskPath addLineToPoint:CGPointMake(0, height)];
    [maskPath addLineToPoint:CGPointMake(0, [self cropSize].height+margin)];
    [maskPath addLineToPoint:CGPointMake(width, [self cropSize].height+margin)];
    [maskPath addLineToPoint:CGPointMake(width, height)];
    [maskPath closePath];
    [fillColor setFill];
    [maskPath fill];
    
    // Add the square crop
    CGRect cropRect = CGRectMake(lineWidth/2, margin+lineWidth/2, width-lineWidth, [self cropSize].height-lineWidth);
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:cropRect];
    [strokeColor setStroke];
    cropPath.lineWidth = lineWidth;
    [cropPath stroke];
    
    //Create the image using the current context.
    UIImage *_maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _maskedImage;
}

/*
 * Created with PaintCode.
 * Base PaintCode file available inside of Resource folder.
 */
- (UIImage *)circularOverlayMask
{
    // Constants
    CGRect rect = self.navigationController.view.bounds;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CGFloat diameter = width-(kInnerEdgeInset*2);
    CGFloat radius = diameter/2;
    CGPoint center = CGPointMake(width/2, height/2);
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    // Create the bezier path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:rect];
    
    // Add the circular crop
    [maskPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:NO];
    [maskPath addClip];
    [fillColor setFill];
    [maskPath fill];

    UIImage *_maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return _maskedImage;
}

/*
 * The edited photo is generated by generating an image from the current image context definition.
 */
- (UIImage *)editedPhoto
{
    UIImage *_image = nil;
    
    // Constant sizes
    CGSize viewSize = self.navigationController.view.bounds.size;
    CGRect cropRect = [self cropRect];

    CGFloat verticalMargin = (viewSize.height-cropRect.size.height)/2;

    cropRect.origin.x = -_scrollView.contentOffset.x;
    cropRect.origin.y = -_scrollView.contentOffset.y - verticalMargin;

    UIGraphicsBeginImageContextWithOptions(cropRect.size, NO, 0);{
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, cropRect.origin.x, cropRect.origin.y);
        [_scrollView.layer renderInContext:context];
        
        _image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    if (_cropMode == UIPhotoEditViewControllerCropModeCircular) {
        
        CGFloat diameter = [self circularDiameter];
        CGRect roundedRect = CGRectMake(0, 0, diameter, diameter);
        
        UIGraphicsBeginImageContextWithOptions(roundedRect.size, NO, 0.0);{
            
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:roundedRect];
            [bezierPath addClip];
            
            // Draw the image
            [_image drawInRect:CGRectMake(0, -kInnerEdgeInset, 320, 320)];
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGPathRef path = [bezierPath CGPath];
            CGContextAddPath(context, path);
            
            _image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }

    return _image;
}


#pragma mark - Setter methods

/*
 * Crop size setter
 * Instead of asigning the same CGSize value, we first calculate a proportional height
 * based on the maximum width of the container (ie: for iPhone, 320px).
 */
- (void)setCropSize:(CGSize)cropSize
{
    CGSize viewSize = self.view.bounds.size;
    CGFloat cropHeight = roundf((cropSize.height * viewSize.width) / cropSize.width);
    _cropSize = CGSizeMake(cropSize.width, cropHeight);
}


#pragma mark - UIPhotoEditViewController methods

/*
 * It is important to update the scroll view content inset, specilally after zooming.
 * This allows the user to move the image around with control, from edge to edge of the overlay masks.
 */
- (void)updateScrollViewContentInset
{
    CGFloat maskHeight = 0;
    
    if (_cropMode == UIPhotoEditViewControllerCropModeCircular) maskHeight = [self circularDiameter];
    else maskHeight = [self cropSize].height;
    
    CGSize imageSize = [self imageSize];
    
    CGFloat hInset = (_cropMode == UIPhotoEditViewControllerCropModeCircular) ? kInnerEdgeInset : 0.0;
    CGFloat vInset = fabs((maskHeight-imageSize.height)/2);
    
    NSLog(@"hInset : %f", hInset);
    NSLog(@"vInset : %f", vInset);

//    if (UIEdgeInsetsEqualToEdgeInsets(_scrollView.contentInset, UIEdgeInsetsZero)) {
//        vInset = fabs((maskHeight-imageSize.height)/2);
//    }
//    else {
//        vInset = _scrollView.contentInset.top;
//    }
//    
//    CGFloat zoomDelta = (_scrollView.zoomScale-_lastZoomScale)*10;
//
//    switch (photoAspectFromSize(imageSize)) {
//        case UIPhotoAspectSquare:
//            break;
//            
//        case UIPhotoAspectHorizontalRectangle:
//            break;
//            
//        case UIPhotoAspectVerticalRectangle:
//            break;
//            
//        default:
//            break;
//    }
    
    if (vInset == 0) vInset = 0.5;
    
    _scrollView.contentInset =  UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
}

- (void)acceptEdition:(id)sender
{
    UIImage *editedPhoto = [self editedPhoto];
    CGRect cropRect = [self cropRect];
    
    if (editedPhoto && !CGRectEqualToRect(cropRect, CGRectZero)) {
        
        [UIPhotoEditViewController didFinishPickingEditedImage:editedPhoto
                                                  withCropRect:cropRect
                                             fromOriginalImage:_imageView.image
                                                  referenceURL:_photoDescription.fullURL
                                                    authorName:_photoDescription.authorName
                                                    sourceName:_photoDescription.sourceName];
    }
}

- (void)cancelEdition:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

+ (void)didFinishPickingEditedImage:(UIImage *)editedImage
                       withCropRect:(CGRect)cropRect
                  fromOriginalImage:(UIImage *)originalImage
                       referenceURL:(NSURL *)referenceURL
                         authorName:(NSString *)authorName
                         sourceName:(NSString *)sourceName
{
    static NSString *UIPhotoPickerControllerAuthorCredits = @"UIPhotoPickerControllerAuthorCredits";
    static NSString *UIPhotoPickerControllerSourceName = @"UIPhotoPickerControllerAuthorCredits";
    static NSString *kUIPhotoPickerDidFinishPickingNotification = @"kUIPhotoPickerDidFinishPickingNotification";

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [NSValue valueWithCGRect:cropRect],UIImagePickerControllerCropRect,
                                     @"public.image",UIImagePickerControllerMediaType,
                                     nil];
    
    if (editedImage != nil) [userInfo setObject:editedImage forKey:UIImagePickerControllerEditedImage];
    if (originalImage != nil) [userInfo setObject:originalImage forKey:UIImagePickerControllerOriginalImage];
    if (referenceURL != nil) [userInfo setObject:referenceURL.absoluteString forKey:UIImagePickerControllerReferenceURL];
    if (authorName != nil) [userInfo setObject:authorName forKey:UIPhotoPickerControllerAuthorCredits];
    if (sourceName != nil) [userInfo setObject:sourceName forKey:UIPhotoPickerControllerSourceName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUIPhotoPickerDidFinishPickingNotification object:nil userInfo:userInfo];
}


#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    _lastZoomScale = _scrollView.zoomScale;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //[self updateScrollViewContentInset];
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    _imageView.image = nil;
    _imageView = nil;
    _scrollView = nil;
}


#pragma mark - View Auto-Rotation

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
