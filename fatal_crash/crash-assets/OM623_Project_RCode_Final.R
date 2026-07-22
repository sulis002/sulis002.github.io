###########################################################################
# OM 623 - Business Analytics / Supply Chain                              #
# Fatal Crash Prediction - 2023 NHTSA FARS Data                          #
# Group: Clarissa Hardin, Brenda Laime Jaime, Natasha Sulistyo           #
# Goal: predict number of fatalities per crash using Linear Regression    #
#       and a Decision Tree                                               #
###########################################################################

###########################################################################
# Symbols we use in this script                                           #
###########################################################################
# <-    stores a value in a variable
# ~     separates target from predictors in a model formula
# .     means "use all other columns" in a formula
# $     pulls a specific column from a data frame
# []    subsets rows or columns
# :     creates a sequence like 1:nrow(df)
# |     logical OR
# &     logical AND
###########################################################################

###########################################################################
# Packages and functions we use                                           #
###########################################################################
# library          loads a package so we can use its functions
# set.seed         makes random steps give the same result every time
# getwd            shows which folder R is currently working in
# list.files       shows what files are in that folder
# read.csv         reads a csv file into a data frame
# str              shows column names and data types
# head             shows first few rows
# names            shows column names
# summary          gives descriptive stats for each column
# nrow             counts rows
# aggregate        groups data and applies a function to each group
# merge            joins two data frames using a shared column
# factor           converts a column into a categorical variable
# lapply           applies a function to multiple columns at once
# table            frequency table for a column
# is.na            checks which values are missing
# colSums          sums each column (useful for counting NAs)
# anyNA            checks if there are any missing values at all
# median           the middle value of a sorted column
# quantile         gets percentiles like Q1 and Q3
# boxplot          box and whisker plot
# hist             histogram
# barplot          bar chart
# plot             general scatter or line plot
# abline           adds a line to an existing plot
# par              controls plot layout
# cor              correlation matrix
# corrplot         visual correlation heatmap
# sample           picks random row indices for train/valid split
# lm               fits a linear regression model
# predict          gets predictions from a fitted model
# step             stepwise feature selection using AIC
# formula          extracts the formula from a model
# vif              checks multicollinearity using Variance Inflation Factors
# qqnorm / qqline  Normal Q-Q plot to check residual normality
# rpart            fits a decision tree
# rpart.control    sets the tree growing parameters
# prune            prunes a tree back to a simpler version
# rpart.plot       draws the decision tree
# trainControl     sets up cross-validation parameters
# train            runs cross-validation using caret
# print            prints an object
# cat              prints text to the console
# round            rounds numbers to a set number of decimal places
###########################################################################


############################################################
# A. Setup                                                 #
############################################################

# run these once if you need to install the packages
# install.packages("car")
# install.packages("caret")
# install.packages("rpart")
# install.packages("rpart.plot")
# install.packages("corrplot")

library(car)        # gives us vif()
library(caret)      # gives us trainControl() and train()
library(rpart)      # gives us rpart() for decision trees
library(rpart.plot) # gives us rpart.plot() to draw the tree
library(corrplot)   # gives us corrplot() for the heatmap

set.seed(123)  # set seed so our random split is reproducible
               # set.seed() is also called before each individual
               # random operation (CV) to ensure reproducibility
               # regardless of what ran earlier in the session

# check that R is looking in the right folder
getwd()
list.files()

# make sure both csv files are actually there before we try to load them
file.exists("accident.csv")
file.exists("drimpair.csv")


############################################################
# B. Load the Data                                         #
############################################################

accident <- read.csv("accident.csv", header = TRUE)
drimpair <- read.csv("drimpair.csv", header = TRUE)

# take a quick look at both files to understand what we are working with
str(accident)
head(accident, 3)
names(accident)
summary(accident)

str(drimpair)
head(drimpair, 3)


############################################################
# C. Build the Impaired Driver Flag                        #
############################################################

# the drimpair file has one row per driver per crash
# DRIMPAIR = 9 means the driver was under the influence of alcohol or drugs
# we want a single flag per crash: 1 if any driver was impaired, 0 if not
# this variable is not in the raw accident file — we engineer it here

