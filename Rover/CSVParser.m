//
//  CSVParser.m
//  SAO
//
//  Created by Sean Fitzgerald on 5/17/13.
//  Copyright (c) 2013 Sean T Fitzgerald. All rights reserved.
//

#import "CSVParser.h"

@interface CSVParser () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSArray * lines;
@property BOOL continueParsing;
@property int lineNumber;
@property int columnNumber;
@property BOOL parserReady;

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSURLConnection * connection;
@property (nonatomic, strong) NSMutableData * receivedData;
@property (nonatomic, strong) NSMutableArray* currentRow;
@property (nonatomic, strong) NSMutableArray* currentTable;
@property (nonatomic, strong) NSMutableArray* headers;

@end

@implementation CSVParser

#pragma mark -
#pragma mark Public methods

//loads a CSV file into memory
-(void)loadCSVFileWithResourceName:(NSString *)filename;
{
	NSString* pathT = [[NSBundle mainBundle] pathForResource:filename
                                                      ofType:@"csv"];
	NSString* contentT = [NSString stringWithContentsOfFile:pathT
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
	self.lines = [contentT componentsSeparatedByString:@"\r"];
	self.lineNumber = 0;
	[self.delegate parserLoaded:self];
}

-(void)loadCSVTableWithString:(NSString *)tableString
{
	self.lines = [tableString componentsSeparatedByString:@"\r"];
	self.lineNumber = 0;
	[self.delegate parserLoaded:self];
}

-(void)loadCSVFileWithFilePath:(NSString *)path
{
	NSError* error;
	self.lines = [[NSString stringWithContentsOfFile:path
                                        usedEncoding:NSUTF8StringEncoding //apparently, the non-warning way is depracated, so ignore this warning until Apple fixes it.
                                               error:&error] componentsSeparatedByString:@"\r"];
	self.lineNumber = 0;
	[self.delegate parserLoaded:self];
}

-(void)loadCSVFileFromURL:(NSURL *)url
{
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	self.connection = [[NSURLConnection alloc] initWithRequest:requestObj delegate:self];
	NSLog(@"request sent");
	self.receivedData = [[NSMutableData alloc] init];
}

/******************************************/
//STARTING CONNECTION STUFF//

//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//{
//	NSLog(@"got authorization challenge");
//	
//	if ([challenge previousFailureCount] == 0) {
//		
//		[[challenge sender] useCredential:[NSURLCredential credentialWithUser:self.username
//																																 password:self.password persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
//		
//	} else {
//		[[challenge sender] cancelAuthenticationChallenge:challenge];
//		[[[UIAlertView alloc] initWithTitle:@"Invalid Username/Password"
//																message:@"Please try again."
//															 delegate:nil
//											cancelButtonTitle:@"OK"
//											otherButtonTitles: nil] show];
//	}
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
	NSLog(@"received response via nsurlconnection");
}

- ( void )connectionDidFinishLoading: (NSURLConnection *)connection
{
	NSLog(@"loadedData: %@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
	NSString * loadedFile = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
	
	self.lines = [loadedFile componentsSeparatedByString:@"\r"];
	self.lineNumber = 0;
	[self.delegate parserLoaded:self];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", [error description]);
}

- ( void )connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
	// receivedData is an NSMutableData object
	[self.receivedData appendData: data ];
}

//DONE WITH CONNECTION STUFF//
/******************************************/

