# analyze survey data for free (http://asdfree.com) with the r language
# pesquisa mensal de emprego

# # # # # # # # # # # # # # # # #
# # block of code to run this # #
# # # # # # # # # # # # # # # # #
# library(downloader)
# setwd( "C:/My Directory/PME/" )
# source_url( "https://raw.github.com/ajdamico/usgsd/master/Pesquisa%20Mensal%20de%20Emprego/download%20all%20microdata.R" , prompt = FALSE , echo = TRUE )
# # # # # # # # # # # # # # #
# # end of auto-run block # #
# # # # # # # # # # # # # # #

# if you have never used the r language before,
# watch this two minute video i made outlining
# how to run this script from start to finish
# http://www.screenr.com/Zpd8

# anthony joseph damico
# ajdamico@gmail.com

# if you use this script for a project, please send me a note
# it's always nice to hear about how people are using this stuff

# for further reading on cross-package comparisons, see:
# http://journal.r-project.org/archive/2009-2/RJournal_2009-2_Damico.pdf


#################################################
# analyze the pesquisa mensal de emprego with R #
#################################################


# set your working directory.
# the PME data files will be stored here
# after downloading and importing them.
# use forward slashes instead of back slashes

# uncomment this line by removing the `#` at the front..
# setwd( "C:/My Directory/PME/" )
# ..in order to set your current working directory


# if you want to overwrite previously-download files
# redownload.all <- TRUE
# uncomment the above line.
# if the object `redownload.all` does not exist,
# then this program will, by default, _not_ re-download
# pme months that are already saved in your current working directory

# warning: this command must be run before any other
# internet-accessing lines in the session
setInternet2(TRUE)
# you also might need administrative rights



# remove the # in order to run this install.packages line only once
# install.packages( c( "SAScii" , "downloader" ) )


############################################
# no need to edit anything below this line #

# # # # # # # # #
# program start #
# # # # # # # # #


library(SAScii) 	# load the SAScii package (imports ascii data with a SAS script)
library(downloader)	# downloads and then runs the source() function on scripts from github


# load the download.cache and related functions
# to prevent re-downloading of files once they've been downloaded.
source_url( 
	"https://raw.github.com/ajdamico/usgsd/master/Download%20Cache/download%20cache.R" , 
	prompt = FALSE , 
	echo = FALSE 
)


# create a temporary file and a temporary directory..
tf <- tempfile() ; td <- tempdir()


# download the sas importation scripts..
download.cache( 
	"ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Mensal_de_Emprego/Microdados/documentacao/Documentacao.zip" , 
	tf 
)


# ..and unzip those files to the local disk
z <- unzip( tf , exdir = td )


# hold onto only the filename containing the word `INPUT`
input <- z[ grep( "INPUT" , z ) ]


# download the contents of the ftp directory for all microdata
download.cache(
	"ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Mensal_de_Emprego/Microdados/" , 
	tf
)


# if this object does not exist, then create it
# (see `redownload.all` note above) for more detail
# about what it does
if ( !exists( 'redownload.all' ) ) redownload.all <- FALSE


# read the text of the microdata ftp into working memory
ftp.listing <- readLines( tf )

# extract the text from all lines containing a year of microdata
year.lines <- ftp.listing[ grep( '/Microdados/20' , ftp.listing , fixed = TRUE ) ]

# figure out the names of those year directories
available.years <- rev( gsub( "(.*<B>)(.*)(</B>.*)" , "\\2" , year.lines ) )
# now `available.years` should contain all of the available years on the pme ftp site