impaired_flag <- aggregate(
  DRIMPAIR ~ ST_CASE,                           # group by unique crash ID
  data = drimpair,
  FUN  = function(x) as.integer(9 %in% x)      # 1 if any driver had code 9
)

# rename the column so it makes sense after the merge
names(impaired_flag)[2] <- "impaired_driver"

# merge this flag into the accident file using the shared crash ID
# all.x = TRUE keeps every accident row even if there is no match in drimpair
# note: confirmed that all 37,654 crashes appear in both files,
#       so all.x = TRUE is defensive practice here
df <- merge(accident, impaired_flag,
            by    = "ST_CASE",
            all.x = TRUE)

# any crash with no matching drimpair record gets NA — fill with 0
# (no impaired driver record is treated as no impaired driver present)
df$impaired_driver[is.na(df$impaired_driver)] <- 0

# quick check — should still have 37,654 rows and no NAs in impaired_driver
nrow(df)
cat("NA check — impaired_driver after fill:", sum(is.na(df$impaired_driver)), "\n")
table(df$impaired_driver)   # 0 = no impaired driver, 1 = at least one impaired driver


############################################################
# D. Keep Only the Columns We Need                         #
############################################################

# we do not need all 80 columns from the accident file
# we selected 14 predictors relevant to predicting crash fatalities
# FATALS is our target variable (how many people died in the crash)

df <- df[, c("FATALS",
             "HOUR", "DAY_WEEK", "MONTH",
             "RUR_URB", "LGT_COND", "WEATHER",
             "FUNC_SYS", "REL_ROAD", "TYP_INT",
             "MAN_COLL", "HARM_EV",
             "PERSONS", "VE_TOTAL",
             "impaired_driver")]

str(df)
summary(df)


############################################################
# E. Replace NHTSA Unknown Codes with NA                   #
############################################################

# NHTSA FARS uses values like 99 and 98 to mean "unknown" or "not reported"
# if we leave those in, the model treats 99 as a real hour of day or
# lighting code — which would distort results
# we replace all known unknown codes with NA before imputation

df$HOUR[df$HOUR == 99]                        <- NA
df$LGT_COND[df$LGT_COND %in% c(8, 9)]       <- NA
df$WEATHER[df$WEATHER %in% c(98, 99)]        <- NA
df$RUR_URB[df$RUR_URB %in% c(6, 8, 9)]      <- NA
df$FUNC_SYS[df$FUNC_SYS %in% c(96, 98, 99)] <- NA
df$REL_ROAD[df$REL_ROAD %in% c(98, 99)]     <- NA
df$TYP_INT[df$TYP_INT %in% c(98, 99)]       <- NA
df$MAN_COLL[df$MAN_COLL %in% c(98, 99)]     <- NA
df$HARM_EV[df$HARM_EV == 99]                <- NA

# count NAs per column — should show values > 0 now
colSums(is.na(df))
anyNA(df)   # should be TRUE since we just introduced NAs


############################################################
# F. Fill In Missing Values (Imputation)                   #
############################################################

# for continuous columns we use the median
# we pick median over mean because these distributions are right-skewed —
# the median is more robust to extreme values than the mean

df$HOUR[is.na(df$HOUR)]         <- median(df$HOUR,     na.rm = TRUE)
df$PERSONS[is.na(df$PERSONS)]   <- median(df$PERSONS,  na.rm = TRUE)
df$VE_TOTAL[is.na(df$VE_TOTAL)] <- median(df$VE_TOTAL, na.rm = TRUE)

# for categorical columns coded as integers we use the mode
# the mode is the most commonly observed category

mode_val <- function(x) {
  as.integer(names(which.max(table(x))))
}

