# ----------------------------------------
# TriloMorph
# Workflow of a morpho-geometric analysis of trilobites with R.
# ----------------------------------------
# Here is an R script designed to perform the morphological disparity analyses computed in the manuscript :
#   Serra F, Balseiro D, Monnet C, Randolfe E, Bault V, Rustán JJ, Vaccari E, Bignon A, Muñoz DF, Crônier C, & Waisfeld BG (2023).
#   TriloMorph: A dynamic and collaborative database for morphogeometric information of trilobites.
#   Scientific Data, XXX, XXX-XXX. doi: xxxxxxxxxxx
# ----------------------------------------
# If you use this script and/or the TriloMorph database,
#   please cite the reference above.
# ----------------------------------------
# Analyses computed using R version 4.1.3 (R Core Team 2022).
# This script follows the following steps:
# .: Set up the R environment and import required libraries and functions.
# .: Load and filter the data (contextual and geomorphometric).
# .: Superimpose the selected configurations by GPA.
# .: Construct the morphospace of selected configurations.
# .: Reconstruct a morphological disparity curve through time
#      by a crossover with the Paleobiology Database (PBDB).
# .: Quantify measurement error.
# .: Package citations and other references
# ----------------------------------------


# ----------------------------------------
# First, set up the R environment.

# .: Clean the R environment.
rm(list=ls(all=TRUE))
graphics.off()

# .:Define the working directory
# IMPORTANT: Make sure that within this working directory you have the 'landmark' folder containing all shape files that you downloaded.
# Additionaly you can also download the 'replicates' folder within your working directory for the error tests.

# setwd("type/the/path/to/the/folder")


# .: Check and load the required libraries (package citations at end of script).
# These various packages must be installed prior to the following analyses.
# First, we check if they are installed
# if not installed, we automatically set the installation (internet connection required):
if (!any(installed.packages()[, 1] == "geomorph")) {
  install.packages("geomorph") }

if (!any(installed.packages()[, 1] == "StereoMorph")) {
  install.packages("StereoMorph") }

if (!any(installed.packages()[, 1] == "data.table")) {
  install.packages("data.table") }

if (!any(installed.packages()[, 1] == "vegan")) {
  install.packages("vegan") }

# Load all required packages
library(geomorph)     # for landmark analyses (Adams & Otárola-Castillo 2013)
library(StereoMorph)  # for landmark acquisition (Olsen & Westneat 2015)
library(data.table)   # for data handling
library(vegan)        # for analysis of multivariate dispersion

# Source additional functions used in this study (internet connection required).
source("https://raw.githubusercontent.com/balsedie/trilomorph/main/TriloMorph-funs.R")

# .: Paths to Trilomorph metadata and PBDB occurrence dataset
fdat <- "https://raw.githubusercontent.com/balsedie/trilomorph/main/trilomorph.yaml"
focs <- (paste0("https://paleobiodb.org/data1.2/occs/list.csv?", 
                "base_name=Trilobita&",
                "interval=Lochkovian,Famennian&",  # bottom, top
                "show=class,coords,loc,refattr&",  #information retrieved
                "occs_created_before=2023-3-27")) # stable data set 
#if(!file.exists(fdat)) stop("expected main table is missing")
#if(!file.exists(focs)) stop("expected pbdb-occurrence table is missing")

# .: Assume that data have the following names and are in the following folders:
# Keep in mind that most computer systems are not case sensitive.
dirlm <- "landmarks"
if(!file.exists(dirlm)) stop("expected folder of landmark datafiles is missing")

# .: Set the expected template of landmarks for this analysis.
# Template = number of dimensions, number of landmarks, number of semilandmarks for the first curve, ...
# As described in the paper, cephala have 16 landmarks and four curves of semilandmarks.
# Expected order of the curves: glabella, facial suture, anterior margin, and posterior margin (for details see the published article).
nlms <- c(2, 16, 12, 20, 20, 20)
# ----------------------------------------


