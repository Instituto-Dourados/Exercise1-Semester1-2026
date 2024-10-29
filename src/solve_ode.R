# Function for running differential equations
library(deSolve)
library(ggplot2)


demo_solve_ode = function(b = 1.4, g = 0.3, resusc_prob = 0.01, 
                          da_cidade = 0.1, t = 100) {
  
  # Specify initial conditions.
  init_conds <- c(S = .95, I = 0.05, R = 0)
  parameters <- c(b = b, g = g, resusc_prob = resusc_prob, da_cidade = da_cidade)
  time_vec <- seq(0, t, by = t / (2 * length(1:t)))
  
  eqn_system = function(time, state, parameters)
    with(as.list(c(time, state, parameters)), {
      dS <- -b * S * I + resusc_prob * R - S*da_cidade
      dI <- b*S*I - g*I + S*da_cidade
      dR <- g * I - resusc_prob * R
      
      return (list(c(dS, dI, dR)))
    })
  
  out_df <- as.data.frame(
    ode(y = init_conds, times = time_vec, eqn_system, parms = parameters)
  )
  
  return (out_df)
}


plot_demo_dynamics <- function(out_df) {
  p <- ggplot(out_df, aes(x = time)) +
    geom_line(aes(y = S, color = "Susceptible")) +
    geom_line(aes(y = I, color = "Infected")) +
    geom_line(aes(y = R, color = "Recovered")) +
    xlab(label = "Time") +
    ylab(label = "Proportion")
  
  return (p)
}


# show(plot_demo_dynamics(demo_solve_ode(resusc_prob = 0.01, da_cidade = 0.0, t = 200)))



two_group_ode = function(b = 1.4, g = 0.3, resusc_prob = 0.01, homophily = 0.3,
                         da_cidade_1 = 0.1, da_cidade_2 = 0.0001, t = 100) {
  
  # Specify initial conditions.
  init_conds <- c(S_1 = 1.0, I_1 = 0, R_1 = 0, S_2 = 1.0, I_2 = 0.0, R_2 = 0.0)
  
  parameters <- c(b, g, 
                  da_cidade_1, da_cidade_2, resusc_prob,
                  h = homophily
                  )
  
  time_vec <- seq(0, t, by = t / (2 * length(1:t)))
  
  
  
  eqn_system = function(time, state, parameters)
    
    with(as.list(c(time, state, parameters)), {
      dS_1 <- -b*h*S_1*I_1 - b*(1 - h)*S_1*I_2 + resusc_prob*R_1 - S_1*da_cidade_1
      dI_1 <- b*S_1*h*I_1 + b*S_1*(1 - h)*I_2 - g*I_1 + S_1*da_cidade_1
      dR_1 <- g * I_1 - resusc_prob * R_1
      
      dS_2 <- -b*h*S_2*I_2 - b*(1 - h)*S_2*I_1  + resusc_prob*R_2 - S_2*da_cidade_2
      dI_2 <-  b*h*S_2*I_2 + b*(1 - h)*S_2*I_1 - g*I_2 + S_2*da_cidade_2
      dR_2 <- g*I_2 - resusc_prob*R_2
      
      return (list(c(dS_1, dI_1, dR_1, dS_2, dI_2, dR_2)))
    })
    
  out_df <- as.data.frame(
    ode(y = init_conds, times = time_vec, eqn_system, parms = parameters)
  )
  
  return (out_df)
}

plot_two_groups <- function(out_df) {
  p <- ggplot(out_df, aes(x = time)) +
    geom_line(aes(y = S_1, color = "Susceptible 1")) +
    geom_line(aes(y = I_1, color = "Infected 1")) +
    geom_line(aes(y = R_1, color = "Recovered 1")) +
    geom_line(aes(y = S_2, color = "Susceptible 2"), linetype = "dashed") +
    geom_line(aes(y = I_2, color = "Infected 2"), linetype = "dashed") +
    geom_line(aes(y = R_2, color = "Recovered 2"), linetype = "dashed") +
    scale_colour_manual("Compartments",
                        breaks=c("Susceptible 1","Infected 1","Recovered 1",
                                 "Susceptible 2","Infected 2","Recovered 2"),
                        values=c("blue","red","darkgreen","blue","red","darkgreen")) +
    xlab(label = "Time") +
    ylab(label = "Proportion") +
    ylim(c(0, 10000))
  
  return (p)
}

# show(plot_two_groups(two_group_ode(g = 0.3, da_cidade_1 = .1, da_cidade_2 = 0.2,
#                                    resusc_prob = 0.00,  h = 0.999999999999999, 
#                                    t = 200)))

# run_plot_two_groups = function()