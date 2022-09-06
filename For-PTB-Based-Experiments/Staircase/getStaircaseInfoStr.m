function str_ = getStaircaseInfoStr(s)
str1 = sprintf('This is a %i-up-%i-down staircase;\n',s.UpDown(:));
str2 = sprintf('It will start at an initial Value of %f, \nwithin the boundaries of [%f, %f]',s.initVal,s.LowerHigherBoundaries);
str3 = [sprintf('It will start with a step size of %f \nand switch to the following step sizes if response reversals are encountered:',s.StepSizes(1)),...
    num2str(s.StepSizes(2:end)')];
str4 = sprintf('\n');
str_ = [str1,str2,str3,str4];
end