//
//  ViewController.m
//  PlistConvertor
//
//  Created by SoSo on 5/29/15.
//  Copyright (c) 2015 SAP. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "XMLDictionary.h"
@interface ViewController ()

@property NSString * openFilePath;
@property NSString * saveFilePath;
@property NSString * checkFilePath;
@property NSMutableDictionary * errorsDic;
@property NSMutableDictionary * keysDic;
@property NSInteger *checkButtonTag;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.openFilePath = @"";
    self.saveFilePath = @"";
    self.checkFilePath = @"";
    _companyDBField.stringValue  = @"SBODEMOUS";
    _usernameField.stringValue = @"manager";
    _passwordField.stringValue = @"1234";
    _urlField.stringValue = @"10.58.114.44:40000";
    _modelField.stringValue = @"Activities";
    _keyField.stringValue = @"2";
    _errorsDic = [[NSMutableDictionary alloc] init];
    _keysDic = [[NSMutableDictionary alloc] init];
    _saveField.stringValue  = @"~/Desktop";
    _checkButtonTag = 0;
    [_errorsTextView setString:@"Error_PropertyNames:"];
    [_keysTextView setString:@"Standard_PropertyName:"];
}

//打开要转换成plist的数据库文件，后缀：xcdatmodeld
- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger ret)
     {
         if (ret == NSFileHandlingPanelOKButton)
         {
             NSString *fileExtension = [panel.URL.path pathExtension];
             if ([@"xcdatamodeld" isEqualToString:fileExtension]) {
                 self.openFilePath =  panel.URL.path;
                 
                 self.openField.stringValue = self.openFilePath;
                 NSLog(@"openFilePath: %@", self.openFilePath);
             }else {
                 //提示文件名后缀不对
                 NSAlert *alert = [[NSAlert alloc] init];
                 alert.messageText = @"File Extention should be .xcdatamodeld ";
                 [alert beginSheetModalForWindow:self.view.window
                               completionHandler:nil];
             }
         }
     }];
}

- (IBAction)saveFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;

    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger ret)
     {
         if (ret == NSFileHandlingPanelOKButton)
         {
             self.saveFilePath =  panel.URL.path;
             
             self.saveField.stringValue = self.saveFilePath;
             NSLog(@"saveFilePath: %@", self.saveFilePath);
         }
     }];
    
}

- (IBAction)chooseCheckFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger ret)
     {
         if (ret == NSFileHandlingPanelOKButton)
         {
             NSString *fileExtension = [panel.URL.path pathExtension];
             if ([@"plist" isEqualToString:fileExtension]) {
                 self.checkFilePath =  panel.URL.path;
                 
                 self.checkField.stringValue = self.checkFilePath;
                 NSLog(@"checkFilePath: %@", self.checkFilePath);
             }else {
                 //提示文件名后缀不对
                 NSAlert *alert = [[NSAlert alloc] init];
                 alert.messageText = @"File Extention should be .plist ";
                 [alert beginSheetModalForWindow:self.view.window
                               completionHandler:nil];
             }
         }
     }];
}

const NSString *kPropertyName       = @"PropertyName";
const NSString *kPropertyType       = @"Type";
const NSString *kPropertyAttributes = @"Attributes";
const NSString *kModelName          = @"ModelName";