# loop through each of the available years
for ( year in available.years ){

	# take a look inside the year-specific ftp filepath
	download.cache(
		paste0(
			"ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Mensal_de_Emprego/Microdados/" , 
			year 
		) , 
		tf
	)

	# just like above, read those lines into working memory
	year.ftp.listing <- readLines( tf )
	
	# store each line containing the text `.zip`
	# into a character vector `zip.lines`
	zip.lines <- year.ftp.listing[ grep( '.zip' , year.ftp.listing , fixed = TRUE ) ]
	
	# extract the precise filename of the `.zip` file
	zip.filenames <- gsub( '(.*zip\">)(.*)</A>' , "\\2" , zip.lines )

	# in 2008, the files are named by three-letter month.
	# in portuguese, sorted alphabetically, april is the first month, followed by august, and so on.
	if ( year == 2008 ){

		available.months <- c( '04' , '08' , '12' , '02' , '01' , '07' , '06' , '05' , '03' , '11' , '10' , '09' )
	
	} else {

		# for all zip file names,
		# find the pattern starting with `PMEnova`
		# and ending with the year x month dot zip.
		available.months <- gsub( "(PMEnova)(.)([0-9][0-9])([0-9][0-9][0-9][0-9])([0-9]?)(.zip)" , "\\3" , zip.filenames )
	
	}

	# if `redownload.all` has not been indicated..
	if ( !redownload.all ){
	
		# determine the `.rda` filepath of all available months within this year
		all.savefiles <-
			paste0( 
				'pme ' ,
				year , 
				' ' ,
				available.months , 
				'.rda'
			)
		# this `.rda` construction will determine which files are already in the working directory
		
		# these are the files that need to be downloaded, and..
		available.months <-
			available.months[ !file.exists( all.savefiles ) ]
		
		# ..according to the same pattern,
		# these are the zipped filenames that need to be downloaded.
		zip.filenames <-
			zip.filenames[ !file.exists( all.savefiles ) ]
			
		# in other words, throw out the files that already exist.
	}
	
	
	# loop through the `zip.filenames` character vector..
	for ( i in seq_along( zip.filenames ) ){
	
		# construct the full ftp path to the current zipped file
		current.zipfile <-
			paste0(
				"ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Mensal_de_Emprego/Microdados/" , 
				year ,
				"/" ,
				zip.filenames[ i ]
			)	
		
		# construct the full `.rda` path to the save-location on your local disk
		current.savefile <-
			paste0( 
				'pme ' ,
				year , 
				' ' ,
				available.months[ i ] , 
				'.rda'
			)
		
		# try to download the zipped file..
		attempt.one <- try( download.cache( current.zipfile , tf , mode = 'wb' ) , silent = TRUE )
		
		# ..but if the first attempt fails,
		# wait for three minutes and try again.
		if ( class( attempt.one ) == 'try-error' ){

			Sys.sleep( 180 )
			
			download.cache( current.zipfile , tf , mode = 'wb' )
			
		}
			
		# unzip the current text file to the temporary directory..
		cur.textfile <- unzip( tf , exdir = td )
		
		# ..and read that text file directly into an R data.frame
		# using the sas importation script downloaded before this big fat loop
		x <-
			read.SAScii(
				cur.textfile ,
				input
			)
		
		# convert all column names to lowercase
		names( x ) <- tolower( names( x ) )
		
		# save the data.frame object to the local disk
		save( x , file = current.savefile )
		
		# clear the `x` data.frame object from working memory
		rm( x )
		
		# clear up RAM
		gc()
		
	}
	
}


# remove the temporary file..
file.remove( tf )
# ..and the contents of the temporary directory
unlink( td , recursive = TRUE )
# from your local disk

# print a reminder: set the directory you just saved everything to as read-only!
message( paste0( "all done.  you should set the file " , getwd() , " read-only so you don't accidentally alter these tables." ) )


# for more details on how to work with data in r
# check out my two minute tutorial video site
# http://www.twotorials.com/

# dear everyone: please contribute your script.
# have you written syntax that precisely matches an official publication?
message( "if others might benefit, send your code to ajdamico@gmail.com" )
# http://asdfree.com needs more user contributions

# let's play the which one of these things doesn't belong game:
# "only you can prevent forest fires" -smokey bear
# "take a bite out of crime" -mcgruff the crime pooch
# "plz gimme your statistical programming" -anthony damico