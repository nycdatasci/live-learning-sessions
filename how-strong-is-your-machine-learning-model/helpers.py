import numpy as np
from scipy.stats import norm, binom
import plotly.graph_objects as go


def data_generate(N, sigma, b0 = 1.008, b1 = 2.005, seed=2):
    np.random.seed(seed)
    X = np.sort(np.random.uniform(3, size=N))
    noise = np.random.normal(scale=sigma, size=N)
    y = b0 + b1* X + noise
    
    return X, y



def add_curve(points, slope, intercept, sigma, fig):
#     if len(f.data) > 2:
#         new_data = [f.data[i] for i in  range(len(f.data) - 1)]
#     else:
#         new_data = list(f.data)

#     f.data = tuple(new_data)
    base_color = "rgba(.3,.3,.0,0.2)"


    x_ = points.xs[0]
    y_ = points.ys[0]

    y_hat_ = slope*x_ + intercept
    z = np.linspace(-3*sigma, 3*sigma, 100)
    P = x_ + norm.pdf(z)
    trace_pdf = go.Scatter(
        x=P, y=z + y_hat_, mode="lines", line=go.scatter.Line(color='#bae2be'), showlegend=False, hoverinfo='skip')
    trace_base = go.Scatter(
        x=[x_]*len(z), y=z + y_hat_, mode="lines", line=go.scatter.Line(color=base_color), showlegend=False, hoverinfo='skip')
    
    hovertemplate_center = "The max pdf: %{text}<extra></extra>"
    trace_center = go.Scatter(
        x= np.linspace(x_, x_+norm.pdf(0), 20), y= [y_hat_]*20, text=np.round([norm.pdf(0)]*20, 4),
        mode="lines", line=go.scatter.Line(color=base_color), showlegend=False, hovertemplate = hovertemplate_center)
    
    hovertemplate_observation = "The pdf: %{text}<extra></extra>"
    p_obs=norm.pdf(y_ - y_hat_)
    trace_observation = go.Scatter(
        x=np.linspace(x_, x_+p_obs, 20), y= [y_]*20, text=np.round([p_obs]*20, 4),
        mode="lines", line=go.scatter.Line(color="red"), showlegend=False, 
        hovertemplate = hovertemplate_observation)
    fig.add_traces([trace_base, trace_pdf, trace_center, trace_observation])
    
    
    
def base_plot(X, y, slope, intercept):
    N = len(X)
    f = go.FigureWidget([go.Scatter(x=X, y=y, mode='markers', showlegend = False, hoverinfo='none')])
    
    y_hat = slope * X + intercept
    residual = y - y_hat

    scatter = f.data[0]
    colors = ["rgba(.0,.0,.6,0.5)"] * N
    scatter.marker.color = colors
    scatter.marker.size = [8] * N
    f.layout.hovermode = 'closest'

    trace_line = go.Scatter(
        x=X, y=y_hat, mode="lines", line=go.scatter.Line(color="gray"), showlegend=False
    )
    f.add_trace(trace_line)
    return f, scatter    


def get_str(ary):
    return ["{0:.2f}".format(i) for i in ary]
    
def add_bar(points, slope, intercept, fig):
    res = 20
    x_ = points.xs[0]
    y_ = points.ys[0]
    
    logodds = (intercept + slope*x_)
    p = np.exp(logodds)/(1 + np.exp(logodds))
    
    if y_==1:
        hovertemplate = "The probability of being positive: %{text}%<extra></extra>"
        trace_p = go.Scatter(
            x=[x_]*res, y=np.linspace(0, p, res), mode="lines", 
            text=  get_str(np.round([p]*res, 4)*100),
            line=go.scatter.Line(color='red'), showlegend=False, hovertemplate=hovertemplate)
        trace_n = go.Scatter(
            x=[x_]*res, y=np.linspace(p, 1, res), mode="lines", 
            line=go.scatter.Line(color='rgba(0,0,255,0.3)'), showlegend=False, hoverinfo='none')
    else:
        hovertemplate = "The probability of being negative: %{text}%<extra></extra>"
        trace_p = go.Scatter(
            x=[x_]*res, y=np.linspace(p, 1, res), mode="lines",
            text=  get_str(np.round([1-p]*res, 4)*100),
            line=go.scatter.Line(color='blue'), showlegend=False, hovertemplate=hovertemplate)
        trace_n = go.Scatter(
            x=[x_]*res, y=np.linspace(0, p, res), mode="lines", 
            line=go.scatter.Line(color="rgba(255,0,0,0.3)"), showlegend=False, hoverinfo='none')
    
    fig.add_traces([trace_p, trace_n])

    
def generate_bi(N, b1 = 3, b0 = 0, seed=0):
    np.random.seed(seed)
    X = np.linspace(-2, 2, N)
    
    logodds = (b0 + b1*X)
    p = np.exp(logodds)/(1 + np.exp(logodds))
    y = binom.rvs(1, p)   
    
    return X, y

    
def bi_plot(X, y, slope, intercept):
    N = len(X)
    logodds = (intercept + slope*X)
    p = np.exp(logodds)/(1 + np.exp(logodds))
    f = go.FigureWidget([
        go.Scatter(x=X, y=y, mode='markers', showlegend = False, hoverinfo='none'), 
        go.Scatter(
            x=X, y=p, mode='lines', line=go.scatter.Line(color="rgba(10,10,10,0.3)"), showlegend = False, hoverinfo='none')
    ])
    scatter = f.data[0]
    scatter.marker.color = ["red" if i==1 else "blue" for i in y]
    scatter.marker.size = [6] * N
    
    return f, scatter


def binom_likelihood(X, y, slope, intercept, seed=0):
    def show_binom(trace, points, selector):
        s = list(scatter.marker.size)
        for i in points.point_inds:
            s[i] = 15
            with fig.batch_update():
                scatter.marker.size = s

        add_bar(points, slope, intercept, fig)

    fig, scatter = bi_plot(X, y, slope, intercept)
    scatter.on_click(show_binom)
    
    return fig, scatter


def gaussian_likelihood(slope, intercept, X, y, sigma):
    def show_norm(trace, points, selector):
        c = list(scatter.marker.color)
        s = list(scatter.marker.size)
        for i in points.point_inds:
            c[i] = 'red'
            s[i] = 15
            with fig.batch_update():
                scatter.marker.color = c
                scatter.marker.size = s

        add_curve(points, slope, intercept, sigma, fig)
    
    fig, scatter = base_plot(X, y, slope, intercept)
    scatter.on_click(show_norm)
    fig.update_layout(autosize=False, width=900, height=720)
    
    return fig, scatter






