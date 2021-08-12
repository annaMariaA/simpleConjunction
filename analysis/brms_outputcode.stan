// generated with brms 2.14.4
functions {
  /* turn a vector into a matrix of defined dimension 
   * stores elements in row major order
   * Args: 
   *   X: a vector 
   *   N: first dimension of the desired matrix
   *   K: second dimension of the desired matrix 
   * Returns: 
   *   a matrix of dimension N x K 
   */ 
  matrix as_matrix(vector X, int N, int K) { 
    matrix[N, K] Y; 
    for (i in 1:N) {
      Y[i] = to_row_vector(X[((i - 1) * K + 1):(i * K)]); 
    }
    return Y; 
  } 
 /* compute correlated group-level effects
  * Args: 
  *   z: matrix of unscaled group-level effects
  *   SD: vector of standard deviation parameters
  *   L: cholesky factor correlation matrix
  * Returns: 
  *   matrix of scaled group-level effects
  */ 
  matrix scale_r_cor(matrix z, vector SD, matrix L) {
    // r is stored in another dimension order than z
    return transpose(diag_pre_multiply(SD, L) * z);
  }
  /* Wiener diffusion log-PDF for a single response
   * Args: 
   *   y: reaction time data
   *   dec: decision data (0 or 1)
   *   alpha: boundary separation parameter > 0
   *   tau: non-decision time parameter > 0
   *   beta: initial bias parameter in [0, 1]
   *   delta: drift rate parameter
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
   real wiener_diffusion_lpdf(real y, int dec, real alpha, 
                              real tau, real beta, real delta) { 
     if (dec == 1) {
       return wiener_lpdf(y | alpha, tau, beta, delta);
     } else {
       return wiener_lpdf(y | alpha, tau, 1 - beta, - delta);
     }
   }
}
data {
  int<lower=1> N;  // total number of observations
  vector[N] Y;  // response variable
  int<lower=0,upper=1> dec[N];  // decisions
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  int<lower=1> K_bs;  // number of population-level effects
  matrix[N, K_bs] X_bs;  // population-level design matrix
  int<lower=1> K_bias;  // number of population-level effects
  matrix[N, K_bias] X_bias;  // population-level design matrix
  // data for group-level effects of ID 1
  int<lower=1> N_1;  // number of grouping levels
  int<lower=1> M_1;  // number of coefficients per level
  int<lower=1> J_1[N];  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_1_1;
  vector[N] Z_1_2;
  vector[N] Z_1_3;
  vector[N] Z_1_4;
  vector[N] Z_1_5;
  vector[N] Z_1_6;
  vector[N] Z_1_bs_7;
  vector[N] Z_1_bs_8;
  vector[N] Z_1_bs_9;
  vector[N] Z_1_bias_10;
  vector[N] Z_1_bias_11;
  vector[N] Z_1_bias_12;
  int<lower=1> NC_1;  // number of group-level correlations
  // data for group-level effects of ID 2
  int<lower=1> N_2;  // number of grouping levels
  int<lower=1> M_2;  // number of coefficients per level
  int<lower=1> J_2[N];  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_2_ndt_1;
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
  real min_Y = min(Y);
}
parameters {
  vector[K] b;  // population-level effects
  vector[K_bs] b_bs;  // population-level effects
  real Intercept_ndt;  // temporary intercept for centered predictors
  vector[K_bias] b_bias;  // population-level effects
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations
  matrix[M_1, N_1] z_1;  // standardized group-level effects
  cholesky_factor_corr[M_1] L_1;  // cholesky factor of correlation matrix
  vector<lower=0>[M_2] sd_2;  // group-level standard deviations
  vector[N_2] z_2[M_2];  // standardized group-level effects
}
transformed parameters {
  matrix[N_1, M_1] r_1;  // actual group-level effects
  // using vectors speeds up indexing in loops
  vector[N_1] r_1_1;
  vector[N_1] r_1_2;
  vector[N_1] r_1_3;
  vector[N_1] r_1_4;
  vector[N_1] r_1_5;
  vector[N_1] r_1_6;
  vector[N_1] r_1_bs_7;
  vector[N_1] r_1_bs_8;
  vector[N_1] r_1_bs_9;
  vector[N_1] r_1_bias_10;
  vector[N_1] r_1_bias_11;
  vector[N_1] r_1_bias_12;
  vector[N_2] r_2_ndt_1;  // actual group-level effects
  // compute actual group-level effects
  r_1 = scale_r_cor(z_1, sd_1, L_1);
  r_1_1 = r_1[, 1];
  r_1_2 = r_1[, 2];
  r_1_3 = r_1[, 3];
  r_1_4 = r_1[, 4];
  r_1_5 = r_1[, 5];
  r_1_6 = r_1[, 6];
  r_1_bs_7 = r_1[, 7];
  r_1_bs_8 = r_1[, 8];
  r_1_bs_9 = r_1[, 9];
  r_1_bias_10 = r_1[, 10];
  r_1_bias_11 = r_1[, 11];
  r_1_bias_12 = r_1[, 12];
  r_2_ndt_1 = (sd_2[1] * (z_2[1]));
}
model {
  // likelihood including all constants
  if (!prior_only) {
    // initialize linear predictor term
    vector[N] mu = X * b;
    // initialize linear predictor term
    vector[N] bs = X_bs * b_bs;
    // initialize linear predictor term
    vector[N] ndt = Intercept_ndt + rep_vector(0.0, N);
    // initialize linear predictor term
    vector[N] bias = X_bias * b_bias;
    for (n in 1:N) {
      // add more terms to the linear predictor
      mu[n] += r_1_1[J_1[n]] * Z_1_1[n] + r_1_2[J_1[n]] * Z_1_2[n] + r_1_3[J_1[n]] * Z_1_3[n] + r_1_4[J_1[n]] * Z_1_4[n] + r_1_5[J_1[n]] * Z_1_5[n] + r_1_6[J_1[n]] * Z_1_6[n];
    }
    for (n in 1:N) {
      // add more terms to the linear predictor
      bs[n] += r_1_bs_7[J_1[n]] * Z_1_bs_7[n] + r_1_bs_8[J_1[n]] * Z_1_bs_8[n] + r_1_bs_9[J_1[n]] * Z_1_bs_9[n];
    }
    for (n in 1:N) {
      // add more terms to the linear predictor
      ndt[n] += r_2_ndt_1[J_2[n]] * Z_2_ndt_1[n];
    }
    for (n in 1:N) {
      // add more terms to the linear predictor
      bias[n] += r_1_bias_10[J_1[n]] * Z_1_bias_10[n] + r_1_bias_11[J_1[n]] * Z_1_bias_11[n] + r_1_bias_12[J_1[n]] * Z_1_bias_12[n];
    }
    for (n in 1:N) {
      target += wiener_diffusion_lpdf(Y[n] | dec[n], bs[n], ndt[n], bias[n], mu[n]);
    }
  }
  // priors including all constants
  target += cauchy_lpdf(b | 0, 5);
  target += normal_lpdf(b_bs | 1.5, 1);
  target += normal_lpdf(Intercept_ndt | 0.2, 0.1);
  target += normal_lpdf(b_bias | 0.5, 0.2);
  target += student_t_lpdf(sd_1 | 3, 0, 2.5)
    - 12 * student_t_lccdf(0 | 3, 0, 2.5);
  target += std_normal_lpdf(to_vector(z_1));
  target += lkj_corr_cholesky_lpdf(L_1 | 1);
  target += student_t_lpdf(sd_2 | 3, 0, 2.5)
    - 1 * student_t_lccdf(0 | 3, 0, 2.5);
  target += std_normal_lpdf(z_2[1]);
}
generated quantities {
  // actual population-level intercept
  real b_ndt_Intercept = Intercept_ndt;
  // compute group-level correlations
  corr_matrix[M_1] Cor_1 = multiply_lower_tri_self_transpose(L_1);
  vector<lower=-1,upper=1>[NC_1] cor_1;
  // extract upper diagonal of correlation matrix
  for (k in 1:M_1) {
    for (j in 1:(k - 1)) {
      cor_1[choose(k - 1, 2) + j] = Cor_1[j, k];
    }
  }
}