- (IBAction)convert:(id)sender
{
    //判断拖拽进来的存储目录是不是文件目录
    BOOL isDir = NO;
    _openFilePath = [self.openField stringValue];
    _saveFilePath = [self.saveField stringValue];
    if ([@"" isEqualToString:_openFilePath]) {
        //提示选择打开文件
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please select oepn file!";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if (![[_openFilePath pathExtension] isEqualToString:@"xcdatamodeld"]) {
        //提示文件名后缀不对
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Open file Extention should be .xcdatamodeld ";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if ([@"" isEqualToString:_saveFilePath]) {
        //提示选择储存目录
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please select save path!";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else {
        NSString *entityName;//表的名字
        NSString *modelName;//前端的attribute和relation名字
        NSString *type;//类型: string -> 0  number -> 1 realtion -> 100
        
        
        //处理打开文件的目录名字：加上[项目名].xcdatamodel/contents
        NSString *fileName = [[_openFilePath lastPathComponent] stringByDeletingPathExtension];
        _openFilePath = [_openFilePath stringByAppendingFormat:@"/%@.xcdatamodel/contents",fileName];
        
        //处理文件目录下的xml文件（这里没有xml后缀也行）
        NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:_openFilePath];
        
        //获得entity 字典数组
        NSArray *entities = [xmlDoc arrayValueForKeyPath:@"entity"];
        //遍历entities
        for (NSInteger i = 0; i < entities.count; i++) {//遍历每个Model
            entityName = [entities[i] valueForKeyPath:@"_name"];
            //---------------这里是调试输出--------------------//
            NSLog(@"---------entityName: %@",entityName);
            //---------------调试输出结束----------------------//
            //获得propertity relationship数组
            NSArray *attributes = [entities[i] arrayValueForKeyPath:@"attribute"];
            NSArray *relationships = [entities[i] arrayValueForKeyPath:@"relationship"];
            
            //定义要转成plist的基本结构：一个array加很多dictionary
            NSMutableArray* mArray = [NSMutableArray array];
            
            //遍历attributes 字典数组
            if (attributes != nil) {
                for (NSInteger i = 0; i < [attributes count]; i++) {
                    //获得属性值
                    modelName = [attributes[i] valueForKeyPath:@"_name"];
                    type = [attributes[i] valueForKeyPath:@"_attributeType"];
                    //---------------这里是调试输出--------------------//
                    NSLog(@"attribute  modlename: %@",modelName);
                    NSLog(@"type: %@", type);
                    //---------------调试输出结束----------------------//
                    //费解没什么一定要放在这里？
                    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
                    
                    //设置modelName
                    [mDict setObject:modelName forKey:kModelName];
                    //设置PropertyAttributes （是定值）
                    [mDict setObject:@"@a@u" forKey:kPropertyAttributes];
                    //设置PropertyName （首字母大写）
                    NSString *b = [NSString stringWithFormat:@"%@%@", [[modelName substringToIndex:1] uppercaseString], [modelName substringFromIndex:1]];
                    [mDict setObject:b forKey:kPropertyName];
                    //设置PropertyType (0 | 1)
                    NSArray *items = @[@"String", @"Integer 16", @"Integer 32", @"Integer 64", @"Decimal", @"Double", @"Float"];
                    NSUInteger item = [items indexOfObject:type];
                    switch (item) {
                        case 0:
                            [mDict setObject:[NSNumber numberWithInt:0] forKey:kPropertyType];
                            break;
                        case 1:
                        case 2:
                        case 3:
                        case 4:
                        case 5:
                        case 6:
                            [mDict setObject:[NSNumber numberWithInt:1] forKey:kPropertyType];
                            break;
                        default:
                            [mDict setObject:[NSNumber numberWithInt:0] forKey:kPropertyType];
                            break;
                    }
                    //添加到array里面
                    [mArray addObject:mDict];
                    NSLog(@"array: %@",mArray);
                }
            }
            //遍历relationship 字典数组
            if (relationships != nil) {
                NSLog(@"relationship: %@", relationships);
                for (NSInteger i = 0; i < [relationships count]; i++) {
                    //获得属性值
                    modelName = [relationships[i] valueForKeyPath:@"_name"];
                    //---------------这里是调试输出--------------------//
                    NSLog(@"relationship modlename: %@",modelName);
                    NSLog(@"type: %@", type);
                    //---------------调试输出结束----------------------//
                    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
                    
                    //设置modelName
                    [mDict setObject:modelName forKey:kModelName];
                    //设置PropertyAttributes （是定值）
                    [mDict setObject:@"@a@u" forKey:kPropertyAttributes];
                    //设置PropertyName （首字母大写）
                    NSString *b = [NSString stringWithFormat:@"%@%@", [[modelName substringToIndex:1] uppercaseString], [modelName substringFromIndex:1]];
                    [mDict setObject:b forKey:kPropertyName];
                    //设置PropertyType  (100)
                    [mDict setObject:[NSNumber numberWithInt:100] forKey:kPropertyType];
                    //添加到array里面
                    [mArray addObject:mDict];
                }
            }
            //生成Plist
            NSURL *storeURL = [NSURL fileURLWithPath:[_saveFilePath  stringByAppendingString:[NSString stringWithFormat:@"/%@.plist",entityName]]];
            [mArray writeToURL:storeURL atomically:YES];
        }
        //提示选择打开文件
        NSAlert *alert = [NSAlert alertWithMessageText: @"Do you want to open finder to see?"
                                         defaultButton: @"OK"
                                       alternateButton: @"Cancel"
                                           otherButton: nil
                             informativeTextWithFormat: @"Genarate plist file successfully!"];
        
        [alert beginSheetModalForWindow: self.view.window completionHandler: ^(NSInteger returnCode){
            if (returnCode==NSAlertDefaultReturn) {//1
                NSLog(@"OK");
                //open finder
                if ([_saveFilePath isEqualToString:@"~/Desktop" ]) {
                    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
                    NSString* theDesktopPath = [paths objectAtIndex:0];
                    NSURL *fileURL = [NSURL fileURLWithPath:theDesktopPath];
                    [[NSWorkspace sharedWorkspace] openURL: fileURL];
                }else {
                    NSURL *fileURL = [NSURL fileURLWithPath:_saveFilePath];
                    [[NSWorkspace sharedWorkspace] openURL: fileURL];
                }
            }
            else if (returnCode==NSAlertAlternateReturn) {//0.
                NSLog(@"Cancel");
            }
        }];
    }
    
}

