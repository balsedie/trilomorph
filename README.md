![TriloMorph](https://figshare.com/ndownloader/files/41122841/preview/41122841/preview.jpg)

## About the database
TriloMorph is an openly accessible database for the morpho-geometric information of trilobites, the main Palaeozoic group of marine arthropods[^1]. The database records raw landmark and semilandmark information on trilobite cephala and pygidia following the protocol proposed by Serra et al[^1]. 

The purpose of this repository is to allow the constant input of new data into the database. If you are willing to use the database for analysis, we strongly suggest downloading the stable release that is accessible in the Digital repository of the Universidad Nacional de Córdoba and Zenodo[^2]. 

Further explanation about the R functions and how to download and analyze data hosted in this repository can be found [here](/analyze_data.md)

If you would like to help with the maintenance of the dataset and file revision, do not hesitate to contact us[^6]

Latest stable release [![DOI](https://zenodo.org/badge/637921273.svg)](https://zenodo.org/badge/latestdoi/637921273)

## Entering new data
You can enter more than one specimen at a time. The following explanation is for a single specimen, but uploding several specimens is possible as long as you include all specimens' metadata, shape files and pictures in the same commit (see below for detailed explanation).

**Below we explain step by step the procedure to upload new data to TriloMorph:**

### Specimen
- [ ] select the specimen

  <sup>Specimens included in the database have to be housed in official collections (preferentially having a collection number) or illustrated in the scientific literature. Specimens can be cephala and/or pigydia. Be sure that the selected specimen is **not distorted**, for cephala make sure that free cheeks are in place and not slightly disarticulated.</sup>

- [ ] select the picture

  <sup>The picture used for the landmarking (see below) has to be a ***strictly dorsal*** picture of the specimen, either cephalon or pygidium. If the specimen is articulated make sure that both parts are photographed in dorsal view, if not use different pictures for each part.</sup>
  
  <sup>**IMPORTANT**: each picture has to include a graphical scale. If it is missing in the original publication, include one. You can easily include graphical scale bars with software such as ImageJ[^7]</sup>
  
  <sup>Accepted formats are PNG and JPG/JPEG. Please avoid using TIFF files</sup>

- [ ] name the picture

  <sup>The picture has to be named using the specimen's collection acronym and number. The file name must have the suffix _C when it is the cephalon, and _P for the pygidium. **Important:** If a single specimen and picture is used to landmark both cephalon and pygidium, two different files need to be created and named, one for the pygidum (_P), and one for the cephalon (_C) </sup>

### Landmarking
- [X] select the specimen
- [X] select the picture
- [x] name the picture
- [ ] landmark the specimen

  <sup>The specimen needs to be landmarked following the protocol in Serra et al[^1], which is explained in [figure 2](https://figshare.com/ndownloader/files/40535717/preview/40535717/preview.jpg) and [table 1](https://figshare.com/ndownloader/files/40538384/preview/40538384/preview.pdf)</sup>

  <sup>You can use various landmarking software, namely tpsDig2[^3], geomorph package for R[^4], and StereoMorph package for R[^5]. </sup>
  
  <sup>If you are using the `digitizeImages()` function from the StereoMorph package[^5], you can use our templates for landmarks and curves for [cephala](Cephala/curve.txt) and [pygidia](Pygidia/curve.txt).</sup>
  
  <sup>Please check that the final shape file is a XML-type (.txt)[^5] or TPS-type (.tps)[^3] file with the same name as the image file and their extension in lower case.</sup>

### Complete the specimen's metadata
- [X] select the specimen
- [X] select the picture
- [x] name the picture
- [x] landmark the specimen
- [ ] fill in the form

  <sub>You have to fill in the information about the specimen. **It is very important to complete the form (particularly the stratigraphic fields) relative to the _specimen_, _not the species_**
  
  A specimen's metadata is entered in the following form, please **copy and paste it as it is (including hyphens)** in a text editor and fill in each field. **If there is missing information in a field, type NA**. Fill one form per landmarked **specimen**. If a single specimen has cephalon and pygidum, just fill in a single form indicating that it has a cephalon and a pygidum.
```
  -
  ID: 
  taxonomy: #this is the taxonomic information of the specimen. Don't fill anything else in this line
    genus: 
    gen_status: 
    subgen: 
    sp: 
    sp_status: 
    subsp: 
    orig_genus: 
    sp_author: 
    gen_author: 
    orig_sp:
  ref_pic: 
  morphology: #this is the morphological information of the specimen. Don't fill anything else in this line
    cephalon: 
    cranidium: 
    pygidium: 
    eyes: 
    ontogeny: 
  geography:  #this is the geographic information of the specimen. Don't fill anything else in this line
    locality: 
    country: 
    state: 
    country:
    lat: 
    long: 
  stratigraphy:  #this is the stratigraphic information of the specimen. Don't fill anything else in this line
    formation: 
    min_age: 
    max_age: 
    ref_age: 
    basin: 
    lithology: 
  enterer:
    metadata: 
    landmark:
    date:
```
  The information needed and format for each field is described in Serra et al[^1] [table 2](https://figshare.com/ndownloader/files/40538360/preview/40538360/preview.pdf).

### Upload all data to TriloMorph
- [X] select the specimen
- [X] select the picture
- [x] name the picture
- [x] landmark the specimen
- [x] fill in the form
- [ ] login to github
  
  <sup>If you don't have a github account you have to sign in first. You will only need an email, but don't be afraid using github is very simple.</sub>
  
  <sup>**If it is your first time contributing to TriloMorph, we suggest to contact us[^6] first**</sup>.

- [ ] upload the metadata
    
  Go the [specimens' metadata file](trilomorph.yaml) and press the [edit button](https://docs.github.com/assets/cb-47677/mw-1440/images/help/repository/edit-file-edit-button.webp).
  
  <sup>**Important:** if this is your first time contributing to TriloMorph, github will give a [message](https://figshare.com/ndownloader/files/40539905/preview/40539905/preview.jpg) indicating that you need to fork this repository. Go ahead and **press "Fork this repository"**. Github might also [tell you that your fork is outdated](https://figshare.com/ndownloader/files/40539920/preview/40539920/preview.jpg). Don't worry, just **press "Update your fork"**.</sup>
  
  Once editing the metadata file, paste the **newly filled form(s)** in the second line (below the three hyphens [---])
       
After pasting the new form(s):
  
  * press the "commit changes..." button, which will open a [small window](https://figshare.com/ndownloader/files/40539908/preview/40539908/preview.jpg)
  * press "propose changes". The github page will now have the [heading **"Comparing changes"**](https://figshare.com/ndownloader/files/40539902/preview/40539902/preview.jpg).
  * press "Create pull request". 

After pressing the button the github page will now have the heading **Open a pull request**
 
In this page you will have a [field](https://docs.github.com/assets/cb-33734/mw-1440/images/help/pull_requests/select-bar.webp) where **you _must upload_ the following files**:

- [ ] upload the picture file(s)
  
  <sup>Please note that the maximum size for images is 10MB</sup>
  
- [ ] upload the landmark file(s)
    
Once you've uploaded all files, the field will look like [this](https://figshare.com/ndownloader/files/40539917/preview/40539917/preview.jpg). You can also take a look at the [preview tab](https://figshare.com/ndownloader/files/40539911/preview/40539911/preview.jpg) to make sure that the image(s) have been uploaded correctly.

**Then you must press the "Create pull request" button**.

The final step should look something similar to [this](https://figshare.com/ndownloader/files/40539914/preview/40539914/preview.jpg)


### Include all new references
- [X] select the specimen
- [X] select the picture
- [x] name the picture
- [x] landmark the specimen
- [x] fill in the form
- [x] login to github
- [x] upload the metadata
- [X] upload picture file
- [x] upload the landmark file
  
After submitting the specimen's metadata, shape file and picture, you need to
  
- [ ] update references list
  
  <sup>You have to include the literature references used in the new record. To add new references, go to the [references list](Reference_main_table.csv) and press the [edit button](https://docs.github.com/assets/cb-47677/mw-1440/images/help/repository/edit-file-edit-button.webp). Add all new references using the following formats,</sup>
  
  <sup>for single author: `Author year, Author I. (year). Title. Journal. Volume pages. doi:`</sup>

  <sup>for two authors: `Author Author year, Author I. Author I. (year). Title. Journal. Volume pages. doi:`</sup>

  <sup>for multiple authors: `Author et al year, Author I. Author I. Author I. (year). Title. Journal. Volume pages. doi:`</sup>

  Paste the new references in the list, press the "commit changes..." button and follow the steps.

If it is the **first time** you contribute with data, you also need to
  
- [ ] update the list of contributors
  
  <sup>You have to include your personal information. Go to the [list of contributors](contributors.csv) and press the [edit button](https://docs.github.com/assets/cb-47677/mw-1440/images/help/repository/edit-file-edit-button.webp) and then add all your information using the following format,</sup>
  
  <sup>`Full Name, enterer ID*, ORCID ID, Affilation, email, github username`</sup>

  <sup>*enterer ID is the name you used in the enterer field of the specimen's metadata</sup>

  Paste the new references in the list, press the "commit changes..." button and follow the steps.
  
### Wait for file revison and acceptance
- [X] select the specimen
- [X] select the picture
- [x] name the picture
- [x] landmark the specimen
- [x] fill in the form
- [x] login to github
- [x] upload the metadata
- [X] upload picture file
- [x] upload the landmark file
- [x] update references list
- [x] update list of contributors (if necessary)

After uploading all files of the new landmarked specimen(s), **the new information will not be immediately available in the database**. The TriloMorph maintainers[^6] will review all files, check that there is no conflict, and accept your new data within a week or two. After accepting the new data you will receive an email informing that the data was merged to TriloMorph. If you need your data to be reviewed and accepted faster please contact us[^6].
    
## Licence
All material is distributed under Creative Commons Attribution-Non Commercial-Share Alike 4.0 International [CC BY-NC-SA 4.0] licence terms[^N]. 
  
If you use the database please cite it using the doi or handle and the version of the stable release. A bibtex version of the citable stable release is available [here](citation.bib).

In case you use Trilomorph for a publication, we strongly suggest you to acknowledge the main contributors to the analyzed dataset. You can check the contributors in the accompanying metadata and their full names and additional information in the [list of Trilomorph contributors](/contributors.csv)

### References
[^1]: Serra F., Balseiro D., Monnet C., et al. submitted. A dynamic and collaborative database for morphogeometric information of trilobites. Scientific Data.
[^2]: Latest and previous stable releases are available at https://rdu.unc.edu.ar/handle/11086/547753 and [DOI: 10.5281/zenodo.8033445](https://dx.doi.org/10.5281/zenodo.8033445)
[^3]: Rohlf F.J. 2015. The tps series of software. Hystrix, the Italian Journal of Mammalogy 26:9-12. DOI: [10.4404/hystrix-26.1-11264](https://doi.org/10.4404/hystrix-26.1-11264)
[^4]: Adams D.C, Collyer M.L. and Kaliontzopoulou A. 2020. Geomorph: Software for geometric morphometric analyses. R package version 3.2.1. https://cran.r-project.org/package=geomorph.
[^5]: Olsen A.M. and Westneat M.W. 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up. Methods in Ecology and Evolution 6:351-356. DOI: [10.1111/2041-210X.12326](https://doi.org/10.1111/2041-210X.12326).
[^6]: The data base is currently maintained by [Diego Balseiro](mailto:dbalseiro@unc.edu.ar) and [Fernanda Serra](mailto:fserra@unc.edu.ar)
[^7]: Schneider C.A., Rasband W.S. and Eliceiri K.W. 2012. NIH Image to ImageJ: 25 years of image analysis. Nature Methods 9:671–675. DOI: [10.1038/nmeth.2089](https://doi.org/10.1038/nmeth.2089)
  [Download ImageJ](https://imagej.net/ij/)
[^N]: https://creativecommons.org/licenses/by-nc-sa/4.0/