df$LGT_COND[is.na(df$LGT_COND)] <- mode_val(df$LGT_COND)
df$WEATHER[is.na(df$WEATHER)]    <- mode_val(df$WEATHER)
df$RUR_URB[is.na(df$RUR_URB)]   <- mode_val(df$RUR_URB)
df$FUNC_SYS[is.na(df$FUNC_SYS)] <- mode_val(df$FUNC_SYS)
df$REL_ROAD[is.na(df$REL_ROAD)] <- mode_val(df$REL_ROAD)
df$TYP_INT[is.na(df$TYP_INT)]   <- mode_val(df$TYP_INT)
df$MAN_COLL[is.na(df$MAN_COLL)] <- mode_val(df$MAN_COLL)
df$HARM_EV[is.na(df$HARM_EV)]   <- mode_val(df$HARM_EV)

# confirm zero NAs remain across all columns
colSums(is.na(df))
stopifnot(sum(is.na(df)) == 0)   # script stops here if any NA remains
cat("Post-imputation NA count:", sum(is.na(df)), "— all clear\n")


############################################################
# G. Convert Categorical Columns to Factors                #
############################################################

# these columns look like numbers but are really category codes
# DAY_WEEK = 1 means Sunday, not "1 day" — the number has no numeric meaning
# lm() and rpart() need them as factors to create dummy variables correctly

factor_cols <- c("DAY_WEEK", "MONTH",
                 "RUR_URB",  "LGT_COND",
                 "WEATHER",  "FUNC_SYS",
                 "REL_ROAD", "TYP_INT",
                 "MAN_COLL", "HARM_EV",
                 "impaired_driver")

df[, factor_cols] <- lapply(
  X   = df[, factor_cols],
  FUN = factor
)

# verify they all converted
str(df)
lapply(df[, factor_cols], table)


############################################################
# H. Check and Cap Outliers in Continuous Predictors       #
############################################################

# we apply IQR capping to the three continuous predictors
# values below Q1 - 1.5*IQR are set to that lower boundary
# values above Q3 + 1.5*IQR are set to that upper boundary
# we cap rather than remove — this keeps all 37,654 rows
# we do NOT touch FATALS because it is our target variable —
# the high values represent real multi-fatality crashes we need to learn from

# visualize distributions before capping
par(mfrow = c(1, 3))
boxplot(df$HOUR,
        main = "HOUR before capping",
        ylab = "Hour of day",
        col  = "tomato")
boxplot(df$PERSONS,
        main = "PERSONS before capping",
        ylab = "Number of persons",
        col  = "tomato")
boxplot(df$VE_TOTAL,
        main = "VE_TOTAL before capping",
        ylab = "Number of vehicles",
        col  = "tomato")
par(mfrow = c(1, 1))

# IQR capping function
cap_outliers <- function(x) {
  Q1   <- quantile(x, 0.25, na.rm = TRUE)
  Q3   <- quantile(x, 0.75, na.rm = TRUE)
  IQRx <- Q3 - Q1
  lo   <- Q1 - 1.5 * IQRx
  hi   <- Q3 + 1.5 * IQRx
  x[x < lo] <- lo
  x[x > hi] <- hi
  return(x)
}

df$HOUR     <- cap_outliers(df$HOUR)
df$PERSONS  <- cap_outliers(df$PERSONS)
df$VE_TOTAL <- cap_outliers(df$VE_TOTAL)

# visualize after capping to confirm it worked
par(mfrow = c(1, 3))
boxplot(df$HOUR,
        main = "HOUR after capping",
        ylab = "Hour of day",
        col  = "steelblue")
boxplot(df$PERSONS,
        main = "PERSONS after capping",
        ylab = "Number of persons",
        col  = "steelblue")
boxplot(df$VE_TOTAL,
        main = "VE_TOTAL after capping",
        ylab = "Number of vehicles",
        col  = "steelblue")
par(mfrow = c(1, 1))

summary(df[, c("HOUR", "PERSONS", "VE_TOTAL")])


############################################################
# I. Exploratory Data Analysis                             #
############################################################

# distribution of the target variable
# right-skewed: 93% of crashes have exactly 1 fatality
hist(df$FATALS,
     main   = "Distribution of FATALS (Target Variable)",
     xlab   = "Number of fatalities per crash",
     col    = "steelblue",
     breaks = 8)

