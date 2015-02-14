//
//  CSVParser.h
//  SAO
//
//  Created by Sean Fitzgerald on 5/17/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSVParser;

@protocol CSVParserDelegate <NSObject>

@required

//the parser has loaded the table and is ready to parse
-(void)parserLoaded:(CSVParser *) parser;

//the parser is finished reading the table
//returns a dictionary (of NSArray columns) if there are headers, an array (of NSArray rows) if there are not
-(void)parserDidFinishParsingFile:(CSVParser *)parser withTable:(id)table;

//returns a dictionary if there are headers, an array if there are not
-(void)parserDidFinishRow:(CSVParser *)parser withObject:(id)row;

@optional

//parser read and recognized a value of a table and column
-(void)parser:(CSVParser *)parser
DidParseString:(NSString *) string
withRowNumber:(int)rowNumber
withColumNumber:(int)columnNumber;

//the parse is finished loading the file and ready to start parsing
-(void)parserDidStartParsingFile:(CSVParser *)parser;

//parser recognized a csv file and tells the delegate how many rows and columns
-(void)parser:(CSVParser *)parser
DidReadTableWithTotalRows:(int)numberOfRows
andTotalColumns:(int)numberOfColumns;

@end

@interface CSVParser : NSObject

//the delegate of the parser
@property (nonatomic, weak) id<CSVParserDelegate> delegate;
@property BOOL isParsing;
@property BOOL hasHeaders;

//loads a CSV file into memory
-(void)loadCSVFileWithResourceName:(NSString *)filename;
-(void)loadCSVTableWithString:(NSString *)tableString;
-(void)loadCSVFileWithFilePath:(NSString *)path;
-(void)loadCSVFileFromURL:(NSURL *)url;

//start the parsing or parse in separate queue (specified or not;
-(void)parse;
-(void)parseInQueue:(dispatch_queue_t) queue;
-(void)parseInBackground;

//pause the parsing
-(void)pause;

//rewind the document so that another call of parse will start at the beginning
-(void)rewind;

@end
