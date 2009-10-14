/*
 * This file is part of Deblock.
 *
 *  Deblock is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Deblock is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Deblock in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  GraphLayer.h
//  Deblock
//
//  Created by Maarten Billemont on 03/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ScrollLayer.h"


@interface Score : NSObject {

@private
    NSInteger                                   score;
    NSString                                    *username;
    NSDate                                      *date;
}

@property (readonly) NSInteger                  score;
@property (readonly) NSString                   *username;
@property (readonly) NSDate                     *date;

+ (Score *)scoreWithScore:(NSInteger)aScore by:(NSString *)aUsername at:(NSDate *)aDate;

- (id)initWithScore:(NSInteger)aScore by:(NSString *)aUsername at:(NSDate *)aDate;
    
- (NSComparisonResult)compareByTopScore:(Score *)other;
- (NSComparisonResult)compareByRecency:(Score *)other;
- (NSComparisonResult)compareByUsername:(Score *)other;

@end


@interface GraphDataNode : ScrollLayer {
    
    NSArray                                     *sortedScores;
    NSInteger                                   topScore;
    
    NSString                                    *scoreFormat;
    NSDateFormatter                             *dateFormatter;
    
    CGFloat                                     padding, barHeight;
    NSUInteger                                  scoreCount, barCount;
    
    ccTime                                      animationTimeLeft;
    GLuint                                      vertexBuffer;
    Label                                       **scoreLabels;
}

/** The formatter to use when rendering score dates. */
@property (readwrite, retain) NSDateFormatter   *dateFormatter;
/** The format string to render the score data with.
 *
 * The arguments to the format string are in this order: score, username, formatted date. */
@property (readwrite, retain) NSString          *scoreFormat;

/** The amount of pixels of padding to use between the graph border and the graph data. */
@property (readwrite) CGFloat                   padding;
/** The height of the bars in pixels. */
@property (readwrite) CGFloat                   barHeight;

@end


@interface GraphNode : CocosNode {

@private
    NSArray                                     *scores, *sortedScores;
    SEL                                         comparator;
    
    GraphDataNode                               *graphDataNode;
}

/** An array of Score objects. */
@property (readwrite, retain) NSArray           *scores;
/** The method on the Score object that will determine the order of rendered score appearance. */
@property (readwrite) SEL                       comparator;
/** The node that displays the actual graph data. */
@property (readonly) GraphDataNode              *graphDataNode;

/** @param newData  An array of Score objects. */
- (id)initWithArray:(NSArray *)newData;

@end