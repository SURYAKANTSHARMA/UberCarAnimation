
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/SURYAKANTSHARMA/UberCarAnimation/swift.yml?branch=master)](https://github.com/SURYAKANTSHARMA/UberCarAnimation/actions)
[![Codecov](https://img.shields.io/codecov/c/github/SURYAKANTSHARMA/UberCarAnimation?token=YOUR_CODECOV_TOKEN_PLACEHOLDER)](https://codecov.io/gh/SURYAKANTSHARMA/UberCarAnimation)
[![Travis CI](https://travis-ci.org/SURYAKANTSHARMA/UberCarAnimation.svg?branch=master)](https://travis-ci.org/SURYAKANTSHARMA/UberCarAnimation) 

# UberCarAnimation Project

UberCarAnimation is a delightful and interactive set of iOS projects demonstrating smooth and realistic car animations along routes. It includes examples for both UIKit and SwiftUI, using Google Maps and Apple MapKit.

## Features

*   **Realistic Animation:** Lifelike animation of a car moving along a specified route, with smooth transitions.
*   **Customizable Appearance:** (Primarily in UIKit Google Maps example) Developers can customize aspects like the car image, route color, and animation speed.
*   **Multiple Examples:**
    *   **UberCarAnimation (UIKit with Google Maps):** The original example demonstrating car animation with Google Maps in a UIKit environment.
    *   **SwiftUIExample/UberCarSwiftUI (SwiftUI with Google Maps):** A SwiftUI wrapper around the Google Maps SDK, showcasing car animation.
    *   **CarAnimationMapKitSwiftui (SwiftUI with Apple MapKit):** A pure SwiftUI implementation using Apple's MapKit for car animation.
*   **Unit Tests:** Each project includes unit tests for key components like ViewModels, Location Publishers, and Animators.

## Requirements

*   **Xcode:** 15.3 or later (recommended)
*   **Swift:** 5.9 or later (recommended)
*   **iOS:**
    *   UIKit (Google Maps): iOS 13.0 or later (due to GoogleMaps SDK dependencies and modern practices)
    *   SwiftUI (Google Maps): iOS 14.0 or later (SwiftUI lifecycle and GoogleMaps wrapper)
    *   SwiftUI (MapKit): iOS 15.0 or later (for newer MapKit SwiftUI features if used, otherwise iOS 14)
*   **Google Maps API Key:** Required for projects using Google Maps.
*   **CocoaPods:** Required for dependency management in projects using Google Maps. Run `pod install` in the respective project directories (`UberCarAnimation` and `SwiftUIExample/UberCarSwiftUI`).

## Usage

### General Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SURYAKANTSHARMA/UberCarAnimation.git
    cd UberCarAnimation
    ```
2.  **Install Dependencies:**
    *   For `UberCarAnimation` (UIKit with Google Maps):
        ```bash
        cd UberCarAnimation
        pod install
        cd .. 
        ```
    *   For `SwiftUIExample/UberCarSwiftUI` (SwiftUI with Google Maps):
        ```bash
        cd SwiftUIExample/UberCarSwiftUI
        pod install
        cd ../..
        ```

### Project-Specific Instructions

#### 1. UberCarAnimation (UIKit with Google Maps)

*   **API Key Setup:**
    1.  Create a file named `keys.swift` inside the `UberCarAnimation/UberCarAnimation/` directory (alongside `AppDelegate.swift`).
    2.  Add your Google Maps API key to this file:
        ```swift
        // UberCarAnimation/UberCarAnimation/keys.swift
        import Foundation

        let googleMapsAPIKey = "YOUR_ACTUAL_GOOGLE_MAPS_API_KEY" 
        ```
        (Replace `"YOUR_ACTUAL_GOOGLE_MAPS_API_KEY"` with your real key.)
    3.  The `AppDelegate.swift` is already refactored to use `googleMapsAPIKey` from this file.
*   **Running:** Open `UberCarAnimation.xcworkspace` in Xcode and run the `UberCarAnimation` scheme.
*   **Location Simulation:** Once running in the simulator, select "Features" > "Location" > (e.g., "Freeway Drive") in the Simulator's menu bar to simulate movement.

#### 2. SwiftUIExample/UberCarSwiftUI (SwiftUI with Google Maps)

*   **API Key Setup:**
    1.  Create a file named `keys.swift` inside the `SwiftUIExample/UberCarSwiftUI/UberCarSwiftUI/` directory (alongside `UberCarSwiftUIApp.swift`).
    2.  Add your Google Maps API key to this file:
        ```swift
        // SwiftUIExample/UberCarSwiftUI/UberCarSwiftUI/keys.swift
        import Foundation

        let googleMapsAPIKey = "YOUR_ACTUAL_GOOGLE_MAPS_API_KEY"
        ```
        (Replace `"YOUR_ACTUAL_GOOGLE_MAPS_API_KEY"` with your real key.)
    3.  The `UberCarSwiftUIApp.swift` is already refactored to use `googleMapsAPIKey` from this file during its initialization.
*   **Running:** Open `SwiftUIExample/UberCarSwiftUI/UberCarSwiftUI.xcworkspace` in Xcode and run the `UberCarSwiftUI` scheme.
*   **Location Simulation:** Similar to the UIKit example, use the Simulator's location features.

#### 3. CarAnimationMapKitSwiftui (SwiftUI with Apple MapKit)

*   **API Key Setup:** No API key is required for Apple MapKit.
*   **Running:** Open `CarAnimationMapKitSwiftui/CarAnimationMapKitSwiftui.xcodeproj` in Xcode and run the `CarAnimationMapKitSwiftui` scheme.
*   **Location Simulation:** Use the Simulator's location features. The app uses hardcoded coordinates for drawing a route for demonstration.

### General Notes for Google Maps Projects

*   **Static Path:** The Google Maps examples use a static encoded path string for drawing the route. For real-world applications, you would use the Google Directions API to get actual routes. See links in the original README below or Google's documentation.
*   **Map Style:** Dark and Light mode map styles (`mapStyle1.json`, `mapStyle2.json`) are included in the `Resources` folder of the respective Google Maps projects.

### Demo GIFs

**UberCarAnimation (UIKit - Google Maps):**

| Light Mode                                                                                                                         | Dark Mode                                                                                                                   |
| :--------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://user-images.githubusercontent.com/6416095/52931260-c6bb5e80-3371-11e9-9d46-83f7d1389d18.gif" width="300"> | <img src="Resources/darkmode.gif" width="300" alt="Dark mode demo">                                                       |

**CarAnimationMapKitSwiftui (SwiftUI - Apple MapKit):**

| Demo                                                                                                                                 |
| :-----------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/user-attachments/assets/3110a08a-99e6-4b1d-85bc-607f9bcd6ab8" width="300" alt="MapKit SwiftUI Demo"> |

### Features in Action

*   **Pause and Play:** For projects that include play/pause buttons:
    1.  Simulate location updates in the simulator.
    2.  Press the pause button to pause the car animation.
    3.  Press the play button to resume the animation.

## Running Unit Tests

Each project within this repository now includes unit tests for its core components. To run these tests:

1.  **Open the Project in Xcode:**
    *   For `UberCarAnimation`: Open `UberCarAnimation.xcworkspace`.
    *   For `CarAnimationMapKitSwiftui`: Open `CarAnimationMapKitSwiftui/CarAnimationMapKitSwiftui.xcodeproj`.
    *   For `SwiftUIExample/UberCarSwiftUI`: Open `SwiftUIExample/UberCarSwiftUI/UberCarSwiftUI.xcworkspace`.
2.  **Select a Target Device:** Choose a simulator (e.g., iPhone 15 Pro) or a connected physical device from the scheme selector at the top of the Xcode window.
3.  **Run Tests:**
    *   From the Xcode menu: Select "Product" > "Test".
    *   Keyboard Shortcut: Press Command-U (⌘U).
4.  **View Test Results:** The Test Navigator (Command-6, ⌘6) will show the progress and results of the tests.

For advanced users, tests can also be executed using the `xcodebuild` command-line tool. For example (from the directory containing the `.xcworkspace` or `.xcodeproj`):
```bash
# Example for a workspace
xcodebuild test -workspace YourProject.xcworkspace -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest'

# Example for a project
xcodebuild test -project YourProject.xcodeproj -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest'
```
Replace `YourProject.xcworkspace`, `YourProject.xcodeproj`, and `YourScheme` with the actual names.

## Contributing

Contributions are welcome! If you encounter any issues or have ideas for improvements, please open an issue or submit a pull request on GitHub.

## License

This collection of projects is available under the MIT license. See the `LICENSE` file for more information.

## Stay Connected

Follow [SURYAKANTSHARMA](https://github.com/SURYAKANTSHARMA/) on GitHub for the latest updates and releases.

## Original Video Tutorial (for UIKit version)

A [YouTube video](https://www.youtube.com/watch?v=C03cw4SvaQg) by the original author demonstrates extracting code from the UIKit version for personal use. Note that the codebase has been significantly refactored since this video.
