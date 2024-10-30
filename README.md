
[![Travis CI](https://travis-ci.org/SURYAKANTSHARMA/UberCarAnimation.svg?branch=master)](https://travis-ci.org/SURYAKANTSHARMA/UberCarAnimation) 
# UberAnimation
UberCarAnimation is a delightful and interactive iOS library that provides a smooth and realistic animation of a car moving along a route, inspired by the Uber app's ride tracking feature. This library allows you to easily integrate this dynamic animation into your own iOS app to enhance the user experience.

#   Features
Realistic animation: The library offers a lifelike animation of a car moving along a specified route, complete with smooth transitions and interactive elements.
Customizable appearance: Developers can customize various aspects of the animation, including the car image, route color, and animation speed, to match their app's visual style.
Simple integration: With a few lines of code, you can seamlessly integrate the UberCarAnimation into your iOS app, saving time and effort in development.

- Added Sample project for both UIKit and SwiftUI with Google Maps 
- MapKit with SwiftUI Integration: Demonstrates integrating MapKit directly in SwiftUI, adding annotations and polylines to represent routes dynamically.


# Requirements
- Xcode 16+
- Swift 6+ 
  
# Usage 
**With Google Maps**
Replace `ADD_YOUR_GOOGLE_API_KEY` in class `AppDelegate.swift` from your actual google api key from [Here](https://developers.google.com/maps/documentation/ios-sdk/get-api-key)
Once you have your app running in the simulator, select simulate locations in Xcode as follows
![screen shot 2019-02-11 at 6 08 12 pm](https://user-images.githubusercontent.com/6416095/52563640-0d680080-2e28-11e9-9c03-51c3720b3d69.png)

You will see nice moving car with uber like animation like below

Note: We are using the static path string for giving driving road location from A to B. For actual path use Google's direction api [Here](https://console.cloud.google.com/apis/library/directions-backend.googleapis.com?filter=category:maps&id=c6b51d83-d721-458f-a259-fae6b0af35c5&project=ios-task) 



| Light Mode        | Dark Mode  |
|:-----------------:|:---------------------:| 
|<img src= "https://user-images.githubusercontent.com/6416095/52931260-c6bb5e80-3371-11e9-9d46-83f7d1389d18.gif" width="400" height = "865">|<img src= "Resources/darkmode.gif" width="400" height = "865" alt = "Unable to load gif">|

**With Apple MapKit new swift APIs**
- used MKDirections APIs for Polyline

|<img src= "https://github.com/user-attachments/assets/3110a08a-99e6-4b1d-85bc-607f9bcd6ab8" width="400" height = "865" alt = "Unable to load gif">|


Pause and play

1. Simulate the location on the simulator
2. Press the pause button to pause car animation and play to resume the animation


# Contributing
Contributions to UberCarAnimation are welcome! If you encounter any issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

# License
UberCarAnimation is available under the MIT license. See the LICENSE file for more information.

Stay Connected
Follow [SURYAKANTSHARMA](https://github.com/SURYAKANTSHARMA/) on GitHub for the latest updates and releases.


# Video Tutorial 
[Youtube video](https://www.youtube.com/watch?v=C03cw4SvaQg) on extracting this repo code for own use
