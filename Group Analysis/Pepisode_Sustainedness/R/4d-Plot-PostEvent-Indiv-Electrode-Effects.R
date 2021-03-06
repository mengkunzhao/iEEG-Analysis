# Date:     14 September 2015
# Purpose:  This script will plot the difference in post-teleporter-entry 
#           oscillatory event duration for navigation vs teleporter.

library(dplyr)
library(ggplot2)
library(ggthemes)

load('Rda/allAnalyzedData_COIN.Rda')
load('Rda/allCleanData.Rda')

# Functions ---------------------------------------------------------------

facetLabeller <- function(variable, value) {
  if (variable == "TimeType") {
    return(facetTimeLabels[value])
  } else{
    return(facetFreqLabels[value])
  }
}

meanPostEventOscDuration <- function(dataFrame, eventTime, trialTimeType) {
  output <- dataFrame %>%
    filter(Onset < eventTime & Offset > eventTime & TrialTimeType == trialTimeType) %>%
    mutate(PostEventDuration = Offset - eventTime) %>%
    group_by(ElectrodeID, FrequencyBand, RealTrialNumber) %>%
    summarise(MeanPostEventDuration = mean(PostEventDuration))
}


# Analyze data ------------------------------------------------------------

navNtPostEntryDur <- meanPostEventOscDuration(navSustain, 0, "NT") %>%
  mutate(TimeType = "NT",
         Condition = "Navigation")
navFtPostEntryDur <- meanPostEventOscDuration(navSustain, 0, "FT") %>%
  mutate(TimeType = "FT",
         Condition = "Navigation")

teleNtPostEntryDur <- meanPostEventOscDuration(teleSustain, 0, "NT") %>%
  mutate(TimeType = "NT",
         Condition = "Teleportation")
teleFtPostEntryDur <- meanPostEventOscDuration(teleSustain, 0, "FT") %>%
  mutate(TimeType = "FT",
         Condition = "Teleportation")
allPostEntryData <- rbind(navNtPostEntryDur, 
                          navFtPostEntryDur, 
                          teleNtPostEntryDur, 
                          teleFtPostEntryDur) %>%
  group_by(ElectrodeID, FrequencyBand, Condition) %>%
  filter(n() > 5) %>%
  summarise(MeanDuration = mean(MeanPostEventDuration),
            SEM = sd(MeanPostEventDuration) / sqrt(n()))
navData <- allPostEntryData %>%
  filter(Condition == "Navigation")
teleData <- allPostEntryData %>%
  filter(Condition == "Teleportation")

validData <- inner_join(navData, teleData, by = c('ElectrodeID', 'FrequencyBand')) %>%
  mutate(Difference = (MeanDuration.y - MeanDuration.x)) %>%
  select(ElectrodeID, Difference, FrequencyBand) %>%
  inner_join(allPostEntryData)


# Make plot of individual electrode effects -------------------------------

colFun <- colorRampPalette(c("red", "orange", "black", "deepskyblue", "dodgerblue4"))

p <- validData %>%
  ggplot(aes(x = Condition, 
             y = MeanDuration, 
             ymin = MeanDuration - SEM, 
             ymax = MeanDuration + SEM,
             group = ElectrodeID,
             colour = Difference)) +
  geom_point(size = 5) +
  geom_pointrange() +
  geom_line() +
  scale_color_gradientn(colours = colFun(5)) +
  theme_stata() +
  theme(plot.background = element_rect(fill = "white"),
        text = element_text(size = 24),
        legend.text = element_blank(),
        legend.title = element_text(size = 18),
        axis.title.x = element_blank(),
        axis.title.y = element_text(vjust = 1.5),
        strip.background = element_rect(colour = "black", size = 0.75),
        panel.border = element_rect(colour = "black", size = 0.75, fill = NA),
        panel.grid.major.y = element_line(colour = "dimgray", linetype = "longdash")) +
  ylab("Mean Duration (ms)") +
  facet_grid( ~ FrequencyBand)
#dir.create('Figures/SingleElectrodeEventDur')
ggsave('Figures/SingleElectrodeEventDur/PostEntryDuration_Scatter.pdf', useDingbats = FALSE, width = 16, height = 8)

# plot for each electrode
patientIDs <- data.frame(UCDMC = c('UCDMC13', 'UCDMC14', 'UCDMC15'),
                         P = c('P1', 'P2', 'P3'))
validData$ElectrodeID <- factor(validData$ElectrodeID)
for (thisElec in 1:nlevels(validData$ElectrodeID)) {
  elec <- levels(validData$ElectrodeID)[thisElec]
  elecSplit <- strsplit(elec, '_')
  session <- ifelse(elecSplit[[1]][2] == 'TeleporterA', 'Session 1', 'Session 2')
  pTitle <- paste0(patientIDs$P[which(patientIDs$UCDMC == elecSplit[[1]][1])], ' ', session, ' ', elecSplit[[1]][3])
  
  p <- validData %>%
    filter(ElectrodeID == elec) %>%
    ggplot(aes(x = Condition, 
               y = MeanDuration, 
               ymin = MeanDuration - SEM, 
               ymax = MeanDuration + SEM,
               group = ElectrodeID)) +
    geom_point(size = 5) +
    geom_pointrange() +
    geom_line() +
    theme_stata() +
    theme(plot.background = element_rect(fill = "white"),
          text = element_text(size = 24),
          legend.text = element_blank(),
          legend.title = element_text(size = 18),
          axis.title.x = element_blank(),
          axis.title.y = element_text(vjust = 1.5),
          strip.background = element_rect(colour = "black", size = 0.75),
          panel.border = element_rect(colour = "black", size = 0.75, fill = NA),
          panel.grid.major.y = element_line(colour = "dimgray", linetype = "longdash")) +
    ylab("Mean Duration (ms)") +
    facet_grid( ~ FrequencyBand) +
    ggtitle(pTitle)
  p
  fileName <- paste0('Figures/SingleElectrodeEventDur/EachElectrodeSeparate/', elec, '_Event_Dur_Scatterplot.pdf')
  ggsave(fileName, useDingbats = FALSE, width = 16, height = 8)
}

numElec <- validData %>%
  select(ElectrodeID, FrequencyBand) %>%
  unique() %>%
  group_by(FrequencyBand) %>%
  summarise(Count = n())