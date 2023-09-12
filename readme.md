SZ pack
# Introduction
A pack of few convenient scripts created during processing psychological experimental data.
SZ is my name initials.
# Folder Structure
## /FileImport/
**content = szCSVRead(filename)**: an enhanced version of the csvread function, it reads csv file and give output as cells of string (just as what you can get using [~,~,raw] = xlsread(filename).
** CellOut = fcCellLine2Cell(CellLine) **: This function parses {{line1};{line2}} as {line1;line2} (each of line1, line2, ... is a 1*n cell).  
**fcReadFileByLine**: reads file line-by-line and return the data in cell of string lines.  
**fcExportCellstr2CSV**: prints cellstring into specified file using fprintf(fid,'%s').  
## /DataArrange/
**OutputData = szPickData(cellData,varList,varNames,subList,subNames)**: pick data for specified variable and specified subjects, given the sequence of variables and subject names.
## /InteractivePlotToolBox/
Toolbox to make your figure interactive.
Documentation in progress...**This could be very very very useful**
## /str_prc/
**str_dereplicate.m** detect and remove replicating substrings from a given string.  
This seems to be a function I copied from somewhere 
## /XLS_inte/  
Documentation in progress...
## /PlottingAddins/ (developing)
**scatter3Alpha.m**: seems not to be written by me... not tested yet. It should be a function to add control of alpha value (amount of intransparency) to function scatter3Alpha
