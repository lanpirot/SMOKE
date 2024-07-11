# SMOKE: Simulink Model Obfuscation Keeping structurE

The SMOKE Tool removes, renames, and/or hides various aspects of a Simulink model in order to hide confidential information. This can be useful for eliminating proprietary details when sending models to third-parties, or even by removing details from models in order to create simpler images suitable for publication. The SMOKE Tool can obfuscate (change layout, remove/hide names, remove colors, resize, rearrange diagrams etc.) and remove data and functionality (remove annotations, docblocks, functions from function blocks, stateflow innards, customized callbacks, all customized block parameters) while keeping the structure of the model intact. This way it can be shared while still being useful for structural analysis and/or screenshots that may be published.

Remove all sensitive IP from models with SMOKE!

<img src="imgs/Cover.png" width="850">

*__Disclaimer__: The authors of this tool make no guarantees that all proprietary/confidential information is indeed removed from the Simulink model file. Users should inspect the model to verify that no proprietary/confidential remains.*

## User Guide

For installation and other information, please see the [User Guide](doc/SMOKE_UserGuide.pdf).