# ----------------------------------------
# Load and filter the contextual data (chronostrtaigraphy and taxonomy).
# In order to illustrate the possibilities of the 'TriloMorph' database,
#   in this paper, we select only part of the data as a case study.
# We focus on:
#   - the cephala of trilobites,
#   - from the Devonian chronostratigraphic interval,
#   - at the stage resolution,
#   - and at the genus taxonomic rank.
# Also, currently, as a starting point, the 'TriloMorph' database documents one typical specimen for each genus.
# Therefore, here, to illustrate the most complete disparity of trilobites through time,
#   we use the Paleobiology Database (PBDB) to extract the complete chronostratigraphic range of each genus.

# .: Load the 'TriloMorph' CSV-formatted file containing the contextual information of considered specimens.
# The database is, indeed, a collection of data files overseen by a main table designed to contain specimen-level traits for considered taxa.
# The basic unit of entry in this main table is that of a specimen with a unique alphanumeric identifier (ID).
# It is accompanied by contextual characteristics such as the publication reference,
#   taxonomic information, relevant morphological information, geographic context, and stratigraphic information (internet connection required).
trilos <- yaml_read(file = fdat, flat = TRUE)
trilos <- trilos[which(trilos$morphology.cephalon),]  # as indicated above, keep only cephala
trilos$taxonomy.genus <- trimws(trilos$taxonomy.genus)
str(trilos, max.level = 0)
print(head(trilos))

# .: Load an occurrence dataset of Devonian trilobites (internet connection required).
# Occurrence data are downloaded from https://paleobiodb.org/ (for details see file's header).
occs <- fread(focs, na.strings="")

# Because this illustrative case study focus at the genus rank, ...
# ... unknown occurrences at the genus level are removed,
# ... and subgenus information is removed.
occs <- occs[!is.na(occs$genus),]
occs$genus <- sapply(occs$genus, function(x) unlist(strsplit(x, " ", fixed=T))[1])
str(occs, max.level = 0)
print(head(occs))

# .: Reconstruct the taxon-by-time (genus/stage) incidence matrix of Devonian trilobites
# by collating and processing these two datasets (both contain occurrences not present in the other one).
# ..: Set chronostratigraphic data from the ICS (https://stratigraphy.org/).
xt <- c(419.2, 410.8, 407.6, 393.3, 387.7, 382.7, 372.2, 358.9)
stages <- c("Lochkovian", "Pragian", "Emsian", "Eifelian", "Givetian", "Frasnian", "Famennian")
colages <- setNames(c("#E5B75A", "#E5C468", "#E5D075", "#F1D576", "#F1E185", "#F2EDAD", "#F2EDC5"), stages)
gn_all <- sort(unique(c(occs$genus, trilos$taxonomy.genus)))
# ..: Compile occurrences of each genus in each stage.
ocms <- matrix(0L, nrow = length(gn_all), ncol = length(stages),
  dimnames = list(gn_all, stages))
for(s in gn_all) for(t in stages) {
  dx <- occs[(occs$genus == s) & (occs$early_interval == t),]
  if(nrow(dx) > 0) ocms[s,t] <- 1
  dy <- trilos[(trilos$taxonomy.genus == s) & (trilos$stratigraphy.min_age == t),]
  if(nrow(dy) > 0) ocms[s,t] <- 1
}
# ..: Remove taxa without Devonian occurrences and then fill ranges with gaps.
ocms <- ocms[(rowSums(ocms) > 0),]
fads <- apply(ocms, 1, function(x) min(which(x > 0)))
lads <- apply(ocms, 1, function(x) max(which(x > 0)))
for(i in 1:nrow(ocms)) ocms[i,fads[i]:lads[i]] <- 1
str(ocms)
print(head(ocms))
# write.csv(ocms, file = "GlobalIncidenceMatrix-Devonian.csv")
# ----------------------------------------


