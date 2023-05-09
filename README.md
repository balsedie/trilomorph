# Trilomorph
## About the database
TriloMorph is an openly accessible database for morpho-geometric information of trilobites, the main Palaeozoic group of marine arthropods[^1]. The databased records information on If you are willing to use the database, we strongly suggest to download the stable release that is accesible in the Digital repository of the Universidad Nacional de Córdoba[^2].
The purpose of this repository is to allow the constant input of new data into the database. Below we explain step by step the procedure to upload new data to Trilomorph:

### Specimen
- [ ] select the specimen

<sup>specimens included in the database have to be housed in official collections (preferentially having a collection number) or illustrated in the literature. Specimens can be cephala and/or pigydia. Be sure that the selected specimen is **not distored**, for cephala make sure that free cheeks are in place and not slighly disarticulated.</sup>

- [ ] select the picture

<sup>the picture used for the landmarking (see below) has to be a *strictly dorsal* picture of the specimen, either cephalon or pigidia. If the specimen is articulated make sure that both parts are photographed in dorsal view, if not use different pictures for each part.</sup>

- [ ] name the picture

<sup>the picture has to be named using the specimen's collection acronym and number. The file name has to have the suffix _C when it is the cephalon, and _P for the pygidium. **Important:** If a single specimen and picture is used to landmark both cephalon and pygidium, two different files need to be created and named one for the pygidum (_P) and one for the cephalon (_C) </sup>

### Landmarking
- [X] select the specimen
- [X] select the picture
- [x] name de picture
- [ ] landmark the specimen

<sup>the specimen needs to be landmarked following the protocol in Serra et al[^1], which is explained in figure 1 </sup>

<sup>You can use different landmarking program, namely tpsDig[^3], geomorph package for R[^4], StereoMorph package for R[^5]. </sup>

  
## Licence:
All material is distributed under Creative Commons Attribution-Non Commercial-Share Alike 4.0 International [CC BY-NC-SA 4.0] licence terms[^N]. 

<!-- References -->
[^1]: Serra F., Balseiro D., Monnet C., et al. submitted. TriloMorph: a dynamic and collaborative database for morphogeometric information of trilobites. Scientific Data.
[^2]: Latest and previous stable releases are available at https://rdu.unc.edu.ar/handle/11086/nnnnnnn
[^3]: cita tpsDig 
[^4]: Adams D.C, Collyer M.L. and Kaliontzopoulou A. 2020. Geomorph: Software for geometric morphometric analyses. R package version 3.2.1. https://cran.r-project.org/package=geomorph.
[^5]: Olsen A.M. and Westneat M.W. 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up. Methods in Ecology and Evolution 6:351-356. DOI: 10.1111/2041-210X.12326.
[^N]: https://creativecommons.org/licenses/by-nc-sa/4.0/
