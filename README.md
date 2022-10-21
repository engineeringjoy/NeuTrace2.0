# NeuTrace2.0
Repository initial commit date: 20 OCT 2022
Readme last updated: 21 OCT 2022 by Joy Franco

NeuTrace2.0 is a set of macros/scripts for manually tracing multiple neuronal processes from an image file in ImageJ. The code walks the user through the process of selecting a Z-stack to open with Bioformats, tracing as many neurons as desired and adding them to the ROI manager, then the code produces a "Straightened View" of each neuron traced that is saved as a new .tif file in the directories that are setup by the code in the same folder as the original image. The set of all traces are also saved as a single ROI zip file so that they can be reloaded later in ImageJ if needed.

Scheduled updates to this repostory will include:
- Additions to NeuTrace2.0 that save the "Plot Profile" results for each trace in a .csv file, in case the user prefers to work with the data in that format. 
- Python files for analyzing the straightened views

The original version of the ImageJ macro was written as part of my dissertation work under the mentorship of Dr. Miriam Goodman, Stanford University. The Python code (that will be available in future updates) is based on code written by Dr. Alka Das, as used in Katta...Goodman, 2019 (https://pubmed.ncbi.nlm.nih.gov/31533952/) that was adapted for traces made in cell cultures. The original code is available via the Puncta Analysis repo on Dr. Goodman's GitHub [https://github.com/wormsenseLab/Puncta_analysis](https://github.com/wormsenseLab/Puncta_analysis)

The shared code in its present version is not made for mass distribution, but is available for sharing as an example of how to automate the tracing task in ImageJ in a way that gives the user a great deal of power over what files are produced, where they're stored, and how they're formated. This repository is very much active and will continue to be updated in the future. 
