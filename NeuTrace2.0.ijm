/*
 * NeuTrace.ijm
 * Written by JFRANCO in ImageJ development environment
 * 
 * 10 OCT 2022
 * 
 * This macro is made to work with a .nd2 file, as specified by the user 
 * and guide the user through the neurite tracing process. Every neurite 
 * traced will be saved as an ROI and a straightened neurite image will be 
 * produced. 
 * 
 * This macro is meant for sharing with attribution and not for commercial use. 
 */

/* 
 ************************** MACRO NeuTrace.ijm ******************************
 */
 
// *** HOUSEKEEPING ***
run("Close All");										// Close irrelevant images
roiManager("reset");									// Reset ROI manager
timeStamp = getTimeStamp();								// Time stamp for saving multiple versions

// *** GET THE FILE TO ANALYZE ***
Dialog.create("Welcome to NeuTrace2.0");
Dialog.addMessage("This macro will open your .nd2 file of choice\n"+
	"and guide you through the neurite tracing process.\n"+
	"When presented with the BioFormats opener, make sure 'Split Channels' is NOT checked.\n"+
	"Click 'OK' when you're ready to proceed.");
Dialog.show();
impath = File.openDialog("Choose image to open");    	// Ask user to find file 
open(impath);											// Open the image	

// *** SETUP VARIABLES BASED ON FILENAME & PATH ***
fn = File.name;											// Save the filename (with extension)
fnBase = File.getNameWithoutExtension(impath);			// Get image name
fnROIs = fnBase+".ROIs."+timeStamp+".zip";				// Filename for ROI set generated
fnSS = fnBase+".SS";									// Filename for substack generated
fnMP = fnBase+".MP";									// Filenmae for max projection generated
fnPL = fnBase+".PL";									// Filename for plots generated
fnMD = fnBase+".MD.csv";								// Filename for metadata from the tracing process
wd = File.getDirectory(impath);							// Gets path to where the image is stored
rootInd = lastIndexOf(wd, "RawImages");					// Gets index in string for where root directory ends
root = substring(wd, 0, rootInd);						// Creates path to root directory
dirNT = root+"/NeuTraceResults/";						// Main directory for all things generated via NeuTrace2.0
dirROIs = dirNT+"ROIs/";								// Subdirectory for all ROI.zip files generated from each tracing session
dirJNs = dirNT+"JustNeurites/";							// Subdirectory for straightened neurite views saved as .tif 
dirMD = dirNT+"Metadata/";								// Subdirectory for metadata related to each tracing session
dirPTs = dirNT+"Plots/";								// Subdirectory for plots of pixel intensities across the neurite   
dirSSs = dirNT+"Substacks/";							// Subdirectory for substacks generated for each original z-stack
dirMPs = dirNT+"MaxProjections/";						// Subdirectory for max projections generated for each original z-stack

neuID = 0;												// Index for saving neurite traces.
linewidth = 8;											// Number of pixels to use for straightened image.

// *** SETUP DIRECTORIES IF APPLICABLE ***
// Make directory for storing new files
if (!File.isDirectory(dirNT)) {
	File.makeDirectory(dirNT);
	if (!File.isDirectory(dirROIs)) {
		// Create subdirectories
		File.makeDirectory(dirROIs);
		File.makeDirectory(dirJNs);
		File.makeDirectory(dirMD);
		File.makeDirectory(dirPTs);
		File.makeDirectory(dirSSs);
		File.makeDirectory(dirMPs);
	}
}

// Create a metadata sheet for the image -- Current code assumes image has not yet been traced and will save over existing
//       This approach will be changed in the future to instead just update the sheet if it exists
initResTable(dirMD+fnMD);

// *** HAVE USER MAKE SUBSTACK ***
Stack.getDimensions(width, height, channels, slices, frames);
for (i = 0; i <= channels; i++) {
	Stack.setChannel(i);
	run("HiLo");
}

waitForUser("Examine the Z-stack and choose which images to include in the max projection.\n"+
	"You will enter the specifications in the next dialog box.");
