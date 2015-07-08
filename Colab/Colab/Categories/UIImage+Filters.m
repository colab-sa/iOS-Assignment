//
//  UIImage+Filters.m
//  Colab
//
//  Created by Andre Bohlsen on 7/7/15.
//  Copyright (c) 2015 Andre Morgante Bohlsen. All rights reserved.
//

#import "UIImage+Filters.h"

@implementation UIImage (Filters)

- (UIImage *)grayedImage {
    CIImage *initialImage = [[CIImage alloc]initWithImage:self];
    
    CIFilter *grayFilter = [CIFilter filterWithName:@"CIColorControls"];
    [grayFilter setValue:@(0) forKey:@"inputSaturation"];
    [grayFilter setValue:initialImage forKey:@"inputImage"];
    CIImage *outputCIImage = [grayFilter outputImage];
    CIContext * context = [CIContext contextWithOptions:nil];
    CGImageRef outputCGImage = [context createCGImage:outputCIImage fromRect:[outputCIImage extent]];
    UIImage * outputImage = [UIImage imageWithCGImage:outputCGImage];
    CGImageRelease(outputCGImage);
    
    return outputImage;
}

@end
