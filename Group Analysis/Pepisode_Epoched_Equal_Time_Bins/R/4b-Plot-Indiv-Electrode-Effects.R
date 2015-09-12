# Script Name:  4b-Plot-Indiv-Electrode-Effects.R
# Author:       Lindsay Vass
# Date:         11 September 2015
# Purpose:      This script will plot scatterplots showing pepisode at each time
#               point for each electrode and frequency band.

library(plyr)
library(ggplot2)
library(ggthemes)
library(reshape2)
library(dplyr)


#dir.create('Figures/SingleElectrodeData/')

load('Rda/allCleanData.Rda')

# Individual electrode data -----------------------------------------------

validData <- cleanData %>%
  group_by(ElectrodeID, FrequencyBand, TimePoint) %>%
  summarise(SEM = sd(Pepisode) / sqrt(n()),
            Pepisode = mean(Pepisode))
differenceData <- validData %>%
  dcast(ElectrodeID + FrequencyBand ~ TimePoint, value.var = 'Pepisode') %>%
  mutate(Difference = Tele - ((Pre1 + Post1) / 2)) %>%
  group_by(FrequencyBand) %>%
  select(ElectrodeID, FrequencyBand, Difference) %>%
  inner_join(validData)
differenceData$TimePoint <- revalue(differenceData$TimePoint, c("Pre1" = "Pre", "Tele" = "Teleport", "Post1" = "Post"))

colFun <- colorRampPalette(c("red", "orange", "black", "deepskyblue", "dodgerblue4"))

p <- differenceData %>%
  ggplot(aes(x = TimePoint, 
             y = Pepisode, 
             ymin = Pepisode - SEM, 
             ymax = Pepisode + SEM,
             group = ElectrodeID,
             colour = Difference)) +
  geom_point(size = 5) +
  geom_pointrange() +
  geom_line() +
  scale_color_gradientn(colours = colFun(5)) +
  theme_stata() +
  theme(plot.background = element_rect(fill = "white"),
        text = element_text(size = 30),
        legend.text = element_blank(),
        legend.title = element_text(size = 24),
        axis.title.x = element_blank(),
        axis.title.y = element_text(vjust = 1.5),
        strip.background = element_rect(colour = "black", size = 0.75),
        panel.border = element_rect(colour = "black", size = 0.75, fill = NA),
        panel.grid.major.y = element_line(colour = "dimgray", linetype = "longdash")) +
  ylab(expression("Mean P"["Episode"])) +
  facet_grid(~ FrequencyBand) +
  scale_y_continuous(limits = c(0,1))
p
ggsave('Figures/SingleElectrodeData/Pepisode_by_TimePoint_Scatterplot.png')

# blankP <- differenceData %>%
#   ggplot(aes(x = TimePoint, 
#              y = Pepisode, 
#              ymin = Pepisode - SEM, 
#              ymax = Pepisode + SEM,
#              group = ElectrodeID,
#              colour = Difference)) +
#   geom_blank() + 
#   scale_color_gradientn(colours = colFun(5)) +
#   theme_stata() +
#   theme(plot.background = element_rect(fill = "white"),
#         text = element_text(size = 30),
#         legend.text = element_blank(),
#         legend.title = element_text(size = 24),
#         axis.title.x = element_blank(),
#         axis.title.y = element_text(vjust = 1.5),
#         strip.background = element_rect(colour = "black", size = 0.75),
#         panel.border = element_rect(colour = "black", size = 0.75, fill = NA),
#        # panel.background = element_rect(fill = "black"),
#         panel.grid.major.y = element_line(colour = "dimgray", linetype = "longdash")) +
#   ylab(expression("Mean P"["Episode"])) +
#   facet_grid(~ FrequencyBand) +
#   scale_y_continuous(limits = c(0,1))
# blankP
# ggsave('Figures/SingleElectrodeData/Pepisode_by_TimePoint_Scatterplot_BLANK.png')