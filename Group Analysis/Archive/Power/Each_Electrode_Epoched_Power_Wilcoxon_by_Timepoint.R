# Script Name:  Each_Electrode_Epoched_Power_Wilcoxon_by_Timepoint.R
# Author:       Lindsay Vass
# Date:         29 May 2015
# Purpose:      This script will test whether power significantly differs 
#               between timepoints (Pre1, Tele, Post1) within each frequency
#               band for each electrode. It will use Wilcoxon signed rank tests
#               to identify electrodes that show:
#                 1. Pre > Tele
#                 2. Pre < Tele
#                 3. Tele > Post
#                 4. Tele < Post
#               It will determine whether the number of electrodes showing a 
#               given effect is higher than expected by chance using a binomial
#               test. Finally, it will plot the frequencies of these effects as
#               a bar graph. NB Power is defined as z-scored log(Power), where 
#               the values are z-scored within each electrode and frequency band.
#               This script differs from "Each_Electrode_Epoched_Power_Wilcoxon_
#               by_Timepoint" in that data were epoched prior to estimating 
#               power rather than after.

# Set up workspace and load data ------------------------------------------

library(dplyr)
library(reshape2)
library(permute)
library(ggplot2)

setwd('/Users/Lindsay/Documents/MATLAB/iEEG/Group Analysis/Power/')
load("All_Subjects_Epoched_Power_CLEAN_3sBuffer_2015-05-29.Rda")


# Initialize output data frame and prepare input data frame ---------------

wilcoxonResults <- data.frame(ElectrodeID = NA,
                              FrequencyBand = NA,
                              Contrast = NA,
                              P = NA)
thisRow <- 1

# Prepare input data
allPowerData <- allPowerData %>%
  filter(TimePoint == "Pre1" | TimePoint == "Tele" | TimePoint == "Post1") %>% # keep only timepoints of interest
  select(TrialNumber, TimePoint, Power:FrequencyBand) 

# Perform analysis for each electrode x frequency band --------------------

for (thisElectrode in 1:nlevels(allPowerData$ElectrodeID)){
  
  # Get all data for this electrode
  electrodeData <- allPowerData %>%
    filter(ElectrodeID == levels(ElectrodeID)[thisElectrode]) %>%
    select(-ElectrodeID) 
  
  for (thisFreqBand in 1:nlevels(allPowerData$FrequencyBand)) {
    
    # Filter data for this frequency band
    frequencyData <- electrodeData %>%
      filter(FrequencyBand == levels(FrequencyBand)[thisFreqBand]) %>%
      select(-FrequencyBand) %>%
      group_by(TrialNumber, TimePoint) %>%
      summarise(Power = mean(Power))
    
    # Cast to wide format
    frequencyDataWide <- frequencyData %>%
      dcast(TrialNumber ~ TimePoint, value.var = "Power")
    
    # Wilcoxon signed-rank tests
    preGtTele  <- wilcox.test(frequencyDataWide$Pre1, frequencyDataWide$Tele, alternative = "greater", paired=TRUE)
    preLtTele  <- wilcox.test(frequencyDataWide$Pre1, frequencyDataWide$Tele, alternative = "less", paired=TRUE)
    teleGtPost <- wilcox.test(frequencyDataWide$Tele, frequencyDataWide$Post1, alternative = "greater", paired = TRUE)
    teleLtPost <- wilcox.test(frequencyDataWide$Tele, frequencyDataWide$Post1, alternative = "less", paired = TRUE)
    
    # Add to summary dataframe
    wilcoxonResults[thisRow, ]     <- c(levels(allPowerData$ElectrodeID)[thisElectrode], 
                                      levels(allPowerData$FrequencyBand)[thisFreqBand], 
                                      "Pre > Tele", 
                                      preGtTele$p.value)
    wilcoxonResults[thisRow + 1, ] <- c(levels(allPowerData$ElectrodeID)[thisElectrode], 
                                      levels(allPowerData$FrequencyBand)[thisFreqBand], 
                                      "Pre < Tele", 
                                      preLtTele$p.value)
    wilcoxonResults[thisRow + 2, ] <- c(levels(allPowerData$ElectrodeID)[thisElectrode], 
                                      levels(allPowerData$FrequencyBand)[thisFreqBand], 
                                      "Tele > Post", 
                                      teleGtPost$p.value)
    wilcoxonResults[thisRow + 3, ] <- c(levels(allPowerData$ElectrodeID)[thisElectrode], 
                                      levels(allPowerData$FrequencyBand)[thisFreqBand], 
                                      "Tele < Post", 
                                      teleLtPost$p.value)
    thisRow <- thisRow + 4
    
  } # end thisFreqBand
  
} # end thisElectrode


