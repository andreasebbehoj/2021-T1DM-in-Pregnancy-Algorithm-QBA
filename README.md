# 2021-T1DM-in-Pregnancy-Algorithm-QBA
Stata code for running quantitative bias analysis for:
Validation of Danish registry-cases of type 1 diabetes in women giving live birth using a clinical cohort as gold standard
Endocrinology, Diabetes & Metabolism
Accepted 13/9-22

### Purpose
The aim of the paper was to develop a series of algorithms that could identify live births of mothers with type 1 diabetes mellitus (:T1DM) using Danish health registry data. The algorithms' efficacies, in terms of positive predictive value (:PPV) and completeness (i.e. sensitivity), were tested against a cohort of clinically confirmed T1DM live births (the EPICOM cohort). The EPICOM study did not include all T1DM births in Denmark.

The purpose of this quantitative bias analysis (QBA) was to determine how using the incomplete EPICOM cohort as gold standard, might affect the algorithms' PPV and completeness.

### Assumptions behind QBA analysis
The assumptions behind the QBA are briefly mentioned in comments within the code. Please see the published manuscript and supplementary for more details on the EPICOM cohort, the purpose of the QBA, and the assumptions behind the QBA.

### Instructions
Run 0_master.do to reproduce QBA analysis. Requires Stata Statistical Software to run. Developed in Stata version 16.1.

Output of the code can be found in the log file and in the respective output folders (data, figures and tables).

### Dependencies
Code requires the [*grstyle*](http://repec.sowi.unibe.ch/stata/grstyle/index.html) package for creating graphs.

To install:
```
ssc install grstyle, replace
ssc install palettes, replace
ssc install colrspace, replace
```