cat("FATALS frequency table:\n")
print(table(df$FATALS))
cat("Proportion with exactly 1 fatality:",
    round(mean(df$FATALS == 1), 3), "\n")

# average fatalities by hour of day
avg_hour <- aggregate(FATALS ~ HOUR, data = df, FUN = mean)
plot(avg_hour$HOUR, avg_hour$FATALS,
     type = "b",
     main = "Avg Fatalities by Hour of Day",
     xlab = "Hour",
     ylab = "Avg Fatalities",
     col  = "steelblue",
     pch  = 16,
     lwd  = 2)

# average fatalities by day of week
avg_day <- aggregate(FATALS ~ DAY_WEEK, data = df, FUN = mean)
barplot(avg_day$FATALS,
        names.arg = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
        main = "Avg Fatalities by Day of Week",
        xlab = "Day of Week",
        ylab = "Avg Fatalities",
        col  = "steelblue")

# impaired driver vs fatalities
# crashes with an impaired driver tend to have higher fatality counts
boxplot(FATALS ~ impaired_driver, data = df,
        names = c("No Impaired Driver", "Impaired Driver Present"),
        main  = "Fatalities by Impaired Driver Status",
        ylab  = "Number of Fatalities",
        col   = c("lightgray", "tomato"))

cat("Mean FATALS — no impaired driver: ",
    round(mean(df$FATALS[df$impaired_driver == 0]), 3), "\n")
cat("Mean FATALS — impaired driver:    ",
    round(mean(df$FATALS[df$impaired_driver == 1]), 3), "\n")

# rural vs urban
boxplot(FATALS ~ RUR_URB, data = df,
        main = "Fatalities: Rural vs Urban",
        xlab = "1 = Rural, 2 = Urban",
        ylab = "Number of Fatalities",
        col  = "steelblue")

# correlation among numeric predictors
num_cols <- df[, c("FATALS", "HOUR", "PERSONS", "VE_TOTAL")]
cor_mat  <- cor(num_cols, use = "pairwise.complete.obs")
round(cor_mat, 2)

corrplot(cor_mat,
         method = "circle",
         type   = "upper",
         tl.cex = 0.8,
         title  = "Correlation — Numeric Predictors vs FATALS",
         mar    = c(0, 0, 1, 0))


############################################################
# J. Split into Training and Validation Sets               #
############################################################

# 70% training, 30% validation
# random sample with set.seed so the split is reproducible

n           <- nrow(df)
train_index <- sample(
  x       = 1:n,
  size    = round(0.7 * n),
  replace = FALSE
)

train <- df[ train_index, ]
valid <- df[-train_index, ]

nrow(train)   # approx 26,358
nrow(valid)   # approx 11,296

summary(train$FATALS)
summary(valid$FATALS)


############################################################
# K. Error Metrics Function                                #
############################################################

# reusable function that returns ME, MAE, MSE, and RMSE
# ME   = mean error (bias — positive means under-predicting)
# MAE  = mean absolute error (average size of errors in fatality units)
# MSE  = mean squared error (penalizes larger errors more)
# RMSE = root mean squared error (same units as FATALS — our primary metric)

metrics <- function(actual, pred) {
  err  <- actual - pred
  ME   <- mean(err)
  MAE  <- mean(abs(err))
  MSE  <- mean(err^2)
  RMSE <- sqrt(MSE)
  out  <- c(ME = ME, MAE = MAE, MSE = MSE, RMSE = RMSE)
  return(round(out, 4))
}


############################################################
# L. Full Linear Regression (all predictors)               #
############################################################

# start with all 14 predictors as a baseline before feature selection
m_full <- lm(FATALS ~ ., data = train)
summary(m_full)

pred_train_full <- predict(m_full, newdata = train)
pred_valid_full <- predict(m_full, newdata = valid)

train_errors_full <- metrics(actual = train$FATALS, pred = pred_train_full)
valid_errors_full <- metrics(actual = valid$FATALS, pred = pred_valid_full)

cat("\n--- Full Linear Regression ---\n")
cat("Training errors:\n");   print(train_errors_full)
cat("Validation errors:\n"); print(valid_errors_full)


