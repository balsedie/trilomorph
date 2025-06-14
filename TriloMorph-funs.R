# ----------------------------------------
# TriloMorph
# Functions for reading TriloMorph metadata and the morpho-geometric analysis of trilobites with R.
# ----------------------------------------
# Here is a series of R functions used to perform the morphological analyses computed in the manuscript :
#   Serra F, Balseiro D, Monnet C, Randolfe E, Bignon A, Rustán JJ, Bault V,  Muñoz DF, Vaccari E, Martinetto M, Crönier C, & Waisfeld BG (2023).
#   A dynamic and collaborative database for morphogeometric information of trilobites.
#   Scientific Data, XXX, XXX-XXX. doi: xxxxxxxxxxx
# ----------------------------------------
# The authors of these functions are Claude Monnet and Diego Balseiro. 
#   If you use one of these functions and/or the TriloMorph database, please cite the reference above. 
#   If you want to include these functions in an R package, please contact C.M. (claude.monnet@univ-lille.fr) or D.B. (dbalseiro@unc.edu.ar)
# ----------------------------------------
# References:
# + Adams DC, Otárola-Castillo E, 2013. geomorph: an R package for the collection and analysis of geometric morphometric shape data.
#   Methods in Ecology and Evolution, 4, 393-399. https://doi.org/10.1111/2041-210X.12035
# + Claude J, 2008. Morphometrics with R. Springer. https://doi.org/10.1007/978-0-387-77789-4
# + Olsen AM, Westneat MW, 2015. StereoMorph: an R package for the collection of 3D landmarks and curves using a stereo camera set-up.
#   Methods in Ecology and Evolution, 6, 351-356. https://doi.org/10.1111/2041-210X.12326
# + R Core Team, 2022. R: A language and environment for statistical computing.
#   R Foundation for Statistical Computing, Vienna, Austria. https://www.R-project.org/
# + Rohlf FJ, 2015. The tps series of software. Hystrix, 26, 9-12. https://doi.org/10.4404/hystrix-26.1-11264
# + Wills M, 2001. Morphological disparity: A primer. In: Adrain JM, Edgecombe GD, Lieberman BS (Eds.), Fossils, phylogeny, and form: Ananalytical approach. Springer.
# ----------------------------------------

#First check dependencies and install them if necesary
if (!any(installed.packages()[, 1] == "geomorph")) {
  install.packages("geomorph")
}
if (!any(installed.packages()[, 1] == "StereoMorph")) {
  install.packages("StereoMorph")
}

require(geomorph, warn.conflicts = F)
require(StereoMorph, warn.conflicts = F)