# ----------------------------------------
# Then, load and filter the geomorphometric data for selected genera.
# The loading and processing of the landmark data consist in:
# - Load and parse landmark data of each specimen and store them in a named list.
# - Remove specimen with a landmark scheme not compatible with the provided template (e.g. remove specimens with missing landmarks).
# - Possibly resample semilandmark curves to the submitted template.
# - Collapse all data to the standard 3D array (see Claude 2008).

# .: Spot genera having a landmarked specimen in the TriloMorph database
# and recorded in this incidence matrix.
trilos <- trilos[(trilos$taxonomy.genus %in% rownames(ocms)),]
str(trilos, max.level = 0)
# write.csv(trilos, file = "TriloMorph-filtered.csv")

# .: Load geomorphometric data of these specimens.
# Expect one landmark file for each specimen and named after its ID code
#   (this unique identifier code is reported in the main classifier table loaded above).
# IDs are expected to have no blank character and no special character.
# In addition, for cephala, the landmark filename is expected to end with the suffix "_C".
fids <- trilos$ID
str(fids)
if(any(duplicated(tolower(fids)))) stop("IDs are not unique as expected : ",
  toString(fids[duplicated(tolower(fids))]))

# .: Load and parse the landmark datafiles.
# Landmark filenames are expected to have their extension in lower case.
# These datafiles are assumed to be either in the standard TPS format (see Rohlf 2015)
#   or in the XML-based StereoMorph format (Olsen & Westneat 2015).
# Note: the 'geomorph' package contains the necessary functions to read landmark data in various formats albeit independently.
# Here, a series of functions is provided to read, check, and modify
#   these various datafiles altogether in a structured way (see file 'TriloMorph-funs.R').
lmks <- shapRead(fids, sufix = "_C", subdir = dirlm)
str(lmks, max.level = 0)
str(lmks[1])

# Filter and fit loaded configurations to the submitted template.
print(nlms)
ldks <- shapFix(lmks, nlms)
str(ldks)

# Comment: The function 'shapFix' will warn the user and automatically removed specimens
#   with landmark data not fitting the submitted template.
# For example, we expect 4 curves of semilandmarks (see the manuscript);
#   but some species do not show these four structures and hence have not all of them landmarked;
#   therefore, these are removed as can be expected.
# Warning messages:
# 1: In shapFix(lmks, nlms) :
#   configurations removed : 23 : SMF_57476, SMF_57503, MGCU_48_814, MUA_1094_007, MUA_1094_011, NM_L6127, SMF_57451, USTM_RF_95, WAM_91.316, WAM_1140, Alberti_1983-7.87, Maksimova-1978-2.3b, Maksimova-1968-20.2, MUA-1094-011, Basse-Muller_2000-3.19, SMF-55933, GT-464, SMF-97026, SMF-X540d, SMF-57520, UM-IP-722, WAM-07.277, MUA-1094-007
# 2: In shapFix(lmks, nlms) :
#   configurations unscaled : 8 : NML_8917, SMF-57513, Brauckmann_1986-6.5a, NHM-It-19284, NHMM_2016-055, NHMM_2016-057, IRSBNa12430, Tr-240
# ----------------------------------------


# ----------------------------------------
# Next, superimpose (= align, standardize) the selected configurations.
# Standardization of the landmark data is done by means of a generalized Procrustes analysis (GPA).
# Superimposed landmarks are also projected into the tangent space.
# Here, semilandmark curves are not slided, but this step is often recommended.

# .: Superimpose by GPA.
gpan <- geomorph::gpagen(ldks, Proj = TRUE, PrinAxes = FALSE)

# .: Plot the aligned configurations and the mean shape (consensus).
dev.new()
geomorph::plotAllSpecimens(gpan$coords)
title("aligned configurations and consensus")
mtext(paste0("n = ", dim(gpan$coords)[3]), side = 3, adj = 1, font = 3)
# ----------------------------------------


