# Analize data hosted in TriloMorph

Geomorphometric data in **TriloMorph** is intended to be analyzed in R using the [functions](/TriloMorph-funs.R) developed to read the data and the geomorph package[^N]. You can still analyze TriloMorph data in any other software, as long as it is able to read both XML-based format for shapes digitized with the 'StereoMorph' package[^1] and TPS-based format for shapes digitized with tpsDig2[^2].

## Accessing landmark data

The first step to access the data in the latest version of TriloMorph hosted in github is to download all shape files. There are two options for this, you can 

   * download the whole repository (check [this](https://www.gitkraken.com/learn/git/github-download#how-to-download-a-github-repository) for further instruction on downloading a whole github repoository). Note that the repository hosts both shape files and specimens pictures. *We suggest to download the whole repository only if you want to double-check the specimens' landmark configurations.*

**If you just want to analyse TriloMorph data**, we suggest to download the respective folder containing the shape files. To do so we suggest you to follow the following steps
   * go to [this site](https://download-directory.github.io/)
   * copy and past the path for the desired shape files:
       * for cephala the path is `https://github.com/balsedie/trilomorph/tree/main/Cephala/landmarks`
       * for pygidia the path is `https://github.com/balsedie/trilomorph/tree/main/Pygidia/landmarks`
   * download the zip file to your computer and unzip it.

## Using TriloMorph functions

Trilomorph, in addition to hosting geometric morphometric data, supplies additional R functions that where developed to overcome some potential problems relative to the nature of the data hosted in the database. Therefore we provide a set of R functions that allow you to
  * Analyze both StereoMorph XML-based shape files and tpsDig2 TPS-based files. 
  * Read shape files with different number of missing landmarks, define a landmark template for the analysis, and discard shape files that do not have all the desired landmarks.[^3]
  * Resample semilandmarks, as TPS shape files have fixed semilandmarks but Steremorph shape files do not fix semi-landmarks _a priori_.

To access the functions you have to copy and paste the following line in your R console.

    source(https://raw.githubusercontent.com/balsedie/trilomorph/main/TriloMorph-funs.R)

Once you've uploaded the fuctions in R, you can access the TriloMorph metadata.

    trilomorph_metadata <- yaml_read(https://raw.githubusercontent.com/balsedie/trilomorph/main/trilomorph.yaml)

you can then access the TriloMorph shape files that you've downloaded previously,
    
    #define the vector of specimens' IDs to read the shape files
    fids <- trilomoph_metadata$ID
    
    #set the path to the unzipped folder with the shape files
    dirlm <- "~path/to_the/downloaded/folder" 
    
    #define the desired landmark configuration: 2 dimensions, 16 landmarks, 4 curves (12, 20, 20 and 20 semilandmarks respectively)
    nlms <- c(2, 16, 12, 20, 20, 20)

    #now read the shape files. Note that sufix = "_C" for cephala and "_P" for pygidia.
    lmks <- shapRead(fids, sufix = "_C", subdir = dirlm)
    
    #remove specimens that don't fit the desired landmark configuration.
    ldks <- shapFix(lmks, nlms)

<sup>Comment: The function `shapFix` will warn the user and automatically remove specimens with landmark data not fitting the desired template. For example, we expect 4 curves of semilandmarks; but some species do not show these four structures and hence have not all of them landmarked. `shapFix` will remove these specimens.</sup>

<sup>Note that the current version of `shapFix` does not let you choose a custom subset of landmarks or curves, it just removes specimes that do not fit the full configuration. We are planning to update the function in order to improve its versatility allowing to choose among any landmark configuration.</sup>


and now you can use the geomorph[^1] R package to continue with the general procrustes superimposition, construct the morphospace and further analysis.

    #first load the geomorph package
    library(geomorph)
    
    #Superimpose by GPA.
    gpan <- geomorph::gpagen(ldks, Proj = TRUE, PrinAxes = FALSE)
    
    # Construct the morphospace of selected configurations.
    # This morphological space is reconstructed by means of a principal components analysis (PCA).
    pcan <- geomorph::gm.prcomp(gpan$coords)
    
    #you can now plot the morphospace rather easily
    geomorph:::plot.gm.prcomp(pcan, main = "PCA-based morphospace", pch = 21, bg = "lightgray", cex = 1.5)
    mtext(paste0("n = ", nrow(pcan$x)), side = 3, adj = 1, font = 3)



### References
[^N]: Adams D.C, Collyer M.L. and Kaliontzopoulou A. 2020. Geomorph: Software for geometric morphometric analyses. R package version 3.2.1. https://cran.r-project.org/package=geomorph.
[^1]: Olsen A.M. and Westneat M.W. 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up. Methods in Ecology and Evolution 6:351-356. DOI: [10.1111/2041-210X.12326](https://doi.org/10.1111/2041-210X.12326).
[^2]: Rohlf F.J. 2015. The tps series of software. Hystrix, the Italian Journal of Mammalogy 26:9-12. DOI: [10.4404/hystrix-26.1-11264](https://doi.org/10.4404/hystrix-26.1-11264)
[^3]: Because Trilomorph is intended to cover the whole trilobite phylogeny, missing landmarks are not necessarily related to incomplete specimens but to the absence of certain traits. For example, to analyze both sighted and blind trilobites, one needs to remove landmarks 8, 9 and 14 (see [figure](https://figshare.com/ndownloader/files/40535717/preview/40535717/preview.jpg)).


