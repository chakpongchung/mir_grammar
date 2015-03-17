# mir_grammar
MIR Grammar
===========

This repository contains the following files.

1. MIR.g4 : The ANTLR v4 Grammar for Medium-level Intermediate Representation. MIR used in this grammar is taken from the text book "Advanced Compiler Design & Implementation" by Steven S Muchnick.
2. MIRExtra.g4 : This file extracts the statements from the input program and writes it into a file.
3. MIRFinal.g4 : This file extracts the statements from the program and constructs the nodes for each statement. These are later added to and ArrayList and is serialized and stored.
4. Node.java : Classes for storing the nodes and its details to form the CFG.
5. Writer.java : Support class for writing statements into file and serializing the objects.