# ----------------------------------------
# Then, construct the morphospace of selected configurations.
# This morphological space is reconstructed by means of a principal components analysis (PCA).
pcan <- geomorph::gm.prcomp(gpan$coords)
dev.new()
geomorph:::plot.gm.prcomp(pcan, main = "PCA-based morphospace", pch = 21, bg = "lightgray", cex = 1.5)
mtext(paste0("n = ", nrow(pcan$x)), side = 3, adj = 1, font = 3)
#text(pcan$x[,1:2], rownames(pcan$x), cex = 0.5, pos = 3)
# ----------------------------------------


# ----------------------------------------
# Last, reconstruct a morphological disparity curve through time (at the stage level).

# .: Several morphological disparity metrics exist (see Guillerme et al. 2020).
# Here, for illustration, we simply compute the most common measure used in palaeobiology:
#   the sum of variances (SOV; Foote 1992).
# Here, compute a value for each Devonian stage.
ysov <- ylow <- yup <- yrng <- ylmk <- setNames(integer(length(stages)), stages)
dev.new()
par(mfrow = c(3,3))
for(s in stages) {
  # Get list of genera occurring in the current stage.
  gens <- rownames(ocms)[ocms[,s] > 0]
  yrng[s] <- length(gens)
  # Match this list with the landmarked specimens of the TriloMorph DataBase.
  k <- (trilos$taxonomy.genus %in% gens)
  tids <- trilos$ID[k]
  ylmk[s] <- length(unique(trilos$taxonomy.genus[k]))
  # Show them on the morphospace.
  k <- which(rownames(pcan$x) %in% tids)
  plot(pcan$x[,1:2], asp = 1, main = s, xlab = "", ylab = "", xaxt = "n", yaxt = "n",
    pch = replace(rep(4, nrow(pcan$x)), k, 21),
    bg = replace(rep(NA_character_, nrow(pcan$x)), k, colages[s]),
    cex = replace(rep(0.5, nrow(pcan$x)), k, 2))
  mtext(paste0("n = ", length(k)), side = 3, adj = 1, font = 3)
  # Compute their morphological disparity (SOV).
  ysov[s] <- y <- shapSumVar(pcan$x[k,])
  ylow[s] <- attr(y,"ci")[1]
  yup[s] <- attr(y,"ci")[2]
}
par(mfrow = c(1,1))

# .: Plot diversities through time (taxonomic richness and morphological disparity).
dev.new()
x <- xt[1:(length(xt)-1)] + diff(xt)
par(mfrow = c(2,1))
plot(x, yrng, type = "b", xlim = rev(range(xt)), ylim = c(0, extendrange(yrng)[2]),
  main = "taxonomic diversity", ylab = "genus richness", xlab = "geological time (Ma)")
points(x, ylmk, col = "red", pch = "+")
lines(x, ylmk, col = "red", lty = 3)
legend("topright", c("known Devonian taxa","landmarked taxa"), col = c("black", "red"),
  pch = c("o", "+"), lty = c(1, 3), ncol = 1)
plot(x, ysov, type = "b", xlim = rev(range(xt)), ylim = extendrange(c(ysov, ylow, yup)),
  main = "morphological disparity", ylab = "sum of variances", xlab = "geological time (Ma)")
segments(x, ylow, x, yup)
par(mfrow = c(1,1))
# ----------------------------------------


# ----------------------------------------
# Quantify measurement error based on 3 additional datasets of Devonian cephala:
# - One specimen landmarked by eight different persons: UA13384_??;
#   enable to estimate the "between-observer variability" (BPV).
# - One specimen landmarked 10 times by one person: UA13384_DB1 -> UA13384_DB10.
# - Another specimen landmarked 10 times by another person: UA13256_FS1 -> UA13256_FS10.
#   Both enable to estimate the "within-observer variability" (WPV).
# And compare them to the main TriloMorph dataset (see above),
#   which enables to estimate the "between-genus variability" (BGV).