############################################################
# M. Stepwise Feature Selection (AIC)                      #
############################################################

# stepwise selection adds or removes predictors to minimize AIC
# AIC balances model fit against model complexity — lower is better
# we run all three directions to confirm the selection is stable:
#   backward: starts from the full model, removes one at a time
#   forward:  starts from intercept only, adds one at a time
#   both:     can add or remove at each step
# if all three agree, those variables genuinely earn their place

null_mod <- lm(FATALS ~ 1,  data = train)   # intercept only (no predictors)
full_mod  <- lm(FATALS ~ ., data = train)   # all predictors

step_back <- step(object    = full_mod,
                  direction = "backward",
                  trace     = 0)

step_forw <- step(object    = null_mod,
                  scope     = formula(full_mod),
                  direction = "forward",
                  trace     = 0)

step_both <- step(object    = full_mod,
                  direction = "both",
                  trace     = 0)

# compare the formulas each direction selected
formula(step_back)
formula(step_forw)
formula(step_both)
# if all three match, the feature selection is stable


############################################################
# N. Compare Stepwise Models on Validation Set             #
############################################################

pred_back_valid <- predict(step_back, newdata = valid)
pred_forw_valid <- predict(step_forw, newdata = valid)
pred_both_valid <- predict(step_both, newdata = valid)

cat("\n--- Stepwise Backward Validation ---\n")
print(metrics(valid$FATALS, pred_back_valid))

cat("\n--- Stepwise Forward Validation ---\n")
print(metrics(valid$FATALS, pred_forw_valid))

cat("\n--- Stepwise Both Validation ---\n")
print(metrics(valid$FATALS, pred_both_valid))


############################################################
# O. Multicollinearity Check (VIF)                         #
############################################################

# VIF measures how much a predictor's variance is inflated by
# correlation with the other predictors
# rule of thumb: VIF < 5 = fine, 5-10 = moderate concern, > 10 = serious

vif(step_back)


############################################################
# P. Final Linear Regression Model                         #
############################################################

# all three stepwise directions picked the same predictors
# we use step_back as the final linear regression model

final_lm <- step_back
summary(final_lm)

pred_train_lm <- predict(final_lm, newdata = train)
pred_valid_lm <- predict(final_lm, newdata = valid)

lm_train_errors <- metrics(train$FATALS, pred_train_lm)
lm_valid_errors <- metrics(valid$FATALS, pred_valid_lm)

cat("\n--- Final Linear Regression Errors ---\n")
cat("Training:\n");   print(lm_train_errors)
cat("Validation:\n"); print(lm_valid_errors)

# ----- Residual Diagnostic Plots -----
# these three plots check the assumptions of linear regression

par(mfrow = c(1, 3))

# 1. Residuals vs Fitted — checks linearity and constant variance
#    goal: random cloud around 0, no curve, no funnel shape
plot(fitted(final_lm), residuals(final_lm),
     main = "Residuals vs Fitted",
     xlab = "Fitted Values",
     ylab = "Residuals",
     col  = "gray40",
     pch  = 16,
     cex  = 0.4)
abline(h = 0, lty = 2, col = "red")

# 2. Histogram of Residuals — checks whether errors are roughly symmetric
#    goal: approximately bell-shaped and centered near 0
hist(residuals(final_lm),
     main   = "Histogram of Residuals",
     xlab   = "Residuals",
     col    = "lightgray",
     breaks = 30)

# 3. Normal Q-Q Plot — checks normality of residuals more precisely
#    goal: points close to the red diagonal line
qqnorm(residuals(final_lm),
       main = "Normal Q-Q Plot",
       pch  = 16,
       col  = "gray40",
       cex  = 0.4)
qqline(residuals(final_lm), col = "red", lwd = 2)

par(mfrow = c(1, 1))


############################################################
# Q. Cross-Validation for Linear Regression                #
############################################################

# 5-fold CV gives a more reliable error estimate than a single train/valid split
# the dataset is split into 5 parts; each part takes a turn as the hold-out set
# CV RMSE close to validation RMSE confirms the model generalizes well

