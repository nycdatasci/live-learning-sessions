'''
Define the layouts of each page/url
'''
import dash_core_components as dcc
import dash_bootstrap_components as dbc
import dash_html_components as html
from callbacks import df # import the df loaded from callbacks so we don't need to load it again

# the layout of homepage
homepage_layout = html.Div(
                [
                    dbc.Row(
                        [
                            dbc.Col(dcc.Markdown([
                                "##### Mobility Types\n",
                                "**Grocery & pharmacy**\n",
                                "Mobility trends for places like grocery markets, food warehouses, \
                                    farmers markets, specialty food shops, drug stores, and pharmacies.\n",
                                "**Parks**\n",
                                "Mobility trends for places like local parks, national parks, public beaches,\
                                    marinas, dog parks, plazas, and public gardens.\n",
                                "**Transit stations**\n",
                                "Mobility trends for places like public transport hubs such as subway, bus, and train stations.\n",
                                "**Retail & recreation**\n",
                                "Mobility trends for places like restaurants, cafes, shopping centers, \
                                    theme parks, museums, libraries, and movie theaters.\n",
                                "**Residential**\n", "Mobility trends for places of residence.\n",
                                "**Workplaces**\n", "Mobility trends for places of work."

                            ])),
                            dbc.Col(dcc.Markdown([
                                "##### Correlation Coefficients between Daily Cases and Mobility\n",
                                "It is the number that describes how people reacted to the reported daily cases "\
                                    "in the previous days. It takes values between -1 and 1. A positive value indicates that "\
                                        "as the reported daily cases increased, people's mobility decreased in the following day.\n",
                                "##### Data resources\n",
                                "[Google COVID-19 Community Mobility Reports](https://www.google.com/covid19/mobility/index.html?hl=en)\n",
                                "[John Hopkins Daily Reports](https://github.com/CSSEGISandData/COVID-19)\n",
                                "[New York Times COVID-19 Reports](https://github.com/nytimes/covid-19-data)"
                            ])),
                        ]
                    )
                ]
)

# the style arguments for the sidebar. We use position:fixed and a fixed width
# this allows us to have the sidebar unmoved on the left side of the page
SIDEBAR_STYLE = {
    "position": "fixed",
    "top": 0,
    "left": 0,
    "bottom": 0,
    "width": "16rem",
    "padding": "2rem 1rem",
    "background-color": "#f8f9fa",
}

# save all the parameters of the pages for easy accessing
PAGES = [
    {'children': 'Home', 'href': '/', 'id': 'home'},
    {'children': 'Correlation', 'href': '/correlation', 'id': 'correlation-page'}
]

# the layout of the sidebar
sidebar_layout = html.Div(
    [
        html.Div([
                    dbc.Row([html.H4("NYCDSA"), 
                            html.Img(src=('/assets/logo.jpeg'), width=50,
                                    style={"margin-left": "2rem"})
                            ])
                    ]),
        html.Hr(),
        dbc.Nav(
            [
                dbc.NavLink(**page) for page in PAGES
            ],
            vertical=True,
            pills=True,
        ),
    ],
    style=SIDEBAR_STYLE
)

CARD_KEYS = ['retail', 'grocery', 'parks', 'transit', 'workplaces', 'residential']

# the layout of the correlation page
correlation_layout = html.Div(children=[
        dcc.Dropdown(
            id='state-dropdown',
            options=
                [{"label": state, "value": state} for state in df.state.unique()]
            ,
            value='NY',
            clearable=False,
            style={"width": 100}
        ),
        html.Hr(),
        dbc.Row(
            [
                dbc.Col([], id=key+'_card') for key in CARD_KEYS
            ],
            className="mb-4",
        ),

        html.H3(
            'Daily Confirmed Cases',
            style={'text-align': 'center'}
        ),
        dcc.Graph(
            id='line_chart',
            style={
                'width': '80%',
                'height': '500px',
                'text-align': 'center',
                'margin': 'auto'
            }
        ),
        html.H3(
            'Percentage of Change in Mobility',
            style={'text-align': 'center'}
        ),
        dcc.Graph(
            id='trend_chart',
            style={
                'width': '80%',
                'height': '500px',
                'text-align': 'center',
                'margin': 'auto'
            }
        ),
])

# the styles for the main content position it to the right of the sidebar and
# add some padding.
CONTENT_STYLE = {
    "margin-left": "18rem",
    "margin-right": "2rem",
    "padding": "2rem 1rem",
}