# NeuTrace2.0
Repository initial commit date: 20 OCT 2022
Readme last updated: 23 OCT 2022 by Joy Franco

NeuTrace2.0 is a macro for manually tracing multiple neuronal processes from an image file in ImageJ. The code walks the user through the process of selecting a Z-stack to open with Bioformats, tracing as many neurons as desired and adding them to the ROI manager, then the code produces a "Straightened View" of each neuron traced that is saved as a new .tif file in the directories that are setup by the code in the same folder as the original image. The set of all traces are also saved as a single ROI zip file so that they can be reloaded later in ImageJ if needed.

Major updates as of 23 OCT 2022:
- Fixed some bugs where files were saving over each other
- Added features: 
  -- Creates a metadata file for each image analyzed
  -- Each neurite trace has its own metadata that includes the length of the neurite traced and its mean grey value in each channel
  -- Generates a plot for quality control to see what the grey value is across each pixel traced

The original version of the ImageJ macro was written as part of my dissertation work under the mentorship of Dr. Miriam Goodman, Stanford University. Originally I was going to include the accompanying Python code for analyzing the straightened neurite views as part of NeuTrace2.0 but later decided that code will be a seperate repo called "Axon Analyzer." The Python code (that will be available in future updates) is based on code written by Dr. Alka Das, as used in Katta...Goodman, 2019 (https://pubmed.ncbi.nlm.nih.gov/31533952/) that was adapted for traces made in cell cultures. The original code is available via the Puncta Analysis repo on Dr. Goodman's GitHub [https://github.com/wormsenseLab/Puncta_analysis](https://github.com/wormsenseLab/Puncta_analysis)

The shared code in its present version is not made for mass distribution, but is available for sharing as an example of how to automate the tracing task in ImageJ in a way that gives the user a great deal of power over what files are produced, where they're stored, and how they're formated. This repository is very much active and will continue to be updated in the future. 
