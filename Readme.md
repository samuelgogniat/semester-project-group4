# Proposal for Semester Project

**Patterns & Trends in Environmental Data / Computational Movement
Analysis Geo 880**

| Semester:      | FS23                                     |
|:---------------|:---------------------------------------- |
| **Data:**      | POSMO  |
| **Title:**     | Implementation of a basic analysis tool for travel mode detection in R   |
| **Student 1:** | Severin Aicher                    |
| **Student 2:** | Samuel Gogniat                    |

## Abstract 
This research project aims to implement a basic data science procedure in R to identify travel modes from mobile GPS data. The study will investigate different criteria such as speed, acceleration or location and use different features such as mean, minimum and maximum values for comparison with experimentally defined thresholds to achieve accurate mode of transport identification.

## Research Questions
1. How can a basic analysis tool for travel mode detection from GPS data be implemented in R and what accuracy is achieved with it?
2. What are the most effective criteria, features and thresholds for the detection of different travel modes?

## Results / products
We want to implement a basic data science procedure to identify modes of transportation (walking, cycling, car, bus, train) from mobile GPS data by testing and using various criteria such as speed, acceleration, or specialized routes with different features and threshold values. Therefore, our product will be a simple algorithm to analyse GPS records from POSMO regarding transportation mode. 

## Data
As a first step, we will use a subset of the POSMO dataset containing selected days where all five modes of transportation were used. In this dataset, manually corrected transportation mode assignments were made to ensure accuracy. Based on this data a first, simple procedure will be developed to explore different criteria and thresholds. In the next step, we will apply this procedure to the entire manually preprocessed POSMO dataset. This will allow us to test and improve the accuracy of the procedure by comparing the identified modes of transport with the modes of transport set in the POSMO system. The results will be tested on unprocessed datasets and validated for plausibility. To allocate train and bus rides, additional datasets that represent the train and bus networks must be found. Finally, the PatTrEnvData class dataset can be used as a larger sample to test the procedure. 

## Analytical concepts
As conceptual model a continuous, entity-based movement space will be assumed, in which trajectories can be modelled as a series of unconstrained, time-stamped fixes. Speed and acceleration will be calculated using a temporal window and can therefore be considered a focal or interval function. Further, for identifying train bus travels, the spatial analysis method of buffer-calculation for proximity analysis or various similarity measures could be explored. 

## R concepts
R and RStudio will be used, and the code will be scripted in a quarto-document within a git-hub repository.  The additional use of several packages as “readr”, ”dyplr”, “sf” for spatial analysis or ”ggplot2” for visualisations will be complemented as needed. The procedure may be scripted as an if-else-loop. 

## Risk analysis
The biggest difficulty will probably be identifying train and bus travels. For trains, maps with rail data could be sufficient by examining the trajectories for their proximity or similarity to trail networks. However, it may be particularly difficult to distinguish between bus and car journeys, as they use the same infrastructure and thus usually have similar movement patterns. Different criteria must be tried out here. One possibility for solving this problem could be the exploitation of the stop and go behaviour of buses, which could be recognisable in the acceleration. Another solution may be the usage of similarity measures.

In general, choosing the conceptual model of a continuous movement space with unconstrained trajectories could limit ourselves in the determination of train and bus rides, as additional information regarding the spatial context of the movement may be required here. An improved approach could involve incorporating a network space with restricted movements in roads or rails. However, implementing this approach would be more complex and less suitable for generalizing to other data sets, as it heavily relies on the availability of public transport data. Therefore, if feasible, we want to limit ourselves in this study to the first model.

## Questions? 
-	Where to get background data of the road/rail-network?
