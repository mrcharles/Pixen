//
//  PXBitmapImporter.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXBitmapImporter.h"

const int PXBMPBitcountPosition = 28;
const int PXBMPColorTablePosition = 54;
const int PXBMPColorCountPosition = 46;

@implementation PXBitmapImporter

- (id)init
{
	[NSException raise:@"Invalid initializer" format:@"OSProgressPopup is a singleton; use [PXBitmapImporter sharedBitmapImporter] to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedBitmapImporter
{
	static PXBitmapImporter *sharedBitmapImporter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedBitmapImporter = [[self alloc] _init];
	});
	
	return sharedBitmapImporter;
}

- (BOOL)bmpDataHasColorTable:(NSData *)data
{
	if (!data || [data length] < 28) { return NO; }
	const unsigned char *bitmapData = [data bytes];
	return (bitmapData[PXBMPBitcountPosition] == 8);
}

- (NSArray *)colorsInBMPData:(NSData *)data
{
	if (![self bmpDataHasColorTable:data]) { return nil; }
	const unsigned char *bitmapData = [data bytes];
	
	long colorCount = bitmapData[PXBMPColorCountPosition];
	colorCount += (bitmapData[PXBMPColorCountPosition + 1] * 256);
	colorCount += (bitmapData[PXBMPColorCountPosition + 2] * 256 * 256);
	colorCount += (bitmapData[PXBMPColorCountPosition + 3] * 256 * 256 * 256);
	if (colorCount == 0) { colorCount = 256; }
	
	NSMutableArray *colorArray = [NSMutableArray array];
	int i;
	for (i = 0; i < colorCount; i++)
	{
		int base = PXBMPColorTablePosition + i*4;
		unsigned char red = bitmapData[base + 2];
		unsigned char green = bitmapData[base + 1];
		unsigned char blue = bitmapData[base + 0];
		
		[colorArray addObject:[NSColor colorWithCalibratedRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1]];
	}
	return colorArray;
}

@end
