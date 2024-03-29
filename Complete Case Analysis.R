---
title: "BS 849 Final Project"
author: "Irene Hsueh"
date: "3/28/2022"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(table1)
library(knitr)
library(rjags)
library(formatR)
set.seed(1234)
```


# Tics Dataset
```{r}
tics_raw <- read.csv("C:/Irene Hsueh's Documents/MS Applied Biostatistics/BS 849 - Bayesian Modeling for Biomedical Research & Public Health/Project/tics.csv")
colSums(is.na(tics_raw))

tics <- tics_raw %>% 
#Renaming Variables
  dplyr::select(id = ID, 
                family_id = fam.num, 
                sex = sex, 
                group = ptype,
                age_enrollment = Age.at.Enrollment,
                age_last_contact = Age.Last.Contact, 
                deceased = Deceased,
                bmi = BMI, 
                smoker = SH.Ever.Smoked., 
                aspirin = MC.Aspirin,
                stroke = MC.Stroke, 
                diabetes = MC.Diabetes.Mellitus, 
                hypertension = MC.HTN, 
                cad = MC.Coronary.Artery.Disease, 
                cancer = MC.Cancer, 
                heart_attack = MC.Heart.Attack, 
                years_education = Years.of.Education, 
                tics1 = TICS01, 
                tics2 = TICS02, 
                tics3 = TICS03, 
                tics4 = TICS04, 
                tics5 = TICS05, 
                age1 = Age01, 
                age2 = Age02,
                age3 = Age03, 
                age4 = Age04, 
                age5 = Age05) %>% 
#Remove Observations with NA
  na.omit() %>%
#Reassign Values to Binary Variables
  mutate_at(c("deceased", "smoker", "aspirin", "stroke", "diabetes", 
              "hypertension", "cad", "cancer", "heart_attack"), 
            list(~dplyr::recode(., "No"=0, "Yes"=1))) %>%
#Factoring Variables
  mutate(across(.cols=c("sex", "group", "deceased", "smoker", "aspirin", "stroke", 
                        "diabetes", "hypertension", "cad", "cancer", "heart_attack"),
                .fns=as.factor))
head(tics, 10)
```



# Descriptive Statistics
```{r}
#Table 1
table_html <- table1(~ sex + age_enrollment + bmi + smoker + aspirin + stroke +
                       diabetes + hypertension + cad + cancer + heart_attack +
                       years_education | group, data=tics, 
                     overall="Total", 
                     rowlabelhead="Controls or Centenarian Offspring", 
                     caption="Telephone Interview for Cognitive Status Dataset")

tics_baseline_dataset <- list(N=nrow(tics), 
                              tics1 = tics$tics1,
                              group=tics$group, 
                              sex=tics$sex,
                              age_enrollment=tics$age_enrollment, 
                              bmi=tics$bmi,
                              smoker=tics$smoker,
                              aspirin=tics$aspirin,
                              stroke=tics$stroke, 
                              diabetes=tics$diabetes, 
                              hypertension=tics$hypertension,
                              cad=tics$cad, 
                              cancer=tics$cancer, 
                              heart_attack=tics$heart_attack, 
                              years_education=tics$years_education)
```


# Bayesian Crude Linear Regression of Baseline TICS Score 
```{r}
tics_crude_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- beta0 + beta_group*group[i] 
}

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

