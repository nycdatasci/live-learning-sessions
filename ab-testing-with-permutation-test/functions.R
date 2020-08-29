#
# Helper functions for "A/B Testing with Permutation Test"
#
# This script contains the following 4 functions:
# - ab_test_results_df : creates dataframe with all A/B test results
# - one_ab_permutation : performs one A/B permutation
# - n_ab_permutations  : performs multiple A/B permutations
# - ab_permutation_test: main function, performs A/B Permutation Test
#
# Documentation notes are provided inside the definition of each function
# 


ab_test_results_df = function(a_all, b_all, a_yes, b_yes) {
  
  # Function documentation
  #
  # Purpose: Create and return a dataframe with all A/B test results metrics
  #
  # Input (parameters):
  # - a_all: Total number of subjects in group A
  # - b_all: Total number of subjects in group B
  # - a_yes: Number of successes (1, Yes) in group A
  # - b_yes: Number of successes (1, Yes) in group B
  #
  # Output (result): a dataframe with all A/B test results metrics
  
  df = data.frame(
    "all" = c(a_all, b_all, a_all + b_all, a_all - b_all),
    "yes" = c(a_yes, b_yes, a_yes + b_yes, a_yes - b_yes),
    row.names = c("a", "b", "a+b", "a-b")
  )
  
  df["no"] = df["all"] - df["yes"]
  
  df["yes_pct"] = 100 * df["yes"] / df["all"]
  
  df["a-b", "yes_pct"] = df["a", "yes_pct"] - df["b", "yes_pct"]
  
  return(df)
}


one_ab_permutation = function(n_yes, n_no, n_a, verbose=FALSE, max_print=20) {
  
  # Function documentation
  #
  # Purpose: Perform one A/B permutation and return the corresponding test 
  #          statistic result
  #
  # Input (parameters):
  # - n_yes: Total (A + B) number of successes (1, Yes)
  # - n_no : Total (A + B) number of failures  (0, No)
  # - n_a  : Number of subjects in group A
  #
  # Output (result): Test statistic result of the permutation
  
  # Maximum indexes to print (if verbose)
  if (verbose) {
    m = min(c(max_print, n_yes + n_no))
    ma = min(c(max_print, n_a))
    mb = min(c(max_print, n_yes + n_no - n_a))
  }
  
  # Step 1: Combine all results in a bag
  bag = c(rep(1, n_yes), rep(0, n_no))
  if (verbose) cat('(1) Bag before shuffle:', bag[1:m], '\n')
  
  # Step 2: Shuffle the bag
  bag = sample(bag)
  if (verbose) cat('(2) Bag after  shuffle:', bag[1:m], '\n')
  
  # Step 3: Draw a random sample of size A
  all_ind = seq(1, n_yes + n_no)
  a_ind = sample(all_ind, n_a)
  a_rs = bag[a_ind]
  if (verbose) cat('(3) A resample:', a_rs[1:ma], '\n')
  
  # Step 4: Draw a random sample of size B (the remainder)
  b_ind = setdiff(all_ind, a_ind)
  b_rs = bag[b_ind]
  if (verbose) cat('(4) B resample:', b_rs[1:mb], '\n')
  
  # Step 5: Record the difference (in the proportion of 1s)
  a_yes_pct = 100 * sum(a_rs) / length(a_rs)
  b_yes_pct = 100 * sum(b_rs) / length(b_rs)
  ab_yes_pct_diff = a_yes_pct - b_yes_pct
  if (verbose) {
    cat('(5) Resample Conversion Rate (%) \n',
        '    A:', a_yes_pct, '\n', 
        '    B:', b_yes_pct, '\n',
        '  A-B:', ab_yes_pct_diff, '\n')
  }
  
  return(ab_yes_pct_diff)
}


