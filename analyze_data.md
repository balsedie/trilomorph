# Analize data hosted in Trilomorph

Geomorphometric data in **Trilomorph** is intended to be analyzed in R using the [functions](/TriloMorph-funs.R) developed to read the data and the geomorph package[^N]. You can still analyze Trilomorph data in any other software, as long as it is able to read both XML-based format for shapes digitized with the 'StereoMorph' package[^1] and TPS-based format for shapes digitized with tpsDig2[^2].

## Trilomorph functions

Trilomorph, in addition to hosting geometric morphometric data, supplies additional R functions that where developed to overcome some potential problems relative to the nature of the data hosted in the database. Therefore we provide a set of R functions that allow you to
  * Analyze both StereoMorph XML-based shape files and tpsDig2 TPS-based files. 
  * Read shape files with different number of missing landmarks, define a landmark template for the analysis, and discard shape files that do not have all the desired landmarks.[^3]
  * Resample semilandmarks, as TPS shape files have fixed semilandmarks but Steremorph shape files do not fix semi-landmarks _a priori_.

The data can be read with the 


### References
[^N]: Adams D.C, Collyer M.L. and Kaliontzopoulou A. 2020. Geomorph: Software for geometric morphometric analyses. R package version 3.2.1. https://cran.r-project.org/package=geomorph.
[^1]: Olsen A.M. and Westneat M.W. 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up. Methods in Ecology and Evolution 6:351-356. DOI: [10.1111/2041-210X.12326](https://doi.org/10.1111/2041-210X.12326).
[^2]: Rohlf F.J. 2015. The tps series of software. Hystrix, the Italian Journal of Mammalogy 26:9-12. DOI: [10.4404/hystrix-26.1-11264](https://doi.org/10.4404/hystrix-26.1-11264)
[^3]: Because Trilomorph is intended to cover the whole trilobite phylogeny, missing landmarks are not necessarily related to incomplete specimens but to the absence of certain traits. For example, to analyze both sighted and blind trilobites, one needs to remove landmarks 8, 9 and 14 (see [figure](https://figshare.com/ndownloader/files/40535717/preview/40535717/preview.jpg)).


