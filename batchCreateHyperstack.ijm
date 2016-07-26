/*
 * Macro to process multiple sequences of images in a directory into hyperstacks grouped by matching filename 
 * NB Single channel only - use batchCreateHyperstackChannels for multiple channgels
 * Usage Steps:
 * 1. Select input files directory
 * 2. Select output directory
 * 3. Check the basename delimiter - change or accept
 *   (ie it will truncate at this - case-sensitive, eg "_z")
 * 4. Hyperstack files will be written to output directory
 * 5. Troubleshooting: Check Log output window in ImageJ
 * (Contact: Liz Cooper-Williams, QBI e.cooperwilliams@uq.edu.au)
 */
requires("1.51d");

input = getDirectory("Input directory");
output = getDirectory("Output directory");

Dialog.create("Base filename ends at");
suffix = "_z";
Dialog.addString("File suffix: ", suffix, 5);
Dialog.show();
suffix = Dialog.getString();
start=0;


processFolder(suffix, input);
exit("Finished");

function processFolder(suffix, input) {
    print("Starting folder processing: " + input);
	list = getFileList(input);
	print("Total entries in directory:" + list.length);
	stacklist = newArray(list.length); //initial stack
	j = 0; //added counter
	l = 0; //cumulative list size ie already processed
	filename = "";
	for (i = 0; i < list.length; i++) {
		if (!File.isDirectory(input + list[i])){
			if ((lengthOf(filename) > 0) && startsWith(list[i], filename)){
				j++;
				stacklist[j]= input + list[i];
				
			} else {
				if (j > 0) {
					stacklist = Array.slice(stacklist, 0, j+1);
					processStack(input,stacklist, output, filename);
					l += stacklist.length;
					stacklist = newArray(list.length - l);
				}
				filename = getRootFilename(suffix, list[i]);
				j = 0;				
				stacklist[j]= input + list[i];
			}
			//showProgress(i, list.length);
		}else{
			print("File is directory");
		}
	}
	//last one
	if (stacklist.length > 0){
		stacklist = Array.slice(stacklist, 0, j+1);
		//print("Last stack: " + stacklist.length);
		processStack(input,stacklist, output, filename);
	}
}


//If problems with base filename - uncomment print statements to debug
function getRootFilename(suffix, fname){
	print("Filename:" + fname);
	idx = lastIndexOf(fname, suffix);
	if (idx < 0){
		exit("Error: Problem with filenames")
	}
	//print("Suffix:" + idx);
	rootfname = substring(fname, 0, idx);
	print("Base Filename:" + rootfname);
	return rootfname;
}

function processStack(inputdir,input, output, file) {
	outputfile = output + "Stack_" + file + ".tif";
	print("Processing: " + input.length + " files");
	run("Bio-Formats", "open=[" + input[0] + "] color_mode=Default group_files view=Hyperstack stack_order=XYCZT use_virtual_stack axis_1_number_of_images=3 axis_1_axis_first_image=1 axis_1_axis_increment=1 axis_2_number_of_images=3 axis_2_axis_first_image=1 axis_2_axis_increment=1 axis_3_number_of_images=" + input.length + " axis_3_axis_first_image=1 axis_3_axis_increment=1 use_virtual_stack contains=[" + file + "] name=[]");
	saveAs("tiff", outputfile);
	close();
	print("Saved to: " + outputfile);
}
