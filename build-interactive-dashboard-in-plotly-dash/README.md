### Introduction
- This analysis is based on the [COVID-19 Community Mobility Reports](https://www.google.com/covid19/mobility/index.html?hl=en) created by Google. The reports aim to provide insights into what has changed in response to policies aimed at combating COVID-19. The reports chart movement trends over time by geography, across different categories of places such as retail and recreation, groceries and pharmacies, parks, transit stations, workplaces, and residential.
- In order to run the analysis, make sure you download the [original dataset](https://www.google.com/covid19/mobility/index.html?hl=en) from Google and run all the code chunks in the `data_cleaning.ipynb` to create the cleaned dataframe that only focuses on the trend in the U.S
- In order to find the correlation between COVID cases and the mobility trend, I also combined it with the [COVID-19 dataset](https://github.com/nytimes/covid-19-data) from New York Times. There is also an interesting pattern of how people from different states are responding to the number of confirmed cases and deaths.
- The analysis can be found in the `data_analysis.ipynb` notebook. There is also a [Plotly Dash](https://plot.ly/dash) app built on top that. You can find how to run the app in the README file.
<hr>

### How to run the Dash app
**Step 1:**
You can either create a virtual env to work on this project (**recommended**)
```
 pip install virtualenv
 virtualenv venv
 source venv/bin/activate   # Mac OS/Linux
 .\venv\Scripts\activate    # Windows
 pip install -r requirements.txt
```
or you can install all the dependencies manually by running `pip install -r requirements.txt` 

**Step 2:**
Start the Dash App by running `python index.py`

**Step 3:**
Check the app locally at `http://127.0.0.1:8050/`

<hr>

### How to use this project as a boilerplate to build your own app
Most of the examples on the [Plotly gallery](https://dash-gallery.plotly.host/Portal/) are single page app so that they don't give you a clear picture how should you structure the files when you are building something slightly more complicated, i.e a multiple page app. This is what I would recommend as a flat layout project structure.

    ├── app.py                  # where Dash instance is defined
    ├── index.py                # the entry point for running the app
    ├── layouts.py              # define the layout of each url/page
    ├── callbacks.py            # define should we render the output when input changes
    ├── requirements.txt        # install project dependecies in a virtual environment
    ├── assets/                 # static files
    └── ...

There are three main files that you need to read and understand:
1. `index.py` includes everything related to the main page, i.e how do you want to render each url
2. `layouts.py` where you define the structure of each page. There are three major packages used when building the layout of the app:
    - `dash_html_components` contains all the basic html elements like `<h1>` to `<h6>`, `<div>`, `<p>`... More details can be found on the [documentation](https://dash.plotly.com/dash-html-components) page.
    - `dash-core-components` is a set of interactive components written by the Dash team, i.e dropdown, slider, input, checkboxes... More details can be found on the [documentation](https://dash.plotly.com/dash-core-components) page.
    - `dash_bootstrap_components` connect the [bootstrap](https://getbootstrap.com/) with Dash components so that your app has a modern look.
    -  `layouts.py` file is where you combine different html elements and other interactive components to build the layout of the app. It will look messy if you are building a complicated app. It is better to use a bracket colorizer to help you keep the indexing consistent.
3.  `callbacks.py` where all the interactions happen, i.e how to update the graph when the user changes the value in the dropdown menu.