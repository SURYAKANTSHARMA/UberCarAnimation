
[![Travis CI](https://travis-ci.org/SURYAKANTSHARMA/UberCarAnimation.svg?branch=master)](https://travis-ci.org/SURYAKANTSHARMA/UberCarAnimation) 
# UberAnimation
This app is for demoing animating the car like uber from one position to another with preserving angle and smooth animation
# Requirements
Xcode 10.1+
Swift 4.2+ 
# Usage 
Replace `ADD_YOUR_GOOGLE_API_KEY` in class `AppDelegate.swift` from your actual google api key from [Here](https://developers.google.com/maps/documentation/ios-sdk/get-api-key)
Once you have your app running in the simulator, select simulate locations in Xcode as follows
![screen shot 2019-02-11 at 6 08 12 pm](https://user-images.githubusercontent.com/6416095/52563640-0d680080-2e28-11e9-9c03-51c3720b3d69.png)

You will see nice moving car with uber like animation like below

Note: We are using the static path string for giving driving road location from A to B. For actual path use Google's direction api [Here](https://console.cloud.google.com/apis/library/directions-backend.googleapis.com?filter=category:maps&id=c6b51d83-d721-458f-a259-fae6b0af35c5&project=ios-task) 



| Light Mode        | Dark Mode  |
|:-----------------:|:---------------------:| 
|<img src= "https://user-images.githubusercontent.com/6416095/52931260-c6bb5e80-3371-11e9-9d46-83f7d1389d18.gif" width="400" height = "865">|<img src= "Resources/darkmode.gif" width="400" height = "865" alt = "Unable to load gif">|

Pause and play

1. Simulate the location on the simulator
2. Press the pause button to pause car animation and play to resume the animation


