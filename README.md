# TextScanTesseract
Applying Tesseract IOS 4.0 with cocoa pods to scan 



## About

This demo projects contains Tesseract IOS cocoa pods available
https://cocoapods.org/pods/TesseractOCRiOS

And Swift Language Compile is set to 3.2 instead of 4.0  at build settings 

User can go to This readMe for configuration settings 
https://github.com/tesseract-ocr/tesseract/blob/master/README.md

I extend this project to do the following : 

1. Capture Text into singleton array
2. Photo Capture while scanning
3. Let user choose the captured text by programmatically generated pickerview


## Known Issues

1. Since iOS 11 is still on update and bug fix, AVCapture Module may change frequently 
2. The deployment target is set to 11.0. In case to lower down , please turn. it down
3. While capturing, the camera Flash lights turn on but the preview image turns blurred for a second and then clear at the captured imageview. 

## Target 
1. Change it to swift 4.0 compatitble and test 
2. Scanned List filtering for differnet types of textfield


