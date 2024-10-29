AbstractAgent <- R6Class("AbstractAgent", list(
  id = 0
))

STATUSES <- c("Susceptible", "Infected", "Recovered")

SIR_Agent <- R6Class("SIR_Agent", list(
  inherit = AbstractAgent,
  status = "Susceptible"
))