# Summarize significant wilcoxon results ----------------------------------

# Reorder frequency band levels
freqBandOrder <- c("Delta", "Theta", "Alpha", "Beta", "Gamma")
wilcoxonResults$FrequencyBand <- factor(wilcoxonResults$FrequencyBand, levels = freqBandOrder)

# Get the counts of the significant results
wilcoxonSigResults <- wilcoxonResults %>%
  filter(P < 0.05) %>%
  group_by(FrequencyBand, Contrast) %>%
  summarise(Count = n())

# Perform binomial test to determine whether counts are higher than expected by chance
binomP <- wilcoxonSigResults %>%
  rowwise() %>%
  do(BinomialTestP = binom.test(.$Count, 
                                nlevels(allPowerData$ElectrodeID), 
                                p = 0.05, 
                                alternative = "greater")$p.value)
wilcoxonSigResults <- cbind(wilcoxonSigResults, binomP) 

# Make a dataframe for the significance markers
sigMarkers <- wilcoxonSigResults %>%
  filter(BinomialTestP < 0.05) %>%
  mutate(Count = Count + 0.2) 

# Plot the bar charts
wilcoxonPlot <- wilcoxonSigResults %>%
  ggplot(aes(x = Contrast, y = Count)) +
  geom_bar(stat = "identity") +
  geom_hline(aes(yintercept = 0.05*nlevels(allPowerData$ElectrodeID), 
                 color = "red")) +
  facet_grid(. ~ FrequencyBand) +
  geom_text(data = sigMarkers, label = "*", size = 18) +
  theme(strip.text.x = element_text(size = 18),
        plot.title = element_text(size = 24, vjust = 2),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 18)) +
  ggtitle("Frequency of Significant Differences in Z-scored log(Power) by Frequency Band")
wilcoxonPlot

# Save the chart
today <- Sys.Date()
ggsave(filename = paste0("Figures/Each_Electrode_Epoched_Power_Wilcoxon_by_Timepoint_Bar_", today, ".png"))

# Plot data for each electrode separately ---------------------------------
for (thisFreqBand in 1:nlevels(allPowerData$FrequencyBand)) {
  electrodeWisePlot <- allPowerData %>%
    filter(FrequencyBand == levels(allPowerData$FrequencyBand)[thisFreqBand]) %>%
    group_by(TimePoint, ElectrodeID) %>%
    mutate(SEM = sd(Power) / sqrt(n() - 1)) %>%
    summarise(Power = mean(Power), SEM = mean(SEM)) %>%
    ggplot(aes(x = TimePoint, y = Power, ymin = Power - SEM, ymax = Power + SEM)) +
    geom_point(size = 4) +
    geom_pointrange() +
    facet_wrap(~ ElectrodeID) +
    ggtitle(paste0("Z-Scored ", levels(allPowerData$FrequencyBand)[thisFreqBand], " Power"))
  
  # Save the chart
  today <- Sys.Date()
  ggsave(filename = paste0("Figures/Each_Electrode_Epoched_", levels(allPowerData$FrequencyBand)[thisFreqBand], "_Power_by_Timepoint_", today, ".png"))
  
}