# Function to read/load landmark data (digitized shape) from text files
#   in various formats and extract/compile additional information such as scaling.
# Read a shape file in one of the two following formats:
#   1) Either in TPS-based format for shapes digitized with the TPS software (Rohlf 2015); assume the data filename ends with '.tps'.
#   2) Or in XML-based format for shapes digitized with the 'StereoMorph' package (Olsen & Westneat 2015); assume the data filename ends with '.txt'.
# Return for each specimen a structured list of shape data/information.
# For example: List of 1: $ Poroscutellum:List of 13
# ..$ k       : int 2
# ..$ p       : int 3479
# ..$ plm     : int 16
# ..$ lm      : num [1:16, 1:2] 821 815 802 804 1131 ...
# ..$ ncvs    : int 4
# ..$ pcv     : int 3415
# ..$ cv.pts  : Named int [1:4] 846 979 888 702
# .. ..- attr(*, "names")= chr [1:4] "glabella" "suture" "anterior" "posterior"
# ..$ cv.lm   :List of 4
# .. ..$ glabella : num [1:846, 1:2] 815 816 817 818 819 820 821 822 823 824 ...
# .. ..$ suture   : num [1:979, 1:2] 821 822 823 824 825 826 827 828 829 830 ...
# .. ..$ anterior : num [1:888, 1:2] 821 822 823 824 825 826 827 828 829 830 ...
# .. ..$ posterior: num [1:702, 1:2] 804 805 806 807 808 809 810 811 812 813 ...
# ..$ scale   : num 0.0251
# ..$ id      : chr "Poroscutellum"
# ..$ image   : chr NA
# ..$ format  : chr "xml"
# ..$ filename: chr "Poroscutellum_C.txt
# This list must be processed with the function 'shapFix' before running a classical geomorph-based analysis.
shapRead <- function(fids, sufix = NULL, subdir = NULL, neg.na = TRUE) {
  # fids: The name(s) (possibly including file path) of the shape file(s) to read/load.
  # sufix: Possibly a suffix to append to the data filenames.
  # subdir: Possibly the name of a subfolder in which to read the data files.
  # neg.na: Whether or not negative landmark coordinates in a TPS file should be imported as missing values and coded as 'NA'.
  isError <- function(x) inherits(x, "try-error")
  fails <- miss <- character()
  qb <- list()
  # Look for either a TPS or XML file for each specimen ID considered.
  for(s in fids) {
    f <- paste0(s, sufix)
    if(!is.null(subdir)) f <- file.path(subdir, f)
    ftps <- paste0(f, ".tps")
    fxml <- paste0(f, ".txt")
    if(!file.exists(ftps) & !file.exists(fxml)) {
      miss <- c(miss, s)
      next
    }
    if(file.exists(ftps)) {
      dx <- shapReadTps(ftps, neg.na = neg.na)
    } else if(file.exists(fxml)) {
      dx <- shapReadXml(fxml, id = s)
    }
    if(isError(dx)) fails <- c(fails, s) else qb[[s]] <- dx
  }
  attr(qb, "specimens with missing datafile") <- miss
  attr(qb, "specimens with failed loading") <- fails
  return(qb)
}
shapReadXml <- function(fs, id = NA) {
  chrNoext <- function(x) sub('\\..[^\\.]*$', '', basename(x))
  # Read and parse a XML-based landmark file.
  xmlFile <- function(file) {
    read_lines <- readLines(file)
    read_lines <- paste(read_lines, collapse = "\n")
    read_lines <- gsub("(>)([[:print:]])", "\\1\n\\2", read_lines)
    read_lines <- gsub("([[:print:]])(</)", "\\1\n\\2", read_lines)
    lines <- strsplit(x = read_lines, split = "\n")[[1]]
    lines <- gsub("^[\t]*", "", lines)
    object_type <- "vector"
    read_xml_lines <- StereoMorph::readXMLLines(lines)
    rlist <- list(read_xml_lines$rlist)
    names(rlist)[1] = read_xml_lines$obj.name
    return(rlist$shapes)
  }
  qx <- xmlFile(fs)
  # Create a specific data structure to store landmark data and related information.
  scl <- NA_real_
  if(!is.null(qx$scaling)) if(length(qx$scaling) > 0) if(!is.na(qx$scaling)) scl <- qx$scaling
  lmks <- qx$landmarks.pixel
  rownames(lmks) <- rownames(qx$landmarks.pixel) #new line added. Saves landmark names
  #dimnames(lmks) <- NULL
  k <- is.nan(lmks)
  if(any(k)) lmks[k] <- NA
  lmks <- lmks[!is.na(lmks[,1]),] #new line added. Removes NA landmarks
  ncvs <- length(qx$curves.pixel)
  cvs <- qx$curves.pixel
  cv.names <- names(cvs)
  cv.length <- sapply(cvs, function(x) nrow(x))
  cv.slms <- lapply(cvs, function(x) { dimnames(x) <- NULL; return(x) })
  out <- list(
    k = dim(qx$landmarks.pixel)[2],
    p = sum(dim(qx$landmarks.pixel)[1] + cv.length),
    plm = dim(qx$landmarks.pixel)[1],
    lm = lmks, ncvs = ncvs,
    pcv = sum(cv.length), cv.pts = cv.length, cv.lm = cv.slms,
    scale = scl,
    id = ifelse(is.na(id), chrNoext(fs), id), image = NA_character_,
    format = "xml", filename = NA_character_
  )
  return(out)
}
shapReadTps <- function(fs, neg.na = TRUE) {
  # Read and parse along the tokens a TPS-based landmark file.
  tpsfile <- scan(file = fs, what = "char", sep = "\n", quiet = TRUE)
  # .: Remove the comments.
  commlines <- grep("COMMENT=", tpsfile, ignore.case = TRUE)
  if(length(commlines) != 0) tpsfile <- tpsfile[-commlines]
  # .: Check 2D vs 3D data (token 'LM').
  lmdim <- "LM="
  ndim <- 2
  lmlines <- grep("LM=", tpsfile, ignore.case = TRUE)
  if(length(lmlines) == 0) {
    lmdim <- "LM3="
    ndim <- 3
    lmlines <- grep("LM3=", tpsfile, ignore.case = TRUE)
  }
  if(length(lmlines) == 0) stop("missing landmark token: ex. 'LM=' or 'LM3='")
  # .: Get number of specimens to process.
  # Based on the number of detected landmark tokens.
  n <- length(lmlines)
  # .: Set starting and ending lines of each specimen.
  endlines <- lmlines[-1] - 1
  endlines <- c(endlines, length(tpsfile))
  # .: Tokenize each specimen to parse fixed and semilandmarks.
  speclist <- lapply(1:n, function(j) {
    speclines <- tpsfile[lmlines[j]:endlines[j]]
    lml <- grep(lmdim, speclines)
    crvl <- sort(c(grep("CURVES", speclines), grep("OUTLINES", speclines)))
    cptl <- grep("POINTS", speclines)
    scl <- grep("SCALE", speclines)
    iml <- grep("IMAGE", speclines)
    idl <- grep("ID", speclines)
    notlm <- grep("=", speclines)
    templm <- strsplit(speclines[-notlm], "\\s+")
    templm <- lapply(templm, gsub, pattern = "NA", replacement = NA_real_, fixed = TRUE)
    lm <- lapply(templm, as.numeric)
    p <- length(lm)
    # Test consistency in the number of dimensions.
    k <- sapply(lm, length)
    if(length(unique(k)) == 1) k <- unique(k) else stop("mixed 'k' dimensions")
    if((k < 2) | (k > 3)) stop("wrong 'k' dimensions")
    # Reformat scale factor.
    if(length(speclines[scl]) == 0) scale <- NA_real_ else {
      s <- unlist(strsplit(speclines[scl], "SCALE="))[2]
      if(s == "NA") scale <- NA_real_ else scale <- as.numeric(s)
    }
    # Identifier code mandatory.
    image <- unlist(strsplit(speclines[iml], "IMAGE="))[2]
    id <- unlist(strsplit(speclines[idl], "ID="))[2]
    if(is.null(id)) stop("one specimen has no 'id' : ", image)
    # Gather landmark values (open curves and outlines are treated equally).
    plm <- as.numeric(unlist(strsplit(speclines[lml], "="))[2])
    curve.pts <- as.vector(na.omit(as.numeric(unlist(strsplit(speclines[cptl], "POINTS=")))))
    if(length(curve.pts) == 0) pcv <- 0 else pcv <- sum(curve.pts)
    if(p != (plm+pcv)) stop("mismatch among the numbers of total, fixed, and semilandmarks")
    if(pcv > 0) {
      if(plm == 0) {
        curve.lm <- lm
        lm <- NULL
      } else {
        curve.lm <- lm[-(1:plm)]
        lm <- lm[1:plm]
      }
      curve.pts <- as.vector(na.omit(as.numeric(unlist(strsplit(speclines[cptl], "POINTS=")))))
      if(length(curve.pts) == 0) stop("something went wrong (token 'POINTS' missing?)")
    } else {
      cvlst <- curve.lm <- curve.pts <- NULL
    }
    # Convert list into matrix.
    if(!is.null(lm)) lm <- matrix(unlist(lm), nrow = plm, ncol = k, byrow = TRUE)
    if(!is.null(curve.pts)) {
      cvlms <- matrix(unlist(curve.lm), nrow = pcv, ncol = k, byrow = TRUE)
      q <- 0
      cvlst <- vector("list", length(curve.pts))
      for(i in 1:length(curve.pts)) {
        cvlst[[i]] <- cvlms[(q+1):(q+curve.pts[i]),]
        q <- q + curve.pts[i]
      }
    }
    # Possibly reformat unknown values.
    if(neg.na) {
      knas <- logical(nrow(lm))
      for(i in 1:nrow(lm)) if(any(lm[i,] < 0)) knas[i] <- TRUE
      if(any(knas)) lm[knas,] <- NA
    }
    rownames(lm) <- paste0("LM", c(1:plm)) #new line added. Saves landmark names
    lm <- lm[!is.na(lm[,1]),] #new line added. Removes NA landmarks
    # Return results in a structured list.
    out <- list(
      k = k, p = p, plm = plm, lm = lm,
      ncvs = length(curve.pts),
      pcv = pcv, cv.pts = curve.pts, cv.lm = cvlst,
      scale = scale, id = id, image = image,
      format = "tps", filename = basename(fs))
    return(out)
  })
  # Check IDs are unique and put them as list names.
  fids <- do.call(c, lapply(speclist, function(dx) dx$id))
  p <- !any(duplicated(fids))
  if(p) names(speclist) <- fids else stop("IDs of configurations are not unique")
  # Return results.
  if(n == 1) speclist <- speclist[[1]]
  return(speclist)
}