# .: Assume that data have the following names and are in the following folders:
# Keep in mind that most computer systems are not case sensitive.
dirtest <- "replicates"
if(!file.exists(dirtest)) stop("expected folder of observer datafiles is missing")

# .: Load these additional landmark data.
ids_bpv <- paste0("UA13384_", c("BGW", "DB", "DM", "ER", "EV", "FS", "JJR", "VB"))
ids_wp1v <- paste0("UA13384_DB", 1:10)
ids_wp2v <- paste0("UA13256_FS", 1:10)
ids_bgv <- dimnames(ldks)[[3]]
gfac <- c(rep("betw-genus var", dim(ldks)[3]), rep("betw-obs var", length(ids_bpv)),
  rep("with-obs-1 var", length(ids_wp1v)), rep("with-obs-2 var", length(ids_wp2v)))
glvl <- unique(gfac)
gcols <- c("gray", "orange", "royalblue", "purple")
merr <- shapFix(shapRead(c(ids_bpv, ids_wp1v, ids_wp2v), subdir = dirtest), nlms)

# .: Merge the 3 landmark arrays for assessing measurement error
# with the raw TriloMorph landmark dataset already processed above ('ldks').
m <- array(
  c(ldks, merr), c(nrow(ldks), ncol(ldks), dim(ldks)[3] + dim(merr)[3]),
  dimnames = list(dimnames(ldks)[[1]], dimnames(ldks)[[2]], c(ids_bgv, dimnames(merr)[[3]])))
str(m)
#save(m, gfac, glvl, gcols, file = "TriloMorph-errordata.rda")

# .: Superimpose the data by GPA and construct the morphospace.
gper <- geomorph::gpagen(m, Proj = TRUE, PrinAxes = FALSE)
pcer <- geomorph::gm.prcomp(gper$coords)

# .: Compute the morphological variability of each of these 3 groups
#   and compare with the variability of previous genus-based data.
# The amount of variation attributable to measurement error is quantified
#   using the 'morphol.disparity' function from the R package 'geomorph'.
# This function quantifies morphological disparity as the Procrustes variance
#  (overall or for groups) using residuals of a linear model fit (see Zelditch et al. 2012).

# Here, compute partial disparities (Foote 1993). The sum of group partial disparities is the total disparity.
pvars <- geomorph::morphol.disparity(gper$coords ~ 1, groups = gfac, partial = TRUE, print.progress = FALSE)
print(pvars$Procrustes.var)

# .: To compare the morphological variability of each group,
# also we calculate the pairwise Procrustes distances among all taxa within each group.
pdist <- do.call(rbind, c(lapply(
  setNames(glvl, glvl), function(s, gp, mlms) data.frame(group = factor(s),
    x = as.vector(dist(geomorph::two.d.array(mlms[,,(gp == s)])))),
  gp = gfac, mlms = gper$coords), make.row.names = FALSE))
pfmt <- do.call(rbind, tapply(pdist$x, pdist$group, function(x) summary(x)))
print(pfmt)

# Show the results.
# .: On the 'error' morphospace.
dev.new()
geomorph:::plot.gm.prcomp(
  pcer, main = "morphospace for measurement error", cex = 1.5,
  pch = c(21, 3, 4, 4)[match(gfac, glvl)],
  col = gcols[match(gfac, glvl)])
#text(pcer$x[,1:2], rownames(pcer$x), cex = 0.5, pos = 3)
legend("topleft", ncol = 1,
  paste(names(pvars$Procrustes.var), round(pvars$Procrustes.var, 4), sep = " = "),
  col = gcols, pch = c(21, 3, 4, 4),
  title = "morphological variability (Procrustes variance)")
mtext(paste0("n = ", nrow(pcer$x)), side = 3, adj = 1, font = 3)

#.: Test for multivariate homogeneity of group dispersions in the morphospace
# create a vector for groups
g_mult <- c(rep("betw-genus", 142), rep("betw-obs", 8),
  rep("with-obs-1", 10), rep("with-obs-2", 10))

