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
fnROIs = fnBase+"ROIs."+timeStamp+".zip";
path = File.getDirectory(impath);						// Gets path to where the image is stored
dirNT = path+"/NeuTrace_"+fnBase+"/";
dirROIs = dirNT+"ROIs/";
dirJNs = dirNT+"JustNeurites/";
dirMD = dirNT+"Metadata/";

neuID = 0;												// Index for saving neurite traces.
linewidth = 8;											// Number of pixels to use for straightened image.

// *** SETUP DIRECTORIES IF APPLICABLE ***
// Make directory for storing new files
if (!File.isDirectory(dirNT)) {
	File.makeDirectory(dirNT);
	if (!File.isDirectory(dirROIs)) {
		File.makeDirectory(dirROIs);
		File.makeDirectory(dirJNs);
		File.makeDirectory(dirMD);
	}
}

// *** HAVE USER MAKE SUBSTACK ***
Stack.getDimensions(width, height, channels, slices, frames);
print(channels);
for (i = 0; i <= channels; i++) {
	Stack.setChannel(i);
	run("HiLo");
}

waitForUser("Examine the Z-stack and choose which images to include in the max project.\n"+
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
run("Make Substack...", "channels="+chStart+"-"+chEnd+" slices="+slStart+"-"+slEnd);

// *** BEGIN TRACING PROCESS
// Create the max projection to be used as a tracing guide
run("Z Project...", "projection=[Max Intensity]");
// Explain to the user how to add neurite traces to the ROI manager
waitForUser("Select the segmented line tool by right clicking over the icon in the toolbar.\n"+
	"Once selected, double click the same icon and check the 'Spline Fit' box.\n"+
	"In the ROI Manager window select 'Show All' and 'Labels'."+
	"After this you'll begin tracing neurites and adding them to the ROI manager.");
	
// Trace neurite, save ROI, create straightened processed view & save
setTool("polyline");
run("Line Width...", "line="+linewidth);
waitForUser("Trace a neurite then press [t] to add it the ROI to the manager.\n"+
			"Trace as many neurites as necessary, then click 'OK' to save each.");
n = roiManager('count');
for (i = 0; i < n; i++) {
	fnJN = fnBase+".JN."+n;
    roiManager('select', i);
    run("Straighten...", "title=MAX_"+fn+" line="+linewidth+" process");
    saveAs("Tiff",dirJNs+fnJN+".tif");
    close();
}
// Save all of the ROIs in one zip folder
roiManager("save", dirROIs+fnROIs);

waitForUser("Take a screenshot of the max projection with all ROIs shown then click 'OK' to exit.");

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