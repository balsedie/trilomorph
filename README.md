# Trilomorph
## About the database
TriloMorph is an openly accessible database for morpho-geometric information of trilobites, the main Palaeozoic group of marine arthropods[^1]. The database records landmark and semilandmark information on trilobite cephala and pygidia. 

If you are willing to use the database, we strongly suggest to download the stable release that is accesible in the Digital repository of the Universidad Nacional de Córdoba[^2].
The purpose of this repository is to allow the constant input of new data into the database. Below we explain step by step the procedure to upload new data to Trilomorph:

### Specimen
- [ ] select the specimen

  <sup>Specimens included in the database have to be housed in official collections (preferentially having a collection number) or illustrated in the scientific literature. Specimens can be cephala and/or pigydia. Be sure that the selected specimen is **not distored**, for cephala make sure that free cheeks are in place and not slighly disarticulated.</sup>

- [ ] select the picture

  <sup>The picture used for the landmarking (see below) has to be a ***strictly dorsal*** picture of the specimen, either cephalon or pigidia. If the specimen is articulated make sure that both parts are photographed in dorsal view, if not use different pictures for each part.</sup>
  
  <sup>**IMPORTANT**: each picture has to include a graphical scale. If it is missing in the original publication, include one. You can easily include graphical scale bars with sorftware such as ImageJ[^7]</sup>
  
  <sup>Accepted formats are PNG and JPG/JPEG. Please avoid using TIFF files</sup>

- [ ] name the picture

  <sup>The picture has to be named using the specimen's collection acronym and number. The file name must have the suffix _C when it is the cephalon, and _P for the pygidium. **Important:** If a single specimen and picture is used to landmark both cephalon and pygidium, two different files need to be created and named one for the pygidum (_P) and one for the cephalon (_C) </sup>

### Landmarking
- [X] select the specimen
- [X] select the picture
- [x] name de picture
- [ ] landmark the specimen

  <sup>The specimen needs to be landmarked following the protocol in Serra et al[^1], which is explained in figure 1 and table 1 </sup>

  <sup>You can use different landmarking program, namely tpsDig2[^3], geomorph package for R[^4], StereoMorph package for R[^5]. </sup>
  
  <sup>Check that the landmark file is a.txt file with the same name as the image file</sup>

### Complete the specimen's metadata
- [X] select the specimen
- [X] select the picture
- [x] name de picture
- [x] landmark the specimen
- [ ] fill the form

  <sub>You have to fill the information about the specimen. **It is very important to complete the form (particularly the stratigraphic fields) relative to the _specimen_, _not the species_**
  
  Specimen's metadata is entered in the following form, please **copy and paste it as it is (including hyphens)** in a text editor and fill each field. If missing information in a field, you can leave it blank or remove the field. Fill one form per landmarked **specimen**. If a single specimen has cephalon and pygidum, just fill a single form indicating that it has cephalon and pygidum.
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
  The information needed and format for each field is described in Serra et al[^1] [table 2](https://www.figshare.com/blabbla).

### Upload all data to Trilomorph
- [X] select the specimen
- [X] select the picture
- [x] name de picture
- [x] landmark the specimen
- [x] fill the form
- [ ] login in github
  
  <sup>if you don't have a github account you have to sign in first. You will only need an email, but don't be afraid using github is very simple.</sub>
  
  <sup>**if it is your first time contributing to Trilomorph, we suggest to contact us[^6] first**</sup>.

- [ ] upload the metadata
    
  Go the [specimens' metadata file](/main/trilomorph.yaml) and press the "edit" button.
  
  **Important:** if this is your first time contributing to Trilomorph, github will tell you that it will create a new fork of this 
  
  Once editing the metadata file, paste the **new filled form(s)** in the second line (below the two hyphens [--])
       
  Then  
  
  * press the "commit changes..." button which will open a small window
  * press "propose changes" button. The github page will now have the heading **"Comparing changes"**.
  * press "Create pull request". 

After pressing the button the github page will now have the heading **Open a pull request**
 
In this page you will have a [field](https://docs.github.com/assets/cb-33734/mw-1440/images/help/pull_requests/select-bar.webp) where you have upload the following files:

- [ ] upload the picture file
  
  <sup>Please note that the maximum size for images is 10MB</sup>
  
- [ ] upload the landmark file
    
  <sup>After uploading both files the filed should look like this.</sup>
    
### Wait for file revison and acceptance
- [X] select the specimen
- [X] select the picture
- [x] name de picture
- [x] landmark the specimen
- [x] fill the form
- [x] login in github
- [x] uploaod the metadata
- [X] upload picture file
- [x] upload the landmark file

After uploading all files of the new landmarked specimen(s), **the new information will not be immediately available in the database**. The Trilomorph maintainers[^6] will review all files, check that there is no conflict, and accept your new data within a week or two. After accepting the new data you will recieve an email informing that the data was merged to Trilomorph. If you need your data to be reviewed and accepted faster please contact us[^6].
    
## Licence
All material is distributed under Creative Commons Attribution-Non Commercial-Share Alike 4.0 International [CC BY-NC-SA 4.0] licence terms[^N]. 

### References
[^1]: Serra F., Balseiro D., Monnet C., et al. submitted. TriloMorph: a dynamic and collaborative database for morphogeometric information of trilobites. Scientific Data.
[^2]: Latest and previous stable releases are available at https://rdu.unc.edu.ar/handle/11086/nnnnnnn
[^3]: Rohlf F.J. 2015. The tps series of software. Hystrix, the Italian Journal of Mammalogy 26:9-12. DOI: [10.4404/hystrix-26.1-11264](https://doi.org/10.4404/hystrix-26.1-11264)
[^4]: Adams D.C, Collyer M.L. and Kaliontzopoulou A. 2020. Geomorph: Software for geometric morphometric analyses. R package version 3.2.1. https://cran.r-project.org/package=geomorph.
[^5]: Olsen A.M. and Westneat M.W. 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up. Methods in Ecology and Evolution 6:351-356. DOI: [10.1111/2041-210X.12326](https://doi.org/10.1111/2041-210X.12326).
[^6]: The data base is currently maintained by [Diego Balseiro](mailto:dbalseiro@unc.edu.ar) and [Fernanda Serra](mailto:fserra@unc.edu.ar)
[^7]: Schneider C.A., Rasband W.S. and Eliceiri K.W. 2012. NIH Image to ImageJ: 25 years of image analysis. Nature Methods 9:671–675. DOI: [10.1038/nmeth.2089](https://doi.org/10.1038/nmeth.2089)
  [Download ImageJ](https://imagej.net/ij/)
[^N]: https://creativecommons.org/licenses/by-nc-sa/4.0/