//start the parsing or parse in separate queue;
-(void)parse
{
    self.currentTable = [[NSMutableArray alloc] init];
    self.currentRow = [[NSMutableArray alloc] init];
    if (self.hasHeaders) {
        self.headers = [[NSMutableArray alloc] init];
    }
	self.isParsing = YES;
	self.continueParsing = YES;
	if ([self.delegate respondsToSelector:@selector(parserDidStartParsingFile:)]) {
		[self.delegate parserDidStartParsingFile:self];
	}
	
	NSMutableString * currentValue = [[NSMutableString alloc] init];
	for (; self.lineNumber < [self.lines count]; self.lineNumber++)
	{
		//finds the string at the specific line number
		NSString * line = (NSString *)self.lines[self.lineNumber];
		
		BOOL inQuotes = NO;
		BOOL quoteLastRun = NO;
		
		for (int i = 0; i < [line length] && self.continueParsing; i++)
		{
            if (self.lineNumber > 0 && i == 0) {
                continue;
            }
			//get the current character
			char currentCharacter = [line characterAtIndex:i];
			
			//look for special characters
			
			if (currentCharacter == '"')
			{//4 options: it is starting a literal, it is ending a literal, it is the first in a double, it is the second in a double
				if (inQuotes)
				{//3 options: it is ending a literal, it is first in a double, or it is second in a double
					if (quoteLastRun)
					{//it is second in a double - append the quotation mark
						[currentValue appendFormat:@"%c", currentCharacter];
						quoteLastRun = NO;
					} else //it is first in a double or it is ending a literal - do nothing, but remember it...
					{
						quoteLastRun = YES;
					}
				} else
				{//1 option: it is starting a literal
					inQuotes = YES;
				}
			} else
			{
				//2 options: inside quotes, outside quotes
				if (inQuotes)
				{ //in quotes
					if (quoteLastRun)
					{// those last quotes were ending the literal, so proceed as if you weren't in quotes
						inQuotes = NO;
						if (currentCharacter == ',')
						{
							/********************** NEW VALUE **********************/
                            [self newValue:[currentValue copy] withRowNumber:self.lineNumber withColumnNumber:self.columnNumber];
							currentValue = [[NSMutableString alloc] init];
							self.columnNumber++;
						}//splitting values
						else [currentValue appendFormat:@"%c", currentCharacter];//literal character
						
					} else [currentValue appendFormat:@"%c", currentCharacter];//literal character
				}
				else
				{//not in quotes
					if (currentCharacter == ',')
					{
						/********************** NEW VALUE **********************/
                        [self newValue:[currentValue copy] withRowNumber:self.lineNumber withColumnNumber:self.columnNumber];
						currentValue = [[NSMutableString alloc] init];
						self.columnNumber++;
					}//splitting values
					else [currentValue appendFormat:@"%c", currentCharacter];//literal character
				}
			}
		}
		if (!self.continueParsing)
		{
			return;
		}
		/********************** NEW VALUE **********************/
        [self newValue:[currentValue copy] withRowNumber:self.lineNumber withColumnNumber:self.columnNumber];
		currentValue = [[NSMutableString alloc] init];
		self.columnNumber = 0;
        if (self.hasHeaders) {
            NSMutableDictionary *rowDict = [[NSMutableDictionary alloc] init];
            NSInteger index = 0;
            for (NSString *header in self.headers) {
                [rowDict setObject:[self.currentRow[index] copy] forKey:header];
                index++;
            }
            [self.delegate parserDidFinishRow:self withObject:[rowDict copy]];
        } else {
            [self.delegate parserDidFinishRow:self withObject:[self.currentRow copy]];
        }
        [self.currentTable addObject:[self.currentRow copy]];
        [self.currentRow removeAllObjects];
	}
    if (self.hasHeaders) {
        NSMutableDictionary *tableDict = [[NSMutableDictionary alloc] init];
        NSInteger index = 0;
        for (NSString *header in self.headers) {
            NSMutableArray * rowArray = [[NSMutableArray alloc] init];
            for (NSArray *row in self.currentTable) {
                [rowArray addObject:row[index]];
            }
            [tableDict setObject:[rowArray copy] forKey:header];
            index++;
        }
        [self.delegate parserDidFinishParsingFile:self withTable:[tableDict copy]];
    } else {
        [self.delegate parserDidFinishParsingFile:self withTable:[self.currentTable copy]];
    }
	self.isParsing = NO;
}

-(void)parseInQueue:(dispatch_queue_t) queue
{
	dispatch_async(queue, ^{
		[self parse];
	});
}

-(void)parseInBackground
{
	[self parseInQueue:dispatch_queue_create("parsing queue", NULL)];
}

//pause the parsing
-(void)pause
{
	self.continueParsing = NO;
}

//rewind the document so that another call of parse will start at the beginning
-(void)rewind
{
	self.continueParsing = NO;
	self.columnNumber = self.lineNumber = 0;
}

#pragma mark -
#pragma mark Private methods

-(void)newValue:(NSString*)data
  withRowNumber:(NSInteger)row
withColumnNumber:(NSInteger)col
{
    if ([self.delegate respondsToSelector:@selector(parser:DidParseString:withRowNumber:withColumNumber:)]){
        [self.delegate parser:self
               DidParseString:data
                withRowNumber:row
              withColumNumber:col];
    }
    if (self.hasHeaders) {
        if (row == 0) {
            [self.headers addObject:data];
        } else {
            [self.currentRow addObject:data];
        }
    } else {
        [self.currentRow addObject:data];
    }
}
@end
