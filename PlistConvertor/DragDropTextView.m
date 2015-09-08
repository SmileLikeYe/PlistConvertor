//
//  DragDropTextView.m
//  PlistConvertor
//
//  Created by smile on 8/13/15.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import "DragDropTextView.h"

@implementation DragDropTextView



- (void)awakeFromNib
{
    // Register to accept filename drag/drop
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    // Need the delegate hooked up to accept the dragged item(s) into the model
    if ([self delegate]==nil)
    {
        return NSDragOperationNone;
    }
    
    if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType])
    {
        return NSDragOperationCopy;
    }
    NSLog(@"draggingEntered");
    
    return NSDragOperationNone;
}

// Work around a bug from 10.2 onwards
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationEvery;
}

// Stop the NSTableView implementation getting in the way
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    int i;
    NSPasteboard *pboard;
    pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        id delegate = [self delegate];
        NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
        if ([delegate respondsToSelector:@selector(acceptFilenameDrag:)])
        {
            for (i=0;i<[filenames count];i++)
            {
                [delegate performSelector:@selector(acceptFilenameDrag:) withObject:[filenames objectAtIndex:i]];
            }
        }
        return YES;
    }
    return NO;
}

@end
