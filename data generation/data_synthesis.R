set.seed(123)
n <- 100

###1. continuous variables###
age <-round(rnorm(n, mean = 41.4, sd = 10)) #age: normally distributed
income <- rlnorm(n, meanlog = log(3500) - (0.5 * 0.75^2), sdlog = 0.75) #log-normal income: a heavy tailed distribution around the mean of 3000

#personality traits (big 5)
openness <- pmin(pmax(rnorm(n, mean = 3.61, sd = 0.7), 1), 5)
conscientiousness <- pmin(pmax(rnorm(n, mean = 3.44, sd = 0.6), 1), 5)
extraversion <- pmin(pmax(rnorm(n, mean = 3.34, sd = 0.8), 1), 5)
agreeableness <- pmin(pmax(rnorm(n, mean = 3.55, sd = 0.5), 1), 5)
neuroticism <- pmin(pmax(rnorm(n, mean = 2.87, sd = 0.7), 1), 5)

#depression symptoms (PHQ-9) #NOT CONTINUOUS BUT ORDINAL
depressed_mood <- sample(0:3, n, replace = TRUE, prob = c(0.3, 0.3, 0.2, 0.2))
anhedonia <- sample(0:3, n, replace = TRUE, prob = c(0.3, 0.3, 0.2, 0.2))
weight_change <- sample(0:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
sleep_disturbance <- sample(0:3, n, replace = TRUE, prob = c(0.35, 0.3, 0.2, 0.15))
psychomotor <- sample(0:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
fatigue <- sample(0:3, n, replace = TRUE, prob = c(0.25, 0.35, 0.25, 0.15))
worthlessness <- sample(0:3, n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
concentration <- sample(0:3, n, replace = TRUE, prob = c(0.3, 0.3, 0.25, 0.15))
suicidal_ideation <- sample(0:3, n, replace = TRUE, prob = c(0.7, 0.2, 0.08, 0.02))
total_depressive_symptoms <- depressed_mood + anhedonia + weight_change + sleep_disturbance +
  psychomotor + fatigue + worthlessness + concentration + suicidal_ideation


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


###Combining all values into one dataset###
data <- data.frame(
  age = age,
  gender = gender,
  income = income,
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
  total_depressive_symptoms = total_depressive_symptoms,
  ethnicity = ethnicity,
  religion = religion,
  education = education
)

summary(data)
write.csv(data, "synthetic_data.csv", row.names = FALSE)