// Create dialog box	
Dialog.create("Create Substack");
Dialog.addMessage("Choose which channel and slices to use for making the max projection image.");
Dialog.addString("Channel Start","2");
Dialog.addString("Channel End",channels);
Dialog.addString("Slice Start","1");
Dialog.addString("Slice End", slices);
Dialog.show();
// Read in values from dialog box
chStart = Dialog.getString();
chEnd = Dialog.getString();
slStart = Dialog.getString();
slEnd = Dialog.getString();

// Make the substack to spec and save
run("Make Substack...", "channels="+chStart+"-"+chEnd+" slices="+slStart+"-"+slEnd);
saveAs("Tiff",dirSSs+fnSS+".tif");
Stack.getDimensions(width, height, channels, slices, frames);					// Update dimensions

// Create the max projection to be used as a tracing guide
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff",dirMPs+fnMP+".tif");												

// Close unneccessary images
close("\\Others");

// *** BEGIN TRACING PROCESS

// Explain to the user how to add neurite traces to the ROI manager
waitForUser("Select the segmented line tool by right clicking over the polyline icon in the toolbar.\n"+
	"Once selected, double click the same icon and check the 'Spline Fit' box.\n"+
	"In the ROI Manager window select 'Show All' and 'Labels'.\n"+
	"After this you'll begin tracing neurites and adding them to the ROI manager.");
	
// Trace neurite, save ROI, create straightened processed view & save
setTool("polyline");
run("Line Width...", "line="+linewidth);
waitForUser("Trace a neurite then press [t] to add it the ROI to the manager.\n"+
			"Trace as many neurites as necessary, then click 'OK' to save each.");

// *** BEGIN PROCESSING TRACES ***

// Split the max projection stack into two seperate images
//    This was the only way I could get run(grays) and plotting to work
selectWindow(fnMP+".tif");
run("Split Channels");			

// Revert look up table to greys rather than HiLo						
for (j = 0; j < channels; j++) {
	selectWindow("C"+toString(j+1)+"-"+fnMP+".tif");
    run("Grays");
}

// Begin iterating through the traces/ROIs
n = roiManager('count');
for (i = 0; i < n; i++) {
	
	// Update results table for this specific ROI 	
	setResult("image_name", i, fnBase);
	setResult("timestamp", i, timeStamp);
	setResult("slice_start",i, slStart);
	setResult("slice_end",i, slEnd);
	setResult("neurite_id",i, "JN_"+i);					// ROI ID is saved based on index
	setResult("linewidth",i, linewidth);
	
	// Setup filename based on ROI ID 
	fnJN = fnBase+".JN_"+i;
    
    // Iterate through the channels and create .tifs for each
    for (j = 0; j < channels; j++) {
    	
    	// Create and save straightened neurite view for active channel
    	selectWindow("C"+toString(j+1)+"-"+fnMP+".tif");
    	roiManager('select', i);
    	run("Straighten...");
    	getDimensions(wJN, hJN, cJN, sJN, fJN);							// This will store the length of the trace as wJN
    	cMean = getValue("Mean");										// This returns the mean grey value for the entire trace
    	saveAs("Tiff",dirJNs+fnJN+".C_"+toString(j+1)+".tif");
    	close();
    	
		// Store the grey value in the right column based on active channel
		if (j==0) {
			setResult("c1_grey",i,cMean);
		}
 		if (j==1) {
			setResult("c2_grey",i,cMean);
		}
		
 		// Create a new plot for this channel
 		//    Might not need to re-select ROI 
    	selectWindow("C"+toString(j+1)+"-"+fnMP+".tif");
    	roiManager('select', i);
    	run("Plot Profile");
    	saveAs("Tiff",dirPTs+fnPL+".JN_"+i+".C"+toString(j+1)+".tif");
    }
    
    // Combine the two plots for the channels
    selectWindow(fnPL+".JN_"+i+".C2.tif");
    Plot.setStyle(0, "red,none,3.0,Line");
    Plot.getLimits(xminT, xmaxT, yminT, ymaxT);
    selectWindow(fnPL+".JN_"+i+".C1.tif");
    Plot.setStyle(0, "magenta,none,3.0,Line");
    Plot.getLimits(xminO, xmaxO, yminO, ymaxO);
	Plot.addFromPlot(fnPL+".JN_"+i+".C2.tif", 0);
	Plot.addLegend("C1\nC2", "Auto");
	Plot.getLimits(xMin, xMax, yMin, yMax);
	// Determine which of the two plots has the greater yMax and use this to set axis limits
	if (ymaxT > ymaxO) {
		yMax = ymaxT;
	}else{
		yMax = ymaxO;
	}
    Plot.setLimits(xMin, xMax, 0, yMax);
    
    // Make and save a high resolution version of the plots
	Plot.makeHighResolution("Plot of MAX_PA_001.05.01.03.Zs.3C-1.png_HiRes",4.0);
    saveAs("Tiff",dirPTs+fnPL+".JN_"+i+".C1a2.tif");
    
    // Close plots
    close();
    selectWindow(fnPL+".JN_"+i+".C1.tif");
    close();
    selectWindow(fnPL+".JN_"+i+".C2.tif");
    close();
    
    // Update the results table
	setResult("length",i,wJN);
	setResult("height",i,hJN);
	setResult("channels",i,cJN);
	setResult("slices",i,sJN);
	setResult("frames",i,fJN);
}
// Save all of the ROIs in one zip file that can be reopened using the ROI manager
roiManager("save", dirROIs+fnROIs);