tics_crude_model <- jags.model(textConnection(tics_crude_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
tics_crude_model_gibbs <- update(tics_crude_model, n.iter=1000)
tics_crude_model_test <- coda.samples(tics_crude_model, c("beta0", "beta_group"), n.iter=1000)
summary(tics_crude_model_test)
```


# Checking Confounders - Sex 
```{r}
sex_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_sex            *sex[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_sex ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

sex_model <- jags.model(textConnection(sex_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
sex_model_gibbs <- update(sex_model, n.iter=1000)
sex_model_test <- coda.samples(sex_model, c("beta0", "beta_group", "beta_sex"), n.iter=1000)
summary(sex_model_test)
```



# Checking Confounders - BMI 
```{r}
bmi_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_bmi            *bmi[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_bmi ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

bmi_model <- jags.model(textConnection(bmi_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
bmi_model_gibbs <- update(bmi_model, n.iter=1000)
bmi_model_test <- coda.samples(bmi_model, c("beta0", "beta_group", "beta_bmi"), n.iter=1000)
summary(bmi_model_test)
```



# Checking Confounders - Age at Enrollment 
```{r}
age_enrollment_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_age_enrollment *age_enrollment[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_age_enrollment ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

age_enrollment_model <- jags.model(textConnection(age_enrollment_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
age_enrollment_model_gibbs <- update(age_enrollment_model, n.iter=1000)
age_enrollment_model_test <- coda.samples(age_enrollment_model, c("beta0", "beta_group", "beta_age_enrollment"), n.iter=1000)
summary(age_enrollment_model_test)
```



# Checking Confounders - Smoking Status 
```{r}
smoker_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_smoker            *smoker[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_smoker ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

smoker_model <- jags.model(textConnection(smoker_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
smoker_model_gibbs <- update(smoker_model, n.iter=1000)
smoker_model_test <- coda.samples(smoker_model, c("beta0", "beta_group", "beta_smoker"), n.iter=1000)
summary(smoker_model_test)
```



# Checking Confounders - Aspirin Use 
```{r}
aspirin_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_aspirin        *aspirin[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_aspirin ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

aspirin_model <- jags.model(textConnection(aspirin_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
aspirin_model_gibbs <- update(aspirin_model, n.iter=1000)
aspirin_model_test <- coda.samples(aspirin_model, c("beta0", "beta_group", "beta_aspirin"), n.iter=1000)
summary(aspirin_model_test)
```



# Checking Confounders - History of Stroke 
```{r}
stroke_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_stroke            *stroke[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_stroke ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

stroke_model <- jags.model(textConnection(stroke_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
stroke_model_gibbs <- update(stroke_model, n.iter=1000)
stroke_model_test <- coda.samples(stroke_model, c("beta0", "beta_group", "beta_stroke"), n.iter=1000)
summary(stroke_model_test)
```



# Checking Confounders - History of Diabetes 
```{r}
diabetes_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_diabetes            *diabetes[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_diabetes ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

diabetes_model <- jags.model(textConnection(diabetes_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
diabetes_model_gibbs <- update(diabetes_model, n.iter=1000)
diabetes_model_test <- coda.samples(diabetes_model, c("beta0", "beta_group", "beta_diabetes"), n.iter=1000)
summary(diabetes_model_test)
```



# Checking Confounders - History of Hypertension 
```{r}
hypertension_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_hypertension            *hypertension[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_hypertension ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

hypertension_model <- jags.model(textConnection(hypertension_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
hypertension_model_gibbs <- update(hypertension_model, n.iter=1000)
hypertension_model_test <- coda.samples(hypertension_model, c("beta0", "beta_group", "beta_hypertension"), n.iter=1000)
summary(hypertension_model_test)
```



# Checking Confounders - History of Coronary Artery Disease  
```{r}
cad_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_cad            *cad[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_cad ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

cad_model <- jags.model(textConnection(cad_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
cad_model_gibbs <- update(cad_model, n.iter=1000)
cad_model_test <- coda.samples(cad_model, c("beta0", "beta_group", "beta_cad"), n.iter=1000)
summary(cad_model_test)
```



# Checking Confounders - History of Cancer 
```{r}
cancer_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_cancer            *cancer[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_cancer ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

cancer_model <- jags.model(textConnection(cancer_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
cancer_model_gibbs <- update(cancer_model, n.iter=1000)
cancer_model_test <- coda.samples(cancer_model, c("beta0", "beta_group", "beta_cancer"), n.iter=1000)
summary(cancer_model_test)
```



# Checking Confounders - History of Heart Attack 
```{r}
heart_attack_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_heart_attack            *heart_attack[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_heart_attack ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

heart_attack_model <- jags.model(textConnection(heart_attack_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
heart_attack_model_gibbs <- update(heart_attack_model, n.iter=1000)
heart_attack_model_test <- coda.samples(heart_attack_model, c("beta0", "beta_group", "beta_heart_attack"), n.iter=1000)
summary(heart_attack_model_test)
```



# Checking Confounders - Years of Education 
```{r}
years_education_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group          *group[i] + 
    beta_years_education            *years_education[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_years_education ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

years_education_model <- jags.model(textConnection(years_education_model_bugs), data=tics_baseline_dataset, n.adapt=1000)
years_education_model_gibbs <- update(years_education_model, n.iter=1000)
years_education_model_test <- coda.samples(years_education_model, c("beta0", "beta_group", "beta_years_education"), n.iter=1000)
summary(years_education_model_test)
```



# Bayesian Adjusted Multiple Linear Regression of Baseline TICS Score 
```{r}
tics_adjusted_model_bugs <- 
"model {
for (i in 1:N){
  tics1[i] ~ dnorm(mu[i], tau)
  mu[i] <- 
    beta0 + 
    beta_group            *group[i] + 
    beta_sex              *sex[i] + 
    beta_smoker           *smoker[i] + 
    beta_aspirin          *aspirin[i] +
    beta_stroke           *stroke[i] +
    beta_diabetes         *diabetes[i] +
    beta_hypertension     *hypertension[i] +
    beta_cad              *cad[i] +
    beta_cancer           *cancer[i] +
    beta_heart_attack     *heart_attack[i] +
    beta_years_education  *years_education[i] 
    }

#Prior Distributions
beta0 ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_sex ~ dnorm(0, 0.0001)
beta_smoker ~ dnorm(0, 0.0001)
beta_aspirin ~ dnorm(0, 0.0001)
beta_stroke ~ dnorm(0, 0.0001)
beta_diabetes ~ dnorm(0, 0.0001)
beta_hypertension ~ dnorm(0, 0.0001)
beta_cad ~ dnorm(0, 0.0001)
beta_cancer ~ dnorm(0, 0.0001)
beta_heart_attack ~ dnorm(0, 0.0001)
beta_years_education ~ dnorm(0, 0.0001)
tau ~ dgamma(1, 1)
}"

tics_adjusted_model <- jags.model(textConnection(tics_adjusted_model_bugs), data=tics_baseline_dataset, n.adapt=1000, n.chains=3)
tics_adjusted_model_gibbs <- update(tics_adjusted_model, n.iter=1000)
tics_adjusted_model_test <- coda.samples(tics_adjusted_model, c("beta0", "beta_group", "beta_sex", "beta_smoker", "beta_aspirin", "beta_stroke", "beta_diabetes", "beta_hypertension", "beta_cad", "beta_cancer", "beta_heart_attack", "beta_years_education"), n.iter=1000)

summary(tics_adjusted_model_test)
geweke.diag(tics_adjusted_model_test, frac1=0.1, frac2=0.5)
```



# Creating Longitudinal Dataset for JAGS Model
```{r}
#Visualizing Longitudinal Data
plot(unlist(tics[1, c("tics1", "tics2", "tics3", "tics4", "tics5")]), 
     ylim=c(0, max(tics[, c("tics1", "tics2", "tics3", "tics4", "tics5")], na.rm=TRUE)))
for (i in 1:50) {
  lines(unlist(tics[i, c("tics1", "tics2", "tics3", "tics4", "tics5")]), col=i)
}

#All Outcome Measurements
y <- c(t(tics[, c("tics1", "tics2", "tics3", "tics4", "tics5")]))

#Index of Non-Missing Measurements 
index <- rep(1:300, each=5)

#Times of Non-Missing Measurements 
time <- c(t(tics[, c("age1", "age2", "age3", "age4", "age5")]))

#Dataset for JAGS Models
tics_dataset <- list(N=nrow(tics), n_obs=length(y), y=y, time=time, index=index, 
                     group=tics$group, 
                     sex=tics$sex,
                     smoker=tics$smoker,
                     aspirin=tics$aspirin,
                     stroke=tics$stroke, 
                     diabetes=tics$diabetes, 
                     hypertension=tics$hypertension,
                     cad=tics$cad, 
                     cancer=tics$cancer, 
                     heart_attack=tics$heart_attack
                     )
```



# Hierarchical Model Comparing Groups 
```{r}
hierarchical_group_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_group            *group[index[i]] +
            beta_interaction      *group[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_group ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_group_model <- jags.model(textConnection(hierarchical_group_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_group_model_gibbs <- update(hierarchical_group_model, n.iter=1000)
hierarchical_group_model_test <- coda.samples(hierarchical_group_model, c("mu_intercept", "mu_time", "beta_group", "beta_interaction"), n.iter=1000)
summary(hierarchical_group_model_test)
```



# Hierarchical Model Comparing Sex 
```{r}
hierarchical_sex_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_sex              *sex[index[i]] +
            beta_interaction      *sex[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_sex ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_sex_model <- jags.model(textConnection(hierarchical_sex_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_sex_model_gibbs <- update(hierarchical_sex_model, n.iter=1000)
hierarchical_sex_model_test <- coda.samples(hierarchical_sex_model, c("mu_intercept", "mu_time", "beta_sex", "beta_interaction"), n.iter=1000)
summary(hierarchical_sex_model_test)
```



# Hierarchical Model Comparing Smoking Status
```{r}
hierarchical_smoking_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_smoker           *smoker[index[i]] +
            beta_interaction      *smoker[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_smoker ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_smoking_model <- jags.model(textConnection(hierarchical_smoking_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_smoking_model_gibbs <- update(hierarchical_smoking_model, n.iter=1000)
hierarchical_smoking_model_test <- coda.samples(hierarchical_smoking_model, c("mu_intercept", "mu_time", "beta_smoker", "beta_interaction"), n.iter=1000)
summary(hierarchical_smoking_model_test)
```



# Hierarchical Model Comparing Aspirin Use 
```{r}
hierarchical_aspirin_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_aspirin          *aspirin[index[i]] +
            beta_interaction      *aspirin[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_aspirin ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_aspirin_model <- jags.model(textConnection(hierarchical_aspirin_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_aspirin_model_gibbs <- update(hierarchical_aspirin_model, n.iter=1000)
hierarchical_aspirin_model_test <- coda.samples(hierarchical_aspirin_model, c("mu_intercept", "mu_time", "beta_aspirin", "beta_interaction"), n.iter=1000)
summary(hierarchical_aspirin_model_test)
```



# Hierarchical Model Comparing History of Stroke
```{r}
hierarchical_stroke_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_stroke          *stroke[index[i]] +
            beta_interaction      *stroke[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_stroke ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_stroke_model <- jags.model(textConnection(hierarchical_stroke_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_stroke_model_gibbs <- update(hierarchical_stroke_model, n.iter=1000)
hierarchical_stroke_model_test <- coda.samples(hierarchical_stroke_model, c("mu_intercept", "mu_time", "beta_stroke", "beta_interaction"), n.iter=1000)
summary(hierarchical_stroke_model_test)
```



# Hierarchical Model Comparing History of Diabetes Mellitus
```{r}
hierarchical_diabetes_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_diabetes          *diabetes[index[i]] +
            beta_interaction      *diabetes[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_diabetes ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_diabetes_model <- jags.model(textConnection(hierarchical_diabetes_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_diabetes_model_gibbs <- update(hierarchical_diabetes_model, n.iter=1000)
hierarchical_diabetes_model_test <- coda.samples(hierarchical_diabetes_model, c("mu_intercept", "mu_time", "beta_diabetes", "beta_interaction"), n.iter=1000)
summary(hierarchical_diabetes_model_test)
```



# Hierarchical Model Comparing History of Hypertension
```{r}
hierarchical_hypertension_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_hypertension          *hypertension[index[i]] +
            beta_interaction      *hypertension[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_hypertension ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_hypertension_model <- jags.model(textConnection(hierarchical_hypertension_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_hypertension_model_gibbs <- update(hierarchical_hypertension_model, n.iter=1000)
hierarchical_hypertension_model_test <- coda.samples(hierarchical_hypertension_model, c("mu_intercept", "mu_time", "beta_hypertension", "beta_interaction"), n.iter=1000)
summary(hierarchical_hypertension_model_test)
```



# Hierarchical Model Comparing History of Coronary Artery Disease
```{r}
hierarchical_cad_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_cad          *cad[index[i]] +
            beta_interaction      *cad[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_cad ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_cad_model <- jags.model(textConnection(hierarchical_cad_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_cad_model_gibbs <- update(hierarchical_cad_model, n.iter=1000)
hierarchical_cad_model_test <- coda.samples(hierarchical_cad_model, c("mu_intercept", "mu_time", "beta_cad", "beta_interaction"), n.iter=1000)
summary(hierarchical_cad_model_test)
```



# Hierarchical Model Comparing History of Cancer 
```{r}
hierarchical_cancer_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_cancer          *cancer[index[i]] +
            beta_interaction      *cancer[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_cancer ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_cancer_model <- jags.model(textConnection(hierarchical_cancer_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_cancer_model_gibbs <- update(hierarchical_cancer_model, n.iter=1000)
hierarchical_cancer_model_test <- coda.samples(hierarchical_cancer_model, c("mu_intercept", "mu_time", "beta_cancer", "beta_interaction"), n.iter=1000)
summary(hierarchical_cancer_model_test)
```



# Hierarchical Model Comparing History of Heart Attack 
```{r}
hierarchical_heart_attack_model_bugs <- 
"model{
for (i in 1:n_obs) {
  y[i] ~ dnorm(psi[i], tau_y)
  psi[i] <- beta_intercept[index[i]] + 
            beta_time[index[i]]   *(time[i]-time_mean) + 
            beta_heart_attack          *heart_attack[index[i]] +
            beta_interaction      *heart_attack[index[i]] * (time[i]-time_mean)
}

#Random Effects
for (i in 1:N){
beta_intercept[i] ~ dnorm(mu_intercept, tau_intercept)
beta_time[i] ~ dnorm(mu_time, tau_time)
}

#Prior Distributions
mu_intercept ~ dnorm(0, 0.0001)
mu_time ~ dnorm(0, 0.0001)
beta_heart_attack ~ dnorm(0, 0.0001)
beta_interaction ~ dnorm(0, 0.0001)

tau_intercept ~ dgamma(1,1)
tau_time ~ dgamma(1,1)
tau_y ~ dgamma(1,1)

time_mean <- mean(time[])
}"

hierarchical_heart_attack_model <- jags.model(textConnection(hierarchical_heart_attack_model_bugs), data=tics_dataset, n.adapt=1000)
hierarchical_heart_attack_model_gibbs <- update(hierarchical_heart_attack_model, n.iter=1000)
hierarchical_heart_attack_model_test <- coda.samples(hierarchical_heart_attack_model, c("mu_intercept", "mu_time", "beta_heart_attack", "beta_interaction"), n.iter=1000)
summary(hierarchical_heart_attack_model_test)
```

