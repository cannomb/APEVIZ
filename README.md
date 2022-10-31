
# APEVIZ

a suite of data visualization functions I’ve used in causal effect
estimation for program evaluation

## Installation

### create_plot_metadata()

This function is mostly used as a part of the create_love_plot()
function, however I’ve made it available to use on it’s own as well. It
takes in a matchit object (from the MatchIt package) and returns a
tibble that includes a column for each variable in the data used by
MatchIt, a column for the standard mean difference between the treatment
and control group in the unmatched sample, and a column for the standard
mean difference between the treatement and control group in the matched
sample.

``` r
# Load the MatchIt package
library(APEVIZ)
library(MatchIt)
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
    ## ✔ tibble  3.1.8     ✔ dplyr   1.0.9
    ## ✔ tidyr   1.2.1     ✔ stringr 1.4.1
    ## ✔ readr   2.1.3     ✔ forcats 0.5.2
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
# Load the Lalonde Dataset 
data("lalonde", package = "MatchIt")

# Create a MatchIt object using the matchit() function
m.out <- matchit(treat ~ age + educ + race + married + nodegree + re74 + re75,
                 data = lalonde,
                 distance = "mahalanobis",
                 replace = TRUE)

create_plot_metadata(m.out)
```

    ## Joining, by = "covariate"

    ## # A tibble: 9 × 3
    ##   covariate  unmatched_std_mean_diff matched_std_mean_diff
    ##   <chr>                        <dbl>                 <dbl>
    ## 1 age                        -0.309               3.55e- 2
    ## 2 educ                        0.0550             -4.03e- 2
    ## 3 raceblack                   1.76                1.11e-16
    ## 4 racehispan                 -0.350               0       
    ## 5 racewhite                  -1.88                0       
    ## 6 married                    -0.826               2.76e- 2
    ## 7 nodegree                    0.245              -1.11e-16
    ## 8 re74                       -0.721               6.28e- 2
    ## 9 re75                       -0.290               1.38e- 1