ctrl <- trainControl(
  method          = "cv",
  number          = 5,
  savePredictions = "final"
)

set.seed(123)
cv_lm <- train(
  formula(final_lm),
  data      = df,
  method    = "lm",
  trControl = ctrl
)

print(cv_lm)
cv_lm$results   # RMSE, MAE, R-squared averaged across all 5 folds

# out-of-fold predictions
oof_lm <- cv_lm$pred
cat("\nLinear Regression — out-of-fold CV metrics:\n")
print(metrics(actual = oof_lm$obs, pred = oof_lm$pred))


############################################################
# R. Decision Tree                                         #
############################################################

# a decision tree recursively splits the data on the predictor that most
# reduces prediction error at each step
# method = "anova" because FATALS is a continuous number, not a category
# we grow a deep tree first (low cp), then prune to avoid overfitting:
#   - a fully grown tree memorizes training data but performs poorly on new data
#   - pruning pulls it back to the complexity that actually generalizes

reg_tree <- rpart(
  FATALS ~ .,
  data    = train,
  method  = "anova",
  control = rpart.control(
    minsplit = 20,    # a node needs at least 20 rows before it can split
    cp       = 0.001  # small cp lets the tree explore many splits
  )
)

# find the cp value with the lowest cross-validated error
best_cp <- reg_tree$cptable[which.min(reg_tree$cptable[, "xerror"]), "CP"]
cat("Best cp for pruning:", round(best_cp, 6), "\n")

# prune the tree using that cp
reg_tree_pruned <- prune(reg_tree, cp = best_cp)

# plot the pruned tree
rpart.plot(reg_tree_pruned,
           type          = 2,
           extra         = 101,
           fallen.leaves = TRUE,
           cex           = 0.7,
           tweak         = 1.0,
           box.palette   = "Blues",
           main          = "Decision Tree — Predicting FATALS (Pruned)")

# predictions and error metrics
pred_train_tree <- predict(reg_tree_pruned, newdata = train)
pred_valid_tree <- predict(reg_tree_pruned, newdata = valid)

tree_train_errors <- metrics(train$FATALS, pred_train_tree)
tree_valid_errors <- metrics(valid$FATALS, pred_valid_tree)

cat("\n--- Decision Tree Errors ---\n")
cat("Training:\n");   print(tree_train_errors)
cat("Validation:\n"); print(tree_valid_errors)


############################################################
# S. Cross-Validation for Decision Tree                    #
############################################################

set.seed(123)
cv_tree <- train(
  FATALS ~ .,
  data       = df,
  method     = "rpart",
  trControl  = ctrl,
  tuneLength = 10    # tries 10 different cp values and picks the best one
)

print(cv_tree)
cv_tree$results   # RMSE for each cp value tried
plot(cv_tree)     # shows how RMSE changes as cp changes


############################################################
# T. Model Comparison Summary                              #
############################################################

cat("\n============================================================\n")
cat("                  MODEL COMPARISON SUMMARY                  \n")
cat("============================================================\n")

cat("\nLinear Regression (Stepwise) — Training:\n")
print(lm_train_errors)
cat("Linear Regression (Stepwise) — Validation:\n")
print(lm_valid_errors)

cat("\nDecision Tree (Pruned) — Training:\n")
print(tree_train_errors)
cat("Decision Tree (Pruned) — Validation:\n")
print(tree_valid_errors)

cat("\nCross-Validation RMSE (5-fold):\n")
cat("  Linear Regression:", round(cv_lm$results$RMSE,       4), "\n")
cat("  Decision Tree:    ", round(min(cv_tree$results$RMSE), 4), "\n")

cat("\n--- How to interpret ---\n")
cat("RMSE is our primary metric — same units as FATALS, penalizes\n")
cat("larger errors more. Lower RMSE = better prediction accuracy.\n")
cat("If train and validation errors are close, the model is not overfitting.\n")
cat("If they diverge significantly, reduce complexity.\n")

############################################################
# End of Script                                            #
############################################################