- (IBAction)clickLogin:(id)sender {
    if ([@"Login" isEqualToString:[_loginButton title]]) {
        //判断输入框
        if ([[_companyDBField stringValue] isEqualToString:@""] ) {
            //提示转换成功
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Please Input CompanyDB!";
            [alert beginSheetModalForWindow:self.view.window
                          completionHandler:nil];
        }else if ([[_usernameField stringValue] isEqualToString:@""]) {
            //提示转换成功
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Please Input Username!";
            [alert beginSheetModalForWindow:self.view.window
                          completionHandler:nil];
        }else if ([[_passwordField stringValue] isEqualToString:@""]) {
            //提示转换成功
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Please Input Password!";
            [alert beginSheetModalForWindow:self.view.window
                          completionHandler:nil];
        }else {
            //设置URL
            NSURL *url = [NSURL URLWithString:@"https://10.58.114.44:40000/B1MobileServer/Login"];
            //设置request
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [request setHTTPMethod:@"POST"];
            //设置post的JOSN的数据
            NSDictionary *dicData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 _companyDBField.stringValue, @"CompanyDB",
                                 _usernameField.stringValue, @"UserName",
                                 _passwordField.stringValue, @"Password",
                                 nil];
            NSError *jsonerror;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicData options:0 error:&jsonerror];
            NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                             encoding:NSUTF8StringEncoding]);
            [request setHTTPBody:jsonData];
            //创建connection
            NSError *error = nil;
            @try {
                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                NSLog(@"error: %@", error);
            }
            @catch (NSException *exception) {
                NSLog(@"Exception : %@ ", exception);
            }
        }
    }else if([@"Logout" isEqualToString:[_loginButton title]]) {
        [_loginButton setTitle:@"Login"];
        [_companyDBField setEditable:true];
        [_usernameField setEditable:true];
        [_passwordField setEditable:true];
        [_resetButton setEnabled:true];
    }
}

- (IBAction)clickReset:(id)sender {
    [_companyDBField setStringValue:@""];
    [_usernameField setStringValue:@""];
    [_passwordField setStringValue:@""];
}