// Save the metadata from tracing
selectWindow("Results");
saveAs("Results", dirMD+fnMD);

waitForUser("Take a screenshot of the max projection with all ROIs shown then click 'OK' to exit.");
close("*");
exit;

/*
 * ************************	 	FUNCTION DEFINITIONS		**********************	
 */
function getTimeStamp(){
	print("\\Clear");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	month++;
	if (month<10) {month = "0"+toString(month);}
	if (dayOfMonth<10) {month = "0"+toString(dayOfMonth);}
	date = toString(year)+ month + dayOfMonth;
	if (hour<10) {hour = "0"+toString(hour);}
	if (minute<10) {minute = "0"+toString(minute);}
	time = toString(hour)+"h"+toString(minute) +"m";
	arrDateTime = Array.concat(date + "_"+ time);
	Array.print(arrDateTime);
	strDateTime = toString(getInfo("log"));
	strDateTime = substring(strDateTime, 0, lengthOf(strDateTime)-1);
	return strDateTime;
}

function setupMD(fPath){
// FX Reads in csv file and setsup info as a Results table
//    In particular, reads in CCP_###.MetaD.NS_##.##.csv
	lineseparator = "\n";
	cellseparator = ",\t";

	// copies the whole RT to an array of lines
	lines=split(File.openAsString(fPath), lineseparator);

	// recreates the columns headers
	labels=split(lines[0], cellseparator);
	if (labels[0]==" "){
		k=1; // it is an ImageJ Results table, skip first column
	}else{
	k=0; // it is not a Results table, load all columns
	}
	for (j=k; j<labels.length; j++)
		setResult(labels[j],0,0);
		// dispatches the data into the new RT
	run("Clear Results");
	for (i=1; i<lines.length; i++) {
		items=split(lines[i], cellseparator);
	for (j=k; j<items.length; j++)
   		setResult(labels[j],i-1,items[j]);
	}
	updateResults();
}

function initResTable(fPathMD){
// FUNCTION RUNS IF THIS IS THE FIRST TIME SETTING UP DIRECTORIES

	// Setup MD Results Table based on list of images in ProcessedWCS directory
	run("Clear Results");											 
	setResult("image_name", 0, 'TBD');
	setResult("timestamp", 0, 'TBD');
	setResult("slice_start", 0, 'TBD');
	setResult("slice_end", 0, 'TBD');
	setResult("neurite_id", 0, 'TBD');
	setResult("linewidth", 0, linewidth);
	setResult("length",0,'TBD');
	setResult("height",0,'TBD');
	setResult("channels",0,'TBD');
	setResult("slices",0,'TBD');
	setResult("frames",0,'TBD');
	setResult("c1_grey",0,'TBD');
	setResult("c2_grey",0,'TBD');
	updateResults();
		
	// Immediately create a saved copy of the MD file
	selectWindow("Results");
	saveAs("Results", fPathMD);
}
