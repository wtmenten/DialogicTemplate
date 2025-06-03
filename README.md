### Dialogic 2 Visual Novel Project Template

A refactored and improved version of the Dialogic 1.4 example project for used with Dialogic 2 and Godot 4.x

Note: the Dialogic addon contains a few modifications to the `Save` and `Settings` subsystems to provided settings persistence and retrieval via the global_info ConfigFile.

### Required Addons
`Dialogic`: Core game running addon
`SceneManager`: Currently, only used for its singleton manager concept and could easily be removed if desired.

### Setup
Timelines are created in the Dialogic Tab 

Associate a `TimelineMeta` (custom) resource to each timeline to allow certain timelines to appear in the CG gallery. 

Gallery items are ran as root timelines from the main menu. in-game they should jump back to the prior caller on finish unless otherwise controlled.

`GameController`.`make_extra_info()` is the utility method called on every save event which collects the game state external to Dialogic for saving.