
# Property Listings Map Viewer

![](thumbnail.png)

## Overview
This Shiny application provides an interactive map to visualize property listings. Users can filter properties based on criteria like region, type, action, and more. The app displays detailed information and price trends for each property.

## Data Description
The application uses a CSV file named `houses.csv` containing detailed data about property listings. Key fields in the data include:
- `Item_Name`: Name or title of the property.
- `Price`: Listed price of the property.
- `Size`: Size of the property in square meters.
- `Number_of_Rooms`: Number of rooms in the property.
- `Address`: Address of the property.
- `Seller`: Name of the seller or agency.
- `Tags`: Tags associated with the property (e.g., amenities, features).
- `Image_URL`: URL to an image of the property.
- `Page_Link`: URL to the property's listing page.
- `Status`: Current status of the property (e.g., Available).
- Other fields include geographic coordinates, dates, and normalized property details.

## Features
- Interactive map to display property listings.
- Filters for region, object type, action, price, size, and number of rooms.
- Detailed property information including images and price trends.

## Getting Started

### Prerequisites
- R and RStudio
- Required libraries: shiny, dplyr, ggplot2, leaflet, shinythemes

### Installation
1. Clone the repository or download the R script (`app.R`).
2. Ensure you have the required libraries installed. You can install them using R commands like `install.packages("shiny")`.

### Data Source
- The application requires a CSV file named `houses.csv` with property data.
- Make sure the CSV file is in the same directory as the R script.

### Running the Application
1. Open `app.R` in RStudio.
2. Set the working directory to the directory containing `app.R`.
3. Run the application in RStudio by clicking 'Run App'.

### Restoring Virtual Environment
To restore the virtual environment and ensure the right package versions are used, follow these steps:
1. Make sure you have `renv` installed. If not, install it using `install.packages("renv")`.
2. Use the `renv.lock` file to restore the environment:
   ```R
   renv::restore()
   ```

## Contributing
Feel free to fork the repository and submit pull requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
