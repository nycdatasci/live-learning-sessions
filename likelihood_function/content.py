import numpy as np
import pandas as pd
import plotly

from helpers import binom_likelihood, generate_bi, go

N = 30
X1, y1 = generate_bi(N)


fig_data = go.FigureWidget([
        go.Scatter(x=X1, y=y1, mode='markers', showlegend = False, hoverinfo='none') 
])
scatter = fig_data.data[0]
scatter.marker.color = ["red" if i==1 else "blue" for i in y1]
scatter.marker.size = [6] * N


from helpers import data_generate, gaussian_likelihood

N = 50
sigma = 1 # Using sigma=1 is cheating a little bit... just to avoid confusing the audience with another coefficient
X2, y2 = data_generate(N, sigma)

lin_data = go.FigureWidget([go.Scatter(
    x=X2, y=y2, mode='markers', showlegend = False, hoverinfo='none'
)]).update_layout(autosize=False, width=600, height=480)
