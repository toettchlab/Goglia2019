# Take care of importing various libraries to use
# This requires one libraries in addition to the 'vanilla' FIJI installation: trackmate_extras
# Trackmate_extras can be obtained from: https://github.com/tinevez/TrackMate-extras

import sys
import os

from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import LogDetectorFactory
from fiji.plugin.trackmate.tracking.sparselap import SparseLAPTrackerFactory
from fiji.plugin.trackmate.tracking import LAPUtils

from ij import IJ
from ij import WindowManager

from ij.io import DirectoryChooser

import fiji.plugin.trackmate.Spot as Spot
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
import fiji.plugin.trackmate.features.track.TrackDurationAnalyzer as TrackDurationAnalyzer

import fiji.plugin.trackmate.extra.spotanalyzer.SpotMultiChannelIntensityAnalyzerFactory as SpotMultiChannelIntensityAnalyzerFactory

import java.util.ArrayList as ArrayList

# First, prompt the user for a directory of TIFF images to analyze
srcDir = DirectoryChooser("Choose!").getDirectory()
#if not srcDir:
	# User canceled
	#return

# Now, loop through all files and analyze them!
for root, directories, filenames in os.walk(srcDir):
	for filename in filenames:
		# Skip if not a TIFF file
		if not filename.endswith(".tif"):
			continue
		
		path = os.path.join(root, filename)
		
		#----------------------------------------
		# Load the images and prep output files
		#----------------------------------------
		imp = IJ.openImage(path)
		
		# Write output to this file, which is named identically to the image but with suffix ".txt"
		OUTFILE = os.path.join(root, filename+".txt")

		# This is a weird dimension swap that seems to be useful for some TIFF stacks where dimensions get mis-ordered.
		# Swap Z and T dimensions if T=1
		dims = imp.getDimensions() # default order: XYCZT
		if (dims[4] == 1):
			imp.setDimensions( dims[2,4,3] )
		
		# Get the number of channels. 
		# IMPORTANT: This code assumes that the H2B channel is Channel 2 and ErkKTR is Channel 1
		nChannels = imp.getNChannels()
		
		
		#----------------------------
		# Create the model object now
		#----------------------------
		model = Model()
		
		# Send all messages to ImageJ log window.
		model.setLogger(Logger.IJ_LOGGER)    
		
		#------------------------
		# Prepare settings object
		#------------------------
		settings = Settings()
		settings.setFrom(imp)
		
		# Use the spot analyzer for assessing fluorescence intensities in each channel
		settings.addSpotAnalyzerFactory( SpotMultiChannelIntensityAnalyzerFactory() )
		
		# Configure the detector for finding nuclei
		settings.detectorFactory = LogDetectorFactory()
		settings.detectorSettings = { 
			'DO_SUBPIXEL_LOCALIZATION' : True,
			'RADIUS' : 9., # KEY PARAMETER: expect a 9 um nucleus radius, which works very well for keratinocytes
			'TARGET_CHANNEL' : 2, # KEY PARAMETER: H2B for nucleus segmentation is Channel 2
			'THRESHOLD' : 2.,
			'DO_MEDIAN_FILTERING' : False,
		}  
		
		# Configure tracker - We want to allow merges and fusions
		settings.trackerFactory = SparseLAPTrackerFactory()
		settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap() 
		settings.trackerSettings['LINKING_MAX_DISTANCE'] = 5. # KEY PARAMETER: don't let nuclei move more than 5 um between frames
		settings.trackerSettings['ALLOW_GAP_CLOSING'] = True
		settings.trackerSettings['MAX_FRAME_GAP'] = 2 
		settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = 5.
		settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = False
		settings.trackerSettings['ALLOW_TRACK_MERGING'] = False
		
		#-------------------
		# Instantiate plugin
		#-------------------
		trackmate = TrackMate(model, settings)
		
		if not trackmate.checkInput() or not trackmate.process():
			IJ.log('Could not execute TrackMate: ' + str( trackmate.getErrorMessage() ) )
		else:
			IJ.log('TrackMate completed successfully.' )
			IJ.log( 'Found %d spots in %d tracks.' % ( model.getSpots().getNSpots( True ) , model.getTrackModel().nTracks( True ) ) )
		
		# Now open the output file & write a header with each field you need. Fields:
		# Spot_ID, which is unique for each identified object
		# Track_ID, which is unique for each 'track' - i.e. same object over time
		# Frame, which specifies the current frame
		# X-Y-Z, which are the spatial locations of the tracked object at the current frame. 
		headerStr = '%10s %10s %10s %10s %10s %10s' % ( 'Spot_ID', 'Track_ID', 'Frame', 'X', 'Y', 'Z' )
		rowStr = '%10d %10d %10d %10.1f %10.1f %10.1f'
		# Finally, we also want the mean intensity of each tracked object in each frame.
		# For this, we get an additional column for each channel in the image.
		for i in range( nChannels ):
			headerStr += ( ' %10s'  % ( 'C' + str(i+1) ) )
			rowStr += ( ' %10.1f' )
		
		# Open the output file
		file = open(OUTFILE, "w")
		# Write the header line
		file.write( headerStr)
		file.write( "\n" )
		
		# Now get all tracks
		tm = model.getTrackModel()
		trackIDs = tm.trackIDs( True )
		
		# For each track
		for trackID in trackIDs:
			# get the spots in the current track
			spots = tm.trackSpots( trackID )
		
			# This is the list of all spots
			ls = ArrayList( spots );
			
			# Now, take that list and write it out to the file!
			for spot in ls:
				values = [  spot.ID(), trackID, spot.getFeature('FRAME'), \
					spot.getFeature('POSITION_X'), spot.getFeature('POSITION_Y'), spot.getFeature('POSITION_Z') ]
				for i in range( nChannels ):
					values.append( spot.getFeature( 'MEAN_INTENSITY%02d' % (i+1) ) )
			
				file.write( rowStr % tuple( values ) ) 
				file.write( "\n" )
		# Close the file and you're done with this TIFF/output pair!
		file.close()