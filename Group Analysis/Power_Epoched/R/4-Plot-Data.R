# Script Name:  4-Plot-Data.R
# Author:       Lindsay Vass
# Date:         3 June 2015
# Purpose:      This script will plot the results generated by "3-Analyze-Data.R"

library(ggplot2)
library(dplyr)

dir.create('Figures')

# Plot group data ---------------------------------------------------------

wilcoxonPlot <- wilcoxonSigResults %>%
  ggplot(aes(x = Contrast, y = Count)) +
  geom_bar(stat = "identity") +
  geom_hline(aes(yintercept = 0.05*nlevels(cleanData$ElectrodeID), 
                 color = "red")) +
  facet_grid(. ~ FrequencyBand) +
  geom_text(data = sigMarkers, label = "*", size = 18) +
  theme(strip.text.x = element_text(size = 18),
        plot.title = element_text(size = 24, vjust = 2),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 18)) +
  scale_y_continuous(limits = c(0, nlevels(cleanData$ElectrodeID))) + 
  ggtitle("Frequency of Significant Differences in Z-Scored log(Power) by Frequency Band")

# Save the chart
today <- Sys.Date()
ggsave(filename = paste0("Figures/Histogram_Power_By_TimePoint_", today, ".png"))


# Plot electrode-wise data ------------------------------------------------

for (thisFreqBand in 1:nlevels(cleanData$FrequencyBand)) {
  electrodeWisePlot <- cleanData %>%
    filter(FrequencyBand == levels(cleanData$FrequencyBand)[thisFreqBand]) %>%
    filter(TimePoint == "Pre1" | TimePoint == "Tele" | TimePoint == "Post1") %>%
    group_by(TimePoint, ElectrodeID) %>%
    mutate(SEM = sd(Power) / sqrt(n() - 1)) %>%
    summarise(Power = mean(Power), SEM = mean(SEM)) %>%
    ggplot(aes(x = TimePoint, y = Power, ymin = Power - SEM, ymax = Power + SEM)) +
    geom_point(size = 4) +
    geom_pointrange() +
    facet_wrap(~ ElectrodeID, scales = "free") +
    ggtitle(paste0(levels(cleanData$FrequencyBand)[thisFreqBand], " Power By TimePoint"))
  
  electrodeWisePlot
  
  # Save the chart
  today <- Sys.Date()
  ggsave(filename = paste0("Figures/Scatterplot_Each_Electrode_Power_By_TimePoint_", levels(cleanData$FrequencyBand)[thisFreqBand], "_", today, ".png"))
  
}

