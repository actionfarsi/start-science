#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function/S DoLoadMultipleFiles()
	Variable refNum
	String message = "Select one or more files"
	String outputPaths
	String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"
	fileFilters += "All Files:.*;"
 
	Open /D /R /MULT=1 /F=fileFilters /M=message refNum
	outputPaths = S_fileName
 
	if (strlen(outputPaths) == 0)
		Print "Cancelled"
	else
		Variable numFilesSelected = ItemsInList(outputPaths, "\r")
		Variable i
		for(i=0; i<numFilesSelected; i+=1)
			String path = StringFromList(i, outputPaths, "\r")
			Printf "%d: %s\r", i, path
			// Add commands here to load the actual waves.  An example command
			// is included below but you will need to modify it depending on how
			// the data you are loading is organized.
			//LoadWave/A/D/J/W/K=0/V={" "," $",0,0}/L={0,2,0,0,0} path
		endfor
	endif
 
	return outputPaths		// Will be empty if user canceled
End



Function LoadTextFromFolder(level)
	String level
	
	if (strlen(level) == 0)
		NewPath/O importFolder
	endif
	
	PathInfo importFolder
	String baseSFolder = S_path
	String currSFolder = baseSFolder  +  level
	NewPath/O currFolder, currSFolder

	
	String list = IndexedFile(currFolder, -1, ".txt")
	Variable numItems = ItemsInList(list)
	print " ----- " + list
	Variable i
	if (numItems != 0)
		for(i=0; i<numItems; i+=1)
			String fName = StringFromList(i, list) 
			LoadWave/P=currFolder /N=$fName /G fName
		endfor
	endif
	
	//Recursion
	String flist = IndexedDir(currFolder, -1, 0)
	numItems = ItemsInList(flist)
	
	if ((numItems != 0) & (strlen(flist) < 30))
		DFREF curDataFolder = GetDataFolderDFR()
		for(i=0; i<numItems; i+=1)
			fName = StringFromList(i, flist)
			NewDataFolder/O /S $fName
			String newLevel = level  + fName + "/"
			print "Entering folder: " + newLevel
			LoadTextFromFolder(newLevel)
			print "Exit folder"
			SetDataFolder curDataFolder 
	 	endfor
	endif
	
End