# Function to process landmark data loaded with (or at least structured similarly to)
#   the function 'shapRead' (see above)
#   and containing both fixed landmarks and curves of semilandmarks.
# Landmark data are processed to fit the landmark template indicated.
# By the way, semilandmarks are always resampled,
#   assuming that it is not known if they are already equally spaced.
# Return a standard (p x k x n) array, where p is the number of landmark points,
#   k is the number of landmark dimensions (2 or 3), and n is the number of specimens.
# The third dimension of this array contains names for each specimen,
#   which are obtained from the 'ID' field in the submitted data.
shapFix <- function(lmks, model, lm.scale = TRUE, cv.fixed = TRUE) {
  # lmks: A list of landmark data already loaded from TPS files and/or from XML-based StereoMorph files.
  #   The content of this list must follow the outcome of the 'shapRead' function (see above).
  # model: The landmark template to follow.
  #   It is a list of values indicating 1) the number of dimensions, 2) a vector of desired landmark configuration, 3) a vector with names or number of desired curve configuration, 4) the number of semilandmarks for each curve, and then 5) the names of the maximum number of curves that can be found in the dataset.
  # lm.scale: Whether or not to rescale the configurations.
  # cv.fixed: Whether or not to remove the first and last points of each semilandmark curve if these points are already present in the fixed landmarks.

  if(!is.list(lmks)) stop("landmark data must be structured as a specimen-based list")
  n <- length(lmks)
  fids <- vapply(lmks, function(qx) qx$id, character(1), USE.NAMES = FALSE)
  ndims <- model[[1]] #modified to follow new template
  nlms <- length(model[[2]]) #modified to follow new template
  ncurves <- length(model[[3]]) #modified to follow new template
  lms <- model[[2]]
  # 1st: Spot and remove specimens not compatible with the template.
  id2rm <- character()

###### modified seccion------------------------------------------------------------------
  
  #loops to know which curves you want to use
  curves.id <- model[[5]]
  
  if (!is.numeric(model[[3]])) { 
    names.cvs <- model[[3]] 
    nums.cvs <- which(curves.id %in% names.cvs)}
  
  if (is.numeric(model[[3]])) {
    names.cvs <- curves.id[model[[3]]] 
    nums.cvs <- model[[3]] }
            
  bcvs <- NULL  # .: Same number of curves.
  blms <- NULL # .: Same fixed landmark configuration.

  for (i in 1:length(lmks)) {
    temp.lm <- as.numeric(gsub("^..","",rownames(lmks[[i]]$lm)))
    fit.lm.conf <- length(which(model[[2]] %in% temp.lm))==length(model[[2]])
    blms <- c(blms, fit.lm.conf)

    temp.cvs <- unlist(attributes(lmks[[i]]$cv.lm))
    fit.cvs.conf <- ifelse(is.null(attributes(lmks[[i]]$cv.lm)), 
                           lmks[[i]]$ncvs >= length(names.cvs),  #if null (ie. if tps file)
                           length(which(names.cvs %in% temp.cvs))==length(names.cvs) #if not (xml file)
                           )
    bcvs <- c(bcvs, fit.cvs.conf)
    
    if (!is.null(attributes(lmks[[i]]$cv.lm)) & fit.cvs.conf & fit.lm.conf) { #all curves are named and landmarks fit the desired configuration
    
      lmks[[i]]$ncvs <- length(names.cvs) #update curve values given the desired configuration
      lmks[[i]]$cv.pts <- lmks[[i]]$cv.pts[names.cvs]
      lmks[[i]]$pcvs <- sum(lmks[[i]]$cv.pts)
      lmks[[i]]$cv.lm <- lmks[[i]]$cv.lm[names.cvs]
  
      lmks[[i]]$plm <- length(model[[2]]) #update landmark values given the desired configuration
      lmks[[i]]$lm <- lmks[[i]]$lm [which(temp.lm %in% model[[2]]),]
      lmks[[i]]$p <- sum(lmks[[i]]$cv.pts + lmks[[i]]$plm)
      }
        
    if (is.null(attributes(lmks[[i]]$cv.lm)) & lmks[[i]]$ncvs == length(curves.id) & fit.lm.conf) { #curves don't have names (tps file) but all curves are present and landmarks fit the desired configuration
    
      lmks[[i]]$ncvs <- length(nums.cvs) #update curve values given the desired configuration
      lmks[[i]]$cv.pts <- lmks[[i]]$cv.pts[nums.cvs]
      lmks[[i]]$pcvs <- sum(lmks[[i]]$cv.pts)
      lmks[[i]]$cv.lm <- lmks[[i]]$cv.lm[nums.cvs]
  
      lmks[[i]]$plm <- length(model[[2]]) #update landmark values given the desired configuration
      lmks[[i]]$lm <- lmks[[i]]$lm [which(temp.lm %in% model[[2]]),]
      lmks[[i]]$p <- sum(lmks[[i]]$cv.pts + lmks[[i]]$plm)
      }     
  }

  names(blms) <- names(lmks)
  blms <- !blms #record who differs from the desired fixed landmark configuration
  names(bcvs) = names(lmks)
  bcvs <- !bcvs #record who differs from the desired curved configuration
 
  id2rm <- fids[(blms+bcvs)>0] # registrer those that need to be removed
  id2rm.lm <- fids[blms]
  id2rm.cv <- fids[bcvs]
  
  # .: Remove spotted configurations.
  if(length(id2rm) > 0) {
    lmks <- lmks[!(fids %in% id2rm)]
    fids <- vapply(lmks, function(qx) qx$id, character(1), USE.NAMES = FALSE)
  }

###### end modified section ---------------------------------------------------------------------------------------

  # .: Enough semilandmarks.
  ncvs <- vapply(lmks, function(qx) qx$ncvs, numeric(1)) #moved here from above---------------------------------
  n <- length(lmks) #redefini n para seguir
  fs <- paste0("CV", 1:max(ncvs))
  mcvs <- matrix(0L, n, max(ncvs), dimnames = list(names(lmks), fs))
  for(i in 1:n) mcvs[i,1:length(lmks[[i]]$cv.pts)] <- lmks[[i]]$cv.pts
  bcvs <- matrix(FALSE, n, max(ncvs), dimnames = list(names(lmks), fs))
  for(i in 1:max(ncvs)) bcvs[,i] <- (mcvs[,i] >= model[[4]][i]) #modified model[i+2] by model[[4]][i] to follow new template
  k <- apply(bcvs, 1, all)
  id2rm.slm <- names(k[!k])
  #if(any(!k)) warning("configurations removed : ", length(id2rm), " : ", toString(id2rm)," : curves undersampled compared to the template")
  # .: Missing landmarks. #### This part is no longer needed
#  bnas <- vapply(lmks, function(qx) any(is.na(qx$lm)), logical(1)) 
#  if(any(bnas)) id2rm <- c(id2rm, fids[bnas])
  # .: Remove spotted configurations.
  if(length(id2rm.slm) > 0) {
    id2rm.slm <- unique(id2rm.slm)
    lmks <- lmks[!(fids %in% id2rm.slm)]
    fids <- vapply(lmks, function(qx) qx$id, character(1), USE.NAMES = FALSE)  
  }
  
  #save full list of removed taxa
  id2rm <- c(id2rm, id2rm.slm)
  id2m <- as.vector(id2rm)
  id2rm <- unique(id2rm)
  
  # .: Warning message of removed specimens.
  if(length(id2rm) > 0) {
    warning("total configurations removed : ", length(id2rm))
    if(length(id2rm.lm>0)) warning(length(id2rm.lm), " specimens do not conform to the fixed landmarks template : ", toString(id2rm.lm))
    if(length(id2rm.cv)>0) warning(length(id2rm.cv), " specimens do not conform to the semilandmark template : ", toString(id2rm.cv))
    if(length(id2rm.slm)>0) warning(length(id2rm.slm), " specimens with curves undersampled compared to the template : ", toString(id2rm.slm))
  }
    
  # 2nd: Fit remaining specimens to the template.
  #model <- abs(model)
  xs <- ys <- character()
  if(nlms > 0) {
    xs <- c(xs, paste0("LM-", model[[2]])) #added model[[2]] to name landmakrs given the desired template
    ys <- c(ys, rep("LM", nlms))
  }
  if(ncurves > 0) for(i in 1:ncurves) {
    xs <- c(xs, paste0("CV", i, "-", 1:model[[4]][i])) # modified to follow new template
    ys <- c(ys, rep(paste0("CV", i), model[[4]][i])) # modified to follow new template
  }
  m <- array(NA_real_, dim = c(sum(nlms, model[[4]]), ndims, length(lmks)), # modified to follow new template
    dimnames = list(xs, c("x","y","z")[1:ndims], fids))
  # .: Fixed landmarks.
  if(nlms > 0) {
    for(i in 1:length(lmks)) m[1:nlms,,i] <- lmks[[i]]$lm 
  }
  # .: Curves of semilandmarks.
  p <- 0
  q <- nlms
  for(j in 1:ncurves) {
    for(i in 1:length(lmks)) {
      mcvi <- lmks[[i]]$cv.lm[[j]]
      x <- (q+p+1):(q+p+model[[4]][j]) # modified to follow new template
      if(cv.fixed) {
        mcvi <- geomorph:::evenPts(mcvi, model[[4]][j]+2) # modified to follow new template
        mcvi <- mcvi[-c(1,model[[4]][j]+2),] # modified to follow new template
      } else {
        mcvi <- geomorph:::evenPts(mcvi, model[[4]][j]) # modified to follow new template
      }
      m[x,,i] <- mcvi
    }
    p <- p + model[[4]][j] # modified to follow new template
  }
  # 3rd: Possibly rescale configurations.
  if(lm.scale) {
    xscal <- vapply(lmks, function(dx) dx$scale, numeric(1))
    # .: Fix scales of zero.
    kscl <- (xscal == 0)
    if(sum(kscl, na.rm = TRUE) > 0) xscal[which(kscl)] <- NA
    attr(m, "scales") <- xscal
    # .: Fix absence of a scale.
    k <- is.na(xscal)
    if(all(k)) {
      warning("configurations not rescaled (not included)")
    } else {
      for(i in 1:length(lmks)) if(!k[i]) m[,,i] <- m[,,i] * xscal[i]
    }
    if(any(k)) warning("configurations unscaled : ", sum(k), " : ", toString(names(xscal)[k]))
  } else {
    warning("configurations not rescaled (not requested)")
  }
  # 4th: Additional fixes.
  # .: StereoMorph XML mirror hack.
  # Landmark data read from Stereomorph files are mirrored along the y-axis
  #   because these are reversed in StereoMorph for compatibility
  #   with the underlying images used for digitization (R constraint).
  miro <- vapply(lmks, function(qx) qx$format, character(1))
  k <- (miro == "xml")
  for(i in 1:length(lmks)) if(k[i]) m[,2,i] <- -m[,2,i]
  # 5th: Add further information on the landmark data as attributes.
  attr(m, "lmgroup") <- factor(ys, unique(ys))
  attr(m, "removed") <- id2rm
  return(m)
}


