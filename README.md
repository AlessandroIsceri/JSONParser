# JSONParser

JSONParser is a university project (exam: programming languages) and its aim is to translate a JSON file into a proper structure depending on the chosen language (Common Lisp or Prolog) and vice versa.

For more technical information about the code, refer to the specific readme files in the respective folders.

## Getting started Prolog

To use the Prolog parser, simply download the file 'jsonparse.pl' from the Prolog folder. 
Open [SWI-Prolog](https://www.swi-prolog.org/) on your computer, click on `File` in the top navigation bar, choose `Consult` and then select the downloaded file.

After that, you can enter the predicate `jsonread('filename', OUTPUT)` in the console to read a JSON file and obtain the corresponding Prolog structure.

## Getting started Lisp

To use the Lisp parser, all you need to do is download the file 'jsonparse.lisp' from the Lisp folder.
Open [LispWorks](http://www.lispworks.com/) on your computer, click on `File` in the top navigation bar, choose `Load` and then select the downloaded file.

After that, you can enter `jsonread('filename')` in the console to read a JSON file and get the corresponding Lisp structure.