# obtain distance matrix from morphospace 
d_prcomp <- dist(pcer$x[,1:10])

# run Anderson's (2006) Permutation test (aka PERMUDISP2
test_error_mult <- betadisper(d_prcomp, g_mult, type="centroid")

# Test statistical significance
print("======================================")
print("Test for homogeneity of Multivariate dispersion")
print(anova(test_error_mult))
print("======================================")

# A posteriori test for between group comparisons
tukey_error <- TukeyHSD(test_error_mult)

print("======================================")
print("Tukey test for homogeneity of Multivariate dispersion")
print(tukey_error)
print("======================================")

  
# .: Boxplot of pairwise Procrustes distances.
dev.new()
par(mar = c(5.1, 8.1, 4.1, 2.1))
boxplot(pdist$x ~ pdist$group, col = gcols, horizontal = TRUE, las = 1,
  xlab = "Procrustes distance", ylab = NA,
  main = "distribution of pairwise Procrustes distances among specimens within groups")
legend("topright", ncol = 1, col = gcols, pch = 22,
  paste(rownames(pfmt), round(pfmt[,"Median"], 3), sep = " = "),
  title = "median of Procrustes distances")
  
# Kruskal-Wallis test for significance in pairwise Procrustes distances
kw_test <- kruskal.test(pdist$x, pdist$group)

print("======================================")
print("Kruskal-Wallis test for differences in mean pairwise Procrustes distances")
print(kw_test)
print("======================================")

# ----------------------------------------


# ----------------------------------------
# References:
#
# Adams DC, Otárola-Castillo E, 2013. geomorph: an R package for the collection and analysis of geometric morphometric shape data.
# Methods in Ecology and Evolution, 4, 393-399. https://doi.org/10.1111/2041-210X.12035
#
# Anderson, M.J. (2006) Distance-based tests for homogeneity of multivariate dispersions. 
# Biometrics 62, 245-253. https://doi.org/10.1111/j.1541-0420.2005.00440.x
#
# Claude J, 2008. Morphometrics with R.
# Springer. https://doi.org/10.1007/978-0-387-77789-4
#
# Dowle M and Srinivasan A (2019). data.table: Extension of `data.frame`. 
# R package version 1.12.8. https://CRAN.R-project.org/package=data.table
#
# Foote M, 1992. Rarefaction analysis of morphological and taxonomic diversity.
# Paleobiology, 18, 1-16. https://doi.org/10.1017/S0094837300012185
#
# Foote M, 1993. Contributions of individual taxa to overall morphological disparity.
# Paleobiology, 19, 403-419. https://doi.org/10.1017/S0094837300014056
#
# Guillerme T, Puttick MN, Marcy AE, Weisbecker V, 2020. Shifting spaces: Which disparity or dissimilarity measurement best summarize occupancy in multidimensional spaces?
# Ecology and Evolution, 10, 7261-7275. https://doi.org/10.1002/ece3.6452
#
# Olsen AM, Westneat MW, 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up.
# Methods in Ecology and Evolution, 6, 351-356. https://doi.org/10.1111/2041-210X.12326
#
# Jari Oksanen, et al. (2019). vegan: Community Ecology Package. 
# R package version 2.5-6. https://CRAN.R-project.org/package=vegan

# R Core Team, 2022. R: A language and environment for statistical computing.
# R Foundation for Statistical Computing, Vienna, Austria. https://www.R-project.org/
#
# Rohlf FJ, 2015. The tps series of software.
# Hystrix, 26, 9-12. https://doi.org/10.4404/hystrix-26.1-11264
#
# Zelditch ML, Swiderski DL, Sheets HD, Fink WL, 2012. Geometric morphometrics for biologists: a primer.
# Elsevier/Academic Press, Amsterdam. 2nd edition.
# ----------------------------------------