# Function to compute morphological disparity as the sum of variances (see Wills 2001).
shapSumVar <- function(m, ci = TRUE, nbot = 1000) {
  # Sum of Variances: core function.
  SOV <- function(m) {
    ctroid <- colMeans(m)
    y <- sweep(m, 2, ctroid, "-")
    y <- sum(colMeans(y^2))
    return(y)
  }
  # Possibly resample with replacement (bootstrap) to get 95% confidence intervals.
  if(ci) {
    n <- nrow(m)
    xbot <- rep(NA_real_, nbot)
    for(i in 1:nbot) xbot[i] <- SOV(m[(sample(1:n, n, replace=T)),,drop=F])
    x <- mean(xbot, na.rm = TRUE)
    attr(x, "ci") <- quantile(xbot, c(0.025, 0.975), type = 6, na.rm = TRUE)
  } else {
    x <- SOV(m)
  }
  return(x)
}

                 
#YAML function hack. 
#This function allows reading a YAML file and creates a nested (flat=FALSE) or non-nested (flat=TRUE) dataframe.

#first check dependencies and install them if necesary
if (!any(installed.packages()[, 1] == "yaml")) {
  install.packages("yaml")
}

if (!any(installed.packages()[, 1] == "jsonlite")) {
  install.packages("jsonlite")
}

#load dependencies
require(jsonlite, warn.conflicts = F)
require(yaml, warn.conflicts = F)

#function
yaml_read <- function (file, flat = TRUE) {
	out.1 <- read_yaml (file=file)	
	out.1 <- toJSON(out.1)
	out.1 <- fromJSON(out.1, flatten = flat)
	out <- out.1
	if (flat == TRUE) {
	    out <- data.frame(unlist(out.1$ID))
	    for (i in 2:length(colnames(out.1))) {
	        out = cbind(out, unlist(out.1[,i]))
	        }
	    colnames(out) = colnames(out.1)
	} 
	return(out)
}
