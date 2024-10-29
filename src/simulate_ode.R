

# See https://docs.google.com/document/d/163AMOMU_psYCQ7eITdjGxAelNZcxXD1Kk_oYmcpZkjU/edit
# secção "Parámetros de COVID-19 (da Aja Sutton)"
simulate_two_group_sirs_noetnia_det <- 
  function(c_11 = 0.0005, c_22 = 0.00012, c_12 = 0.0005, gamma_1 = 1.0, gamma_2 = 0.0, 
           N_1 = 9386, N_2 =  8341, I_1_init = 10, I_2_init = 0,
           # N_1 = 90, N_2 =  10, I_1_init = 10, I_2_init = 0,
           tau = 0.02, nsteps = 100, rho = 0.2, r = 0.0) {
  
  # Initialize compartment vectors.
  S_1 = S_2 = I_1 = I_2 = R_1 = R_2 = rep(0, nsteps)
  S_1[1] = N_1 - I_1_init
  I_1[1] = I_1_init
  S_2[1] = N_2 - I_2_init
  I_2[1] = I_2_init
  
  # Calculate betas.
  beta_11 = c_11 * tau; beta_22 = c_22 * tau; beta_12 = c_12 * tau;

  # Step model
  for (tt in seq(2, nsteps)) {

    S_1[tt] = S_1[tt - 1] + (- (S_1[tt - 1] * I_1[tt - 1] * beta_11) -
                               (S_1[tt - 1] * I_2[tt - 1] * beta_12) -
                               (S_1[tt - 1] * gamma_1) +
                               (R_1[tt - 1] * r))
    
    S_2[tt] = S_2[tt - 1] + (- (S_2[tt - 1] * I_2[tt - 1] * beta_22) -
                               (S_2[tt - 1] * I_1[tt - 1] * beta_12) -
                               (S_2[tt - 1] * gamma_2) +
                               (R_2[tt - 1] * r))
    
    I_1[tt] = I_1[tt - 1] + ((S_1[tt - 1] * I_1[tt - 1] * beta_11) +
                             (S_1[tt - 1] * I_2[tt - 1] * beta_12) +
                             (S_1[tt - 1] * gamma_1) -
                             (I_1[tt - 1] * rho))
    
    I_2[tt] = I_2[tt - 1] + ((S_2[tt - 1] * I_2[tt - 1] * beta_22) +
                             (S_2[tt - 1] * I_1[tt - 1] * beta_12) +
                             (S_2[tt - 1] * gamma_2) -
                             (I_2[tt - 1] * rho))
    
    R_1[tt] = R_1[tt - 1] + ((I_1[tt - 1] * rho) - (R_1[tt - 1] * r))
    
    R_2[tt] = R_2[tt - 1] + ((I_2[tt - 1] * rho) - (R_2[tt - 1] * r))
    
  }
  
  return (data.frame(S_1 = S_1, S_2 = S_2, 
                     I_1 = I_1, I_2 = I_2, 
                     R_1 = R_1, R_2 = R_2,
                     time = 1:nsteps))
}


possible_B11_resdf <- simulate_two_group_sirs_noetnia_det(
  c_22 = 0.001, gamma_1 = 0.2, gamma_2 = 0.0, c_12 = 0.00001, rho=0.05, r = 0.0
)

possible_B11_resdf_2 <- simulate_two_group_sirs_noetnia_det(c_22 = 0.0075, 
                                                            gamma_1 = 0.01, gamma_2 = 0.0, 
                                                            c_12 = 0.0001, , c_11 = 0.001, 
                                                            tau = 0.002, rho=0.05, 
                                                            r = 0.0, nsteps = 200)