n_ab_permutations = function(n_yes, n_no, n_a, n_p, verbose=FALSE, max_print=100) {
  
  # Function documentation
  #
  # Purpose: Perform multiple A/B permutations and return the corresponding test
  #          statistic results
  #
  # Input (parameters):
  # - n_yes: Total (A + B) number of successes (1, Yes)
  # - n_no : Total (A + B) number of failures  (0, No)
  # - n_a  : Number of subjects in group A
  # - n_p  : Number of permutations
  #
  # Output (result): vector with test statistic results of the permutations
  
  perm_res = rep(0, n_p) # vector for permutation results
  
  # Step 1: Combine all results in a bag
  bag = c(rep(1, n_yes), rep(0, n_no))
  
  # Step 6: Repeat steps 2 to 5 a "large" number of times (n_p)
  for (i in 1:n_p) {
    # Step 2: Shuffle the bag
    bag = sample(bag)
    
    # Step 3: Draw a random sample of size A
    all_ind = seq(1, n_yes + n_no)
    a_ind = sample(all_ind, n_a)
    a_rs = bag[a_ind]
    
    # Step 4: Draw a random sample of size B (the remainder)
    b_ind = setdiff(all_ind, a_ind)
    b_rs = bag[b_ind]
    
    # Step 5: Record the difference (in the proportion of 1s)
    a_yes_pct = 100 * sum(a_rs) / length(a_rs)
    b_yes_pct = 100 * sum(b_rs) / length(b_rs)
    perm_res[i] = a_yes_pct - b_yes_pct
  }
  
  if (verbose) {
    m = min(max_print, n_p)
    for (i in 1:m) {
      cat("Permutation", i, ": A-B (%) =", perm_res[i], "\n")
    }
  }
  
  return(perm_res)
}


ab_permutation_test = function(a_all, b_all, a_yes, b_yes, n_p=100,
                               alpha=0.05, verbose=FALSE, random_seed=NA) {
  
  # Function documentation
  # 
  # Purpose: Main function to perform the whole A/B Permutation Test process, 
  #          show density plot with results summary, and return the p-value
  #
  # Input (parameters):
  # - a_all: Total number of subjects in group A
  # - b_all: Total number of subjects in group B
  # - a_yes: Number of successes (1, Yes) in group A
  # - b_yes: Number of successes (1, Yes) in group B
  # - n_p: Number of permutations to perform 
  #
  # Output (result): Shows a density plot with a summary of the results, and
  #                  returns the p-value of the permutation test
  
  if (is.numeric(random_seed)) set.seed(random_seed)
  
  # No Conversion (failure) counts by group
  a_no = a_all - a_yes
  b_no = b_all - b_yes
  
  # Total conversions (yes) and no conversions (no)
  n_yes = a_yes + b_yes
  n_no  = a_no  + b_no
  
  # Conversion rates (%) by group
  a_yes_pct = 100 * a_yes / a_all
  b_yes_pct = 100 * b_yes / b_all
  
  # Statistic: Conversion rate difference (A-B) (%)
  ab_yes_pct_diff = a_yes_pct - b_yes_pct
  
  if (verbose) {
    cat('Observed Yes Rate (%):',
        ' A:', a_yes_pct, 
        ', B:', b_yes_pct, 
        ', A-B:', ab_yes_pct_diff, '\n')
  }
  
  perm_res = n_ab_permutations(n_yes, n_no, a_all, n_p)
  
  extreme_count = sum(abs(perm_res) >= abs(ab_yes_pct_diff))
  p_value = extreme_count / n_p
  
  #if (verbose) {
  #  cat("Number of permutations           :", n_p, "\n")
  #  cat("Number of extreme values         :", extreme_count, "\n")
  #  cat("Ratio of extreme values (p-value):", p_value)
  #}
  
  # Density plot
  title = paste("Perm. =", n_p, 
                ", Extreme count =", extreme_count,
                ", P-value =", p_value)
  x_lab = paste("A/B Test Statistic: A - B (%)\n",
                "(observed:", ab_yes_pct_diff, "%)")
  # Note: using adjust=2 to get a smother curve
  d = density(perm_res, adjust=2)
  plot(d, main=title, xlab=x_lab)
  xc = abs(ab_yes_pct_diff)
  c1 = (d$x < -xc) # extreme negative values (left)
  c2 = (abs(d$x) < xc) # non-extreme values
  c3 = (d$x > xc) # extreme positive values (right)
  polygon(c(d$x[c1], -xc), c(d$y[c1], 0), col='orange')
  polygon(c(-xc, d$x[c2], xc), c(0, d$y[c2], 0), col='gray') #col='skyblue'
  polygon(c(xc, d$x[c3]), c(0, d$y[c3]), col='orange')
  abline(v = ab_yes_pct_diff, col = 'red', lwd = 3)
  abline(v = -ab_yes_pct_diff, col = 'red', lty = 2, lwd = 3)
  
  return(p_value)
}
