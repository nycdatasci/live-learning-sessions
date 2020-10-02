"""
Building an application with a side bar and multiple urls
Although we can create the app all in one file, for organizational purpose and structure,
We define the layouts and callbacks for each page in different files
"""
from dash import Dash
from dash.dependencies import Input, Output
from layouts import homepage_layout, correlation_layout, sidebar_layout, CONTENT_STYLE
from os import path
from app import app
import dash_core_components as dcc
import dash_html_components as html
import dash_bootstrap_components as dbc
import pandas as pd
import callbacks

# Define the layout of the index page, each layout is defined in the layouts file
app.layout = html.Div([dcc.Location(id="url"), sidebar_layout, 
                        html.Div(id="page-content", style=CONTENT_STYLE)])

# Decide when to show each layout based on the url
@app.callback(Output("page-content", "children"), 
             [Input("url", "pathname")])
def render_page_content(pathname):
    if pathname == '/':
        return homepage_layout
    elif pathname == "/correlation":
        return correlation_layout
    # If the user tries to reach a different page, return a 404 message
    return dbc.Jumbotron(
        [
            html.H1("404: Not found", className="text-danger"),
            html.Hr(),
            html.P(f"The pathname {pathname} was not recognised..."),
        ]
    )

# Save all the parameters of the pages for easy accessing
PAGES = [
    {'children': 'Home', 'href': '/', 'id': 'home'},
    {'children': 'Correlation', 'href': '/correlation', 'id': 'correlation-page'}
]

# this callback uses the current pathname to set the active state of the
# corresponding nav link to true, allowing users to tell see page they are on
@app.callback(
    [Output(page.get('id'), "active") for page in PAGES],
    [Input("url", "pathname")],
)
def toggle_active_links(pathname):
    return [pathname == page.get('href') for page in PAGES]



if __name__ == '__main__':
    app.run_server(debug=True)