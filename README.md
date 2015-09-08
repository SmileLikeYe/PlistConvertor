# PlistConvertor
￼Download
Link: http://pan.baidu.com/s/1kTrLWNH
password: 4tcq
Environment
mac os
Function Point 

1.convert
￼1.1 Brief
______________________________________________________________________________ Convert every entity in CoreData file(.xcdatamodeld) to a corresponding plist file(.plist) with the same specific structure.
1.2 Description
______________________________________________________________________________ - Open file extension should be .xcdatamodeld.
- Support drag and drop file to the text felid
- Each entity respectively generates a plist file.
- Plist file is named with [entityname] + .plist.
￼- The plist file structure is organised as:
￼- Sample:
1.3 Use Guide
______________________________________________________________________________ 
- Open or drag .xcdatamodeld.￼
￼- Choose save file path or use the default path: ~/Desktop
- Click ‘Convert’. If it succeeds, click ‘OK’, it will open the save path in finder.

2.Login
2.1 Brief
______________________________________________________________________________ 
Login to spefic url.
2.2 Description
______________________________________________________________________________ 
- Login progress skip ssl.
- When login fail it will show HTTP response statusCode.
2.3 Use Guide
______________________________________________________________________________ 
- Input required message.
- Click ‘Login’.

3.Check
3.￼￼1 Brief
______________________________________________________________________________ 
After login, send the HTTP request to “https://[URL]/B1MobileServer/[Model]$key=[Key]”.And check all PropertyName in plist file whether it is in the backend table field from HTTP response whether .
3.2 Description
______________________________________________________________________________
- In the destination, URL􏰀Model􏰀Key are based on your input. 
- The structure of check plist file must be same as the structure like the output plist in 1.Convert.
- After checking, the first error log display view on the [error.plist] button will display the error
PropertityName to help user find the errors when typing.
- After checking, the second key log display view on the [keys.plist] button will display the keys
from the HTTP response to help user to check.
- When errors are too many to find, you can click [errors.plist] button, it will generate a
(entityname)_errors.plist under the same folder of check file to handle a great number of errors. It may be like this:
- When keys are too many to check, you can click [keys.plist] button, it will generate a
(entityname)_keys.plsit under the same folder of check file to handle a great number of keys. It may be like this:
￼￼
31.3 Use Guide
______________________________________________________________________________ 
- Choose the plist file to check
- Input required message.
- Click ‘Check’ button.
- Through looking at the errors and keys logs to see
- When errors are too many, click”errors.plist” to see errors_log.plist. - When keys are too many, click”keys.plist” to see keys_log.plist.

