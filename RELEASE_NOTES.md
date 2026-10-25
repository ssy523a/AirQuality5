# AirQuality5 v1.0

## Overview

AirQuality5 is a lightweight native macOS application for viewing a 5-day air quality forecast and hourly air quality details. Automatic current location detection (when location access is authorized) and manual city search make it easy to check conditions near you or in another city.

## Features

- 5-day air quality forecast with daily forecast cards
- Current location detection
- Manual city search
- US AQI, PM2.5, and PM10 data
- Separate PM2.5 and PM10 forecast charts
- Color-coded air quality ranges
- Clickable daily cards with an hourly detail view for each forecast day
- Hourly US AQI chart
- Hourly PM2.5 chart
- Hourly PM10 chart
- Interactive Swift Charts with hourly data selection
- Light and Dark Mode support
- Native macOS interface built with SwiftUI

## Data Source

Air quality forecast data is provided by the Open-Meteo Air Quality API.

## Installation

1. Download the DMG file.
2. Open the DMG.
3. Drag AirQuality5.app to the Applications folder.
4. Launch AirQuality5 from Applications.

## Requirements

- macOS 26.5 or later
- Universal: Apple Silicon and Intel Macs
- Internet connection to retrieve forecasts and online city search results
- Location permission to use current location detection

## Security Note

This release was built using a free Apple development account. It is ad-hoc signed, is not signed with a Developer ID Application certificate, and is not notarized. Depending on macOS security policies, additional confirmation may be required when opening the app for the first time.
