Tested and run on a laptop with: Windows 11 Pro, MATLAB R2024b (with graphics display), Intel i9-13980HX, 96GB RAM.



If you run the script, be sure to have use a MATLAB with all toolboxes installed and graphics display activated.
If you don't have the graphical display, the simulation of the models won't work, and the RQs pertaining simulation differences cannot be answered.
All other parts of our scripts should still work in non-graphical systems, still.

While executing, expect a number of compilation or simulation errors be reported. 
This is either because of misconfigured models (that were misconfigured from the start) or because our obfuscation or input/output harnessing broke parts of the model. 
Furthermore, some models' analysis triggers callbacks within in the model, where they output some information onto the cmd line.
This is to be expected and not a sign of failure -- simply ignore all such output.
To get less errors presented, don't use 'dbstop if error' (in CMD linee) or 'pause on errors' (in IDE).

Note: some models' simulation (e.g., 3560 SINGLE_PWM.slx) may expect user input and halts the analysis. Your user input or simply hitting <Enter> a few times will resume the analysis.