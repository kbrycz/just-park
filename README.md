# Chicago Street Cleaning App

Welcome to the **Chicago Street Cleaning App** repository! This Swift-based iOS app helps users stay informed about street cleaning schedules across various Chicago neighborhoods, ensuring they avoid parking tickets with ease. The app is designed with a clean and user-friendly interface and is optimized for iPhones and iPads.

---

## Features

- **Comprehensive Coverage**: Access street cleaning schedules for multiple neighborhoods across Chicago.
- **Color-Coded Schedules**: Dates are visually distinguished:
  - **Yellow**: Upcoming within the week.
  - **Red**: Upcoming within 3 days.
  - **Gray**: Scheduled outside of these ranges.
- **Dynamic Map View**: View sections and wards with detailed cleaning schedules on an easy-to-use map.
- **Favorite Neighborhoods**: Toggle and manage neighborhoods to focus on areas that matter to you.
- **Completely Free and Ad-Free**: No distractions—just the features you need.

---

## App Functionality

### Home Screen
The Home Screen introduces the app with a title, subtitle, and logo, followed by two main buttons:
1. **Street Cleaning**: Access detailed cleaning schedules and a map view.
2. **Settings**: Customize your app preferences.

### Map View
- Interactive map displaying wards and their sections.
- Tap a section to view detailed cleaning schedules.
- Schedules are fetched locally from the included `dates.json` file.

### Info Modal
- Provides information about street cleaning dates and their significance.
- Links to official resources for Chicago street cleaning.

---

## Tech Stack

- **SwiftUI**: Used for the user interface, providing a modern, declarative UI framework.
- **MapKit**: For displaying and interacting with geographic data.
- **GeoJSON Integration**: Ward and section boundaries are defined using GeoJSON files.
- **Custom Styling**: Fonts and colors use a design system defined in the project.

---

## Folder Structure

```plaintext
.
├── Assets/
│   ├── GeoJSON/       # GeoJSON files for wards and sections
│   ├── Fonts/         # Custom Quicksand fonts
│   ├── Images/        # App icons and backgrounds
├── Utilities/
│   ├── GeoJSONLoader.swift       # Handles loading and parsing GeoJSON data
│   ├── CleaningDatesFetcher.swift # Fetches cleaning dates from local files
├── Views/
│   ├── HomeView.swift            # Main home screen
│   ├── MapView.swift             # Interactive map view
│   ├── SectionInfoModalView.swift # Displays section cleaning schedules
│   ├── InfoModalView.swift       # Informational modal
│   ├── SplashScreenView.swift    # Splash screen at app launch
├── ViewModels/
│   ├── ListViewModel.swift       # View model for managing sections
│   ├── RefreshTrigger.swift      # Handles app refresh logic
├── Models/
│   ├── Section.swift             # Defines section objects
│   ├── Ward.swift                # Defines ward objects
├── roadoneApp.swift              # Main entry point for the app
