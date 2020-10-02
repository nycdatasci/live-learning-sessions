'''
Define all the callbacks on each page
'''

from dash.dependencies import Input, Output
from app import app
import plotly.express as px
import dash_bootstrap_components as dbc
import dash_html_components as html
import pandas as pd

# Read the picked data frame from the project folder
df = pd.read_pickle("app.data")

CARD_KEYS = ['retail', 'grocery', 'parks', 'transit', 'workplaces', 'residential']

@app.callback(
    [Output('line_chart', 'figure'),
     Output('trend_chart', 'figure')],
    [Input('state-dropdown', 'value')])
def display_line_chart(value):
    state_df = df.loc[df.state==value].copy()
    state_df['new_cases'] = state_df['cases'].diff()
    state_df['new_deaths'] = state_df['deaths'].diff()
    return px.line(state_df, x='date', y='new_cases'), \
           px.scatter(state_df, x="date", y=["retail", "grocery", \
               "parks", "transit", "workplaces", "residential"])

@app.callback(
    [Output(key +'_card', 'children') for key in CARD_KEYS],
    [Input('state-dropdown', 'value')])
def update_card_value(value):
    state_df = df.loc[df.state==value].copy()
    state_df['new_cases'] = state_df['cases'].diff()
    state_df['new_deaths'] = state_df['deaths'].diff()
    correlations = state_df.corr().loc[:'residential', 'new_cases']
    return [dbc.Card(dbc.CardBody(
        [
            html.H5(key.title(), className="card-title"),
            html.P("Correlation: " + str(correlations[key]), className="card-text",
            ),
        ]
    ), color="danger" if correlations[key] < 0 else "success") for key in CARD_KEYS]

