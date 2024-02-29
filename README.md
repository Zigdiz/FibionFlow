w# FibionFlow
Fibion Flow is an R markdown code to process data collected from the Fibion Research device. It includes a validated algorithm to detect sleep and non-wear periods and to analyse sitting and physical activity durations and energy expenditures from the valid waking hours. Additional properties include visual representation of the algorithm performance, and data segmentation based on custom timestamps, e.g. for analysing sitting and physical activity metrics for working and non-working hours. 

## Features of FibionFlow
- Automated valid waking wear isolation from time in bed and prolonged non-wear
- Adaptable parameters to customize algorithm thresholds
- Adaptable wear time criteria
- Visualisation of valid waking wear vs. sleep and non-wear with activiyt intensity and off periods (can be exported as pdf files)
- Data segmentation by customized timestamps (can be imported as Microsoft Excel files)

## Outputs of FibionFlow

### Daily summaries of:
 - Waking wear time
 - Sitting time
 - Standing time
 - Walking time
 - Cycling time
 - High-intensity/running time
 - Sitting MET-minutes
 - Standing MET-minutes
 - Walking MET-minutes
 - Cycling MET-minutes
 - High-intensity/running MET-minutes
 - Sitting mean METs
 - Standing mean METs
 - Walking mean METs
 - Cycling mean METs
 - High-intensity/running mean METs
 - Light-intensity activity duration
 - Moderate-intensity activity duration
 - Vigorous-intensity activity duration
 - Moderate-to-vigorous-intensity activity duration
 - Below-walking-intensity activity duration (relative-to-walking METs intensity)
 - Above-walking-intensity activity duration (relative-to-walking METs intensity)

### Sitting and activity-bout summaries of:
 - Bout duration
 - Bout MET-minutes
 - Bout mean METs
 - Bout activity duration (at >1.5 METs, e.g. to calculate duration of active sitting)

### Sitting and activity accumulation patterns:
 - Number of sitting bouts
 - Number of activity bouts
 - Number of <10 min, 10-30 min and >30 min sitting bouts
 - Number of <10 min, 10-30 min and >30 min activity bouts
 - Sitting bout mean duration
 - Activity bout mean duration
 - Duration at <10 min, 10-30 min and >30 min sitting bouts
 - Duration at <10 min, 10-30 min and >30 min activity bouts
 - Usual sitting bout duration
 - Usual activity bout duration
 - Active sitting (>1.5 METs) duration
 - Active sitting (>1.5 METs) proportion of total sitting

The daily summaries are typically used for overall sitting and activity reporting. Moreover, the bout summaries can be used to report sitting and activity accumulation patterns.

FibionFlow has been developed by Arto Pesola (director of Active Life Lab, South-Eastern Finland University of Applied Sciences and co-founder of Fibion Inc).