- (IBAction)clickCheck:(id)sender {
    //判断输入框
    if ([[_urlField stringValue] isEqualToString:@""] ) {
        //提示转换成功
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please Input URL!";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if ([[_modelField stringValue] isEqualToString:@""]) {
        //提示转换成功
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please Input Model!";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if ([[_keyField stringValue] isEqualToString:@""]) {
        //提示转换成功
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please Input Key!";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if([@"" isEqualToString:_checkFilePath]) {
        //提示选择打开文件
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Please select check file!";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if(![[_checkFilePath pathExtension] isEqualToString:@"plist"]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Check file extention should be .plist ";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else {
        //设置url以及参数
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/B1MobileServer/%@?$key=%@", _urlField.stringValue, _modelField.stringValue, _keyField.stringValue]];
        //设置request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request setHTTPMethod:@"GET"];
        //收到response
        NSHTTPURLResponse *response;
        NSError *error = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        //判断状态码
        NSInteger statusCode =[response statusCode];
        if ( statusCode == 200) {
            [_loginButton setTitle:@"Logout"];
            [self check:responseData];
        }else {
            //提示错误成功
            if (statusCode == 0) {
                NSAlert *alert = [NSAlert alertWithMessageText: @"Do you want to login?"
                                                 defaultButton: @"Login"
                                               alternateButton: @"Cancel"
                                                   otherButton: nil
                                     informativeTextWithFormat: @"It seems that you didn't login or the Session Id  expired"];
                
                [alert beginSheetModalForWindow: self.view.window completionHandler: ^(NSInteger returnCode){
                    if (returnCode==NSAlertDefaultReturn) {//1
                        NSLog(@"Login Again");
                        //open finder
                        [self clickLogin:(id)sender];
                    }
                    else if (returnCode==NSAlertAlternateReturn) {//0
                        NSLog(@"Cancel");
                    }
                }];

                
            }else {
                NSAlert *alert1 = [[NSAlert alloc] init];
                alert1.messageText = [NSString stringWithFormat: @"Can't get response!\nHTTP StatusCode:%ld", statusCode];
                [alert1 beginSheetModalForWindow:self.view.window
                              completionHandler:nil];
            }
        }
    }

}

- (NSString *) check:(NSData *) responseData {
    _checkButtonTag ++;
    int errorCount = 0;
    [_errorsDic removeAllObjects];
    [_keysDic removeAllObjects];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    [self.errorsTextView setString:@"Error_PropertyNames:\n-------\n"];
    [self.keysTextView setString:@"Response_Standard_Keys:\n-------\n"];
    if (! error) {
        NSLog(@"------%@",jsonDict);
        NSArray *keys = [jsonDict allKeys];
        NSLog(@"%@", keys);
        //遍历返回的标准keys
        for (int j = 0;  j < keys.count;  j++) {
            //write into keysTextView
            NSString *keyMessage =[NSString stringWithFormat:@"[%@]",keys[j]];
            [self.keysTextView setString:[NSString stringWithFormat:@"%@%@\n",[self.keysTextView string],keyMessage]];
            [_keysDic setObject:keys[j] forKey:[NSString stringWithFormat:@"Standard_PropertyName_%d", j+1]];
        }
        NSArray *dicArray = [NSArray arrayWithContentsOfFile:_checkFilePath];
        //遍历本地修改后的plist
        for (int i = 0 ; i < dicArray.count; i++) {
            NSDictionary *dic = dicArray[i];
            NSLog(@"dic:%@",dic);
            NSString *propertyName = [dic valueForKey:@"PropertyName"];
            NSLog(@"%@", propertyName);
            if ([keys containsObject:propertyName]) {
                NSLog(@"%@ is in keys",propertyName);
            }else {
                NSLog(@"%@ is not in keys!!!!",propertyName);
                errorCount ++;
                NSString *errorMessage = [NSString stringWithFormat:@"[%@] check fails!", propertyName];
                //write into errorsTextView
                [self.errorsTextView setString:[NSString stringWithFormat:@"%@%@\n",[self.errorsTextView string],errorMessage]];
                [_errorsDic setObject:propertyName forKey:[NSString stringWithFormat:@"Error_PropertyName_%d",errorCount]];
            }
        }
    }else{
        NSLog(@"%@",error.localizedDescription);
    }
    return @"OK";
}

- (IBAction)clickClearErrors:(id)sender {
    [self.errorsTextView setString:@"Error_PropertyNames:"];
}

- (IBAction)clickErrorLog:(id)sender {
    //judge _checkFilePath is null;
    if (_checkButtonTag == 0) {
        //提示
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        alert.messageText = @"Please check first!";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if ([@"" isEqualToString:_checkFilePath]) {
        //提示选择打开文件
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        alert.messageText = @"Please select check file!";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
        

    }else if(![[_checkFilePath pathExtension] isEqualToString:@"plist"]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Check file extention should be .plist ";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else {
        //get checkFilePath
        NSString * saveLogDir = [_checkFilePath stringByDeletingPathExtension];
        NSLog(@"[clickLog]:_checkFilePath: %@", saveLogDir);
        NSString *saveLogPath = [NSString stringWithFormat:@"%@_CheckError.plist", saveLogDir];
        if ( [_errorsDic writeToFile:saveLogPath atomically:true] ) {
            
            //提示选择打开文件
            NSAlert *alert = [NSAlert alertWithMessageText: @"Do you want to open finder to correct?"
                                             defaultButton: @"OK"
                                           alternateButton: @"Cancel"
                                               otherButton: nil
                                 informativeTextWithFormat: @"Genarate Checkerror.plist: %@",saveLogPath];
            
            [alert beginSheetModalForWindow: self.view.window completionHandler: ^(NSInteger returnCode){
                if (returnCode==NSAlertDefaultReturn) {//1
                    NSLog(@"OK");
                    //open finder
                    NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", saveLogPath]];
                    NSURL *folderURL = [fileURL URLByDeletingLastPathComponent];
                    [[NSWorkspace sharedWorkspace] openURL: folderURL];
                }
                else if (returnCode==NSAlertAlternateReturn) {//0
                    NSLog(@"Cancel");
                }
            }];
        }
    }
}

- (IBAction)clickClearKeys:(id)sender {
    [self.keysTextView setString:@"Response_Standard_Keys:"];
}

- (IBAction)clickKeyLog:(id)sender {
    //judge _checkFilePath is null;
    if (_checkButtonTag == 0) {
        //提示
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        alert.messageText = @"Please check first!";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else if ([@"" isEqualToString:_checkFilePath]) {
        //提示选择打开文件
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        alert.messageText = @"Please select check file!";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
        
    }else if(![[_checkFilePath pathExtension] isEqualToString:@"plist"]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Check file extention should be .plist ";
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:nil];
    }else {
        //get checkFilePath
        NSString * saveLogDir = [_checkFilePath stringByDeletingPathExtension];
        NSLog(@"[clickLog]:_checkFilePath: %@", _checkFilePath);
        NSString *saveLogPath = [NSString stringWithFormat:@"%@_StandardKeys.plist", saveLogDir];
        if ( [_keysDic writeToFile:saveLogPath atomically:true] ) {
            
            //提示选择打开文件
            NSAlert *alert = [NSAlert alertWithMessageText: @"Do you want to open finder to correct?"
                                             defaultButton: @"OK"
                                           alternateButton: @"Cancel"
                                               otherButton: nil
                                 informativeTextWithFormat: @"Genarate StandardKeys.plist: %@",saveLogPath];
            
            [alert beginSheetModalForWindow: self.view.window completionHandler: ^(NSInteger returnCode){
                if (returnCode==NSAlertDefaultReturn) {//1
                    NSLog(@"OK");
                    //open finder
                    NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", saveLogPath]];
                    NSURL *folderURL = [fileURL URLByDeletingLastPathComponent];
                    [[NSWorkspace sharedWorkspace] openURL: folderURL];
                }
                else if (returnCode==NSAlertAlternateReturn) {//0
                    NSLog(@"Cancel");
                }
            }];
            
        }
    }
    
}

//处理NSHTTP请求的函数
//connection 建立时调用的函数 因为self:delegate过了
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSLog(@"[canAuthenticateAgainstProtectionSpace]: Method is called.");
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"[didReceiveAuthenticationChallenge]: Method is called.");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSLog(@"[didReceiveResponse]: get the whole response: %@", response);
    //nshttpurl 是 nsurl
    if([response isKindOfClass:[NSHTTPURLResponse class]]) {
        //判断状态码
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger statusCode =[httpResponse statusCode];
        if ( statusCode == 200) {
            [_loginButton setTitle:@"Logout"];
            [_resetButton setEnabled:false];
            //提示建立session成功
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Login Successfully!";
            [_companyDBField setEditable:false];
            [_usernameField setEditable:false];
            [_passwordField setEditable:false];
            [alert beginSheetModalForWindow:self.view.window
                          completionHandler:nil];
        }else {
            //提示错误成功
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat: @"Login Fail!\nStatus Code:%ld", statusCode];
            [alert beginSheetModalForWindow:self.view.window
                          completionHandler:nil];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"[didReceiveData]: get some data: %@", data);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    NSLog(@"[connectionDidFinishLoading]: connectionDidFinishLoading");
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"[didFailWithError]: Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

@end
