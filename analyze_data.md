# Analize data hosted in TriloMorph

Geomorphometric data in **TriloMorph** is intended to be analyzed in R using the [functions](/TriloMorph-funs.R) developed to read the data and the geomorph package[^N]. You can still analyze TriloMorph data with any other software, as long as it can read XML-based format for shapes digitized with the StereoMorph package[^1] and TPS-based format for shapes digitized with tpsDig2[^2].

## Accessing shape files

The first step to access the data in the latest version of TriloMorph hosted in github is to download all shape files. There are two options for this,

you can download the whole repository (check [this](https://www.gitkraken.com/learn/git/github-download#how-to-download-a-github-repository) for further instruction on downloading a whole github repository). However, because the repository hosts both shape files and specimens pictures and whole repository size might be large. *We suggest to download the whole repository only if you want to double-check the specimens' landmark configurations.*

**If you just want to analyse TriloMorph data**, we suggest to download the respective folder containing the shape files. To do so, we suggest you to follow the following steps,
   * go to [this site](https://download-directory.github.io/)
   * copy and paste the path for the desired shape files:
       * for cephala the path is `https://github.com/balsedie/trilomorph/tree/main/Cephala/landmarks`
       * for pygidia the path is `https://github.com/balsedie/trilomorph/tree/main/Pygidia/landmarks`
       * for replicated configurations used in the error test `https://github.com/balsedie/trilomorph/tree/main/Cephala/replicates`
   * download the zip file to your computer and unzip it in a new folder.
  
  <sup> note that if you want to run the error test performed in Serra et al.[^6], you need to download *both the cephala and the replicated* configurations</sup>

## Using TriloMorph functions

Trilomorph, in addition to hosting geometric morphometric data, supplies additional R functions that were developed to overcome some potential problems relative to the nature of the data hosted in the database. Therefore we provide a set of R functions that allow you to
  * Analyze both StereoMorph XML-based shape files and tpsDig2 TPS-based files. 
  * Read shape files with different number of missing landmarks, define a landmark template for the analysis, and discard shape files that do not have all the desired landmarks.[^3]
  * Resample semilandmarks, as TPS shape files have fixed semilandmarks but StereoMorph shape files do not fix semi-landmarks _a priori_.

Below we list a step by step explanation to access and analyze the data.

To access the functions you have to copy and paste the following line in your R console.

    source("https://raw.githubusercontent.com/balsedie/trilomorph/main/TriloMorph-funs.R")

Once you've uploaded the fuctions in R, you can access the TriloMorph metadata.

    #access TriloMorph metadata
    trilomorph_metadata <- yaml_read(file="https://raw.githubusercontent.com/balsedie/trilomorph/main/trilomorph.yaml")

    #keep only information on specimens that have cephalon information. 
    #In case you want to analyse pygidia, you just need to change cephalon for pygidium in the line below
    trilomorph_metadata <- trilomorph_metadata[which(trilomorph_metadata$morphology.cephalon),]
    
you can then access the TriloMorph shape files that you've downloaded previously,
    
    #define the vector of specimens' IDs to read the shape files
    fids <- trilomorph_metadata$ID
    
    #set the path to the unzipped folder with the shape files
    dirlm <- "~path/to_the/downloaded/folder" 
    
    #define the desired landmark configuration: 2 dimensions, 16 landmarks, 4 curves (12, 20, 20 and 20 semilandmarks respectively)
    nlms <- c(2, 16, 12, 20, 20, 20)

    #read the shape files. Note that sufix = "_C" is for cephala, change it to "_P" if analysing pygidia.
    lmks <- shapRead(fids, sufix = "_C", subdir = dirlm)
    
    #remove specimens that don't fit the desired landmark configuration.
    ldks <- shapFix(lmks, nlms)

<sup>The function `shapFix` will warn the user and automatically remove specimens with landmark data not fitting the desired template. For example, we expect 4 curves of semilandmarks; but some species do not show these four structures and hence have not all of them landmarked. `shapFix` will remove these specimens.</sup>

<sup>Additionally, `shapFix` lets you easily change the number of semilandmarks in each curve. You only need to change the line `nlms <- c(2, 16, 12, 20, 20, 20)` with the number of desired semilandmarks for each curve (last four numbers).

<sup>Note that the current version of `shapFix` does not let you choose a custom subset of *landmarks* or *curves*, it just removes specimes that do not fit the full configuration. We are planning to update the function in order to improve its versatility allowing to choose among any subset of landmarks and curves.</sup>


now you can use the geomorph[^N] R package to continue with the general procrustes superimposition, construct the morphospace and further analysis.

    #first load the geomorph package
    library(geomorph)
    
    #Superimpose by GPA.
    gpan <- geomorph::gpagen(ldks, Proj = TRUE, PrinAxes = FALSE)
    
    # Construct the morphospace of selected configurations.
    # This morphological space is reconstructed by means of a principal components analysis (PCA).
    pcan <- geomorph::gm.prcomp(gpan$coords)
    
    #you can now plot the morphospace very easily
    geomorph:::plot.gm.prcomp(pcan, main = "PCA-based morphospace", pch = 21, bg = "lightgray", cex = 1.5)
    mtext(paste0("n = ", nrow(pcan$x)), side = 3, adj = 1, font = 3)

## Further analyses

`shapSumVar` function, also available in TriloMorph, allows the calculation of the classic Sum of Variances disparity measure and the estimation of bootstrapped confidence intervals.

Further analysis are expected to be performed by joining TriloMorph morphometric data with occurrence data obtained from the Paleobiology Database[^4] of the Geobiology Database[^5].

As an worked example of how to analyse TriloMorph along with information retrieved from the PDBD, you can check the [R script](/TriloMorph-workflow.R) that runs all analyses performed in Serra et al[^6]. These analyses include the construction of the morphospace, a disparity curve and the test for errors in landmark digitization. 

In case you just want to replicate the exact analyses in Serra et al.[^6], you can simply run the following R script
    
    # Define the working directory
    # IMPORTANT: Make sure that within this working directory you have the cephala 'landmark' 
    # and 'replicates' folder containing all shape files that you downloaded.
    setwd("type/the/path/to/the/folder")

    # Run the R script for the whole analysis
    source("https://raw.githubusercontent.com/balsedie/trilomorph/main/TriloMorph-workflow.R")

As a generalized framework, the expected workflow for further analyses is described in the following figure

![workflow](https://figshare.com/ndownloader/files/40535714/preview/40535714/preview.jpg)

### References
[^N]: Adams D.C, Collyer M.L. and Kaliontzopoulou A. 2020. Geomorph: Software for geometric morphometric analyses. R package version 3.2.1. https://cran.r-project.org/package=geomorph.
[^1]: Olsen A.M. and Westneat M.W. 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up. Methods in Ecology and Evolution 6:351-356. DOI: [10.1111/2041-210X.12326](https://doi.org/10.1111/2041-210X.12326).
[^2]: Rohlf F.J. 2015. The tps series of software. Hystrix, the Italian Journal of Mammalogy 26:9-12. DOI: [10.4404/hystrix-26.1-11264](https://doi.org/10.4404/hystrix-26.1-11264)
[^3]: Because Trilomorph is intended to cover the whole trilobite phylogeny, missing landmarks are not necessarily related to incomplete specimens but to the absence of certain traits. For example, to analyze both sighted and blind trilobites, one needs to remove landmarks 8, 9 and 14 (see [figure](https://figshare.com/ndownloader/files/40535717/preview/40535717/preview.jpg)).
[^4]: https://paleobiodb.org
[^5]: http://www.geobiodiversity.com
[^6]: Serra F., Balseiro D., Monnet C., et al. submitted. A dynamic and collaborative database for morphogeometric information of trilobites. Scientific Data.


