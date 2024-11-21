library(MASS)

set.seed(123)
n <- 100

###1. continuous variables###
cor_matrix <- matrix(c(
  1.0,  0.7,  0.5,  0.6,  0.5,  0.5, -0.3, # age
  0.7,  1.0,  0.6,  0.5,  0.6,  0.5, -0.4, # income
  0.5,  0.6,  1.0,  0.8,  0.7,  0.6, -0.3, # openness
  0.6,  0.5,  0.8,  1.0,  0.7,  0.6, -0.5, # conscientiousness
  0.5,  0.6,  0.7,  0.7,  1.0,  0.8, -0.4, # extraversion
  0.5,  0.5,  0.6,  0.6,  0.8,  1.0, -0.5, # agreeableness
  -0.3, -0.4, -0.3, -0.5, -0.4, -0.5,  1.0  # neuroticism
), nrow = 7, byrow = TRUE)


means <- c(41.4, log(3500), 3.61, 3.44, 3.34, 3.55, 2.87)
sds <- c(10, 0.75, 0.7, 0.6, 0.8, 0.5, 0.7)              

cont_correlated_data <- mvrnorm(n = n, mu = means, Sigma = cor_matrix * (sds %*% t(sds)))

age <- round(cont_correlated_data[, 1])
income <- exp(cont_correlated_data[, 2])  # Transform log-normal back to income
openness <- pmin(pmax(cont_correlated_data[, 3], 1), 5)
conscientiousness <- pmin(pmax(cont_correlated_data[, 4], 1), 5)
extraversion <- pmin(pmax(cont_correlated_data[, 5], 1), 5)
agreeableness <- pmin(pmax(cont_correlated_data[, 6], 1), 5)
neuroticism <- pmin(pmax(cont_correlated_data[, 7], 1), 5)

#ordinal vars
#depression symptoms (PHQ-9)
depressed_mood <- sample(0:3, n, replace = TRUE, prob = c(0.3, 0.3, 0.2, 0.2))
anhedonia <- sample(0:3, n, replace = TRUE, prob = c(0.3, 0.3, 0.2, 0.2))
weight_change <- sample(0:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
sleep_disturbance <- sample(0:3, n, replace = TRUE, prob = c(0.35, 0.3, 0.2, 0.15))
psychomotor <- sample(0:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
fatigue <- sample(0:3, n, replace = TRUE, prob = c(0.25, 0.35, 0.25, 0.15))
worthlessness <- sample(0:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
concentration <- sample(0:3, n, replace = TRUE, prob = c(0.3, 0.3, 0.25, 0.15))
suicidal_ideation <- sample(0:3, n, replace = TRUE, prob = c(0.7, 0.2, 0.08, 0.02))
total_depressive_symptoms <- depressed_mood + anhedonia + weight_change +
  sleep_disturbance + psychomotor + fatigue + worthlessness + concentration +
  suicidal_ideation #continuous!

###2. categorical variables###
gender <- sample(c("Male", "Female", "Other"), n, replace = TRUE, prob = c(0.48, 0.48, 0.04))
ethnicity <- sample(
  c("Dutch", "EU (excluding Dutch)", "Turkish", "Moroccan", "Surinamese", "Indonesian", "Other ethnicity(-ies)"),
  n, replace = TRUE,
  prob = c(0.75, 0.064, 0.024, 0.024, 0.021, 0.02, 0.0937)) #ethnicity categories based on CIA world factbook; "Other ethnicity(-ies)" inflated to make probabilities add to 1
religion <- sample(
  c("Roman Catholic", "Protestant", "Muslim", "Other religion(-s)", "None"),
  n, replace = TRUE,
  prob = c(0.201, 0.148, 0.05, 0.060, 0.541)) #ethnicity categories based on CIA world factbook; "Other religion(-s)" inflated to make probabilities add to 1
education <- sample(
  c("Primary", "VMBO", "HAVO", "VWO", "MBO", "HBO", "WO"),
  n, replace = TRUE,
  prob = c(0.1, 0.2, 0.15, 0.15, 0.2, 0.1, 0.1)) #randomly generated probabilities

#combine into a df
data <- data.frame(
  age = age,
  income = round(income),  # Use rounded income
  gender = gender,
  ethnicity = ethnicity,
  religion = religion,
  education = education,
  openness = openness,
  conscientiousness = conscientiousness,
  extraversion = extraversion,
  agreeableness = agreeableness,
  neuroticism = neuroticism,
  depressed_mood = depressed_mood,
  anhedonia = anhedonia,
  weight_change = weight_change,
  sleep_disturbance = sleep_disturbance,
  psychomotor = psychomotor,
  fatigue = fatigue,
  worthlessness = worthlessness,
  concentration = concentration,
  suicidal_ideation = suicidal_ideation,
  total_depressive_symptoms = total_depressive_symptoms
)

summary(data)
write.csv(data, "synthetic_correlated_data.csv", row.names = FALSE)
