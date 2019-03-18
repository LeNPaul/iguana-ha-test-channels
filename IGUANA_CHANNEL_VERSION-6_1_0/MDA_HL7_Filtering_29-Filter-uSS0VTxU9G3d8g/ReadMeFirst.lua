--[==[
	This is tempalte for creating HL7 channel
	Steps:
	  Step-1 - replace the two vmd with those that you use
	  Step-2 - work on the filter. The name of module should be [prefix_]event_trigger.lua
              DEFAULT IS NOT FILTERED.  You can overwrite it by providing default.lua under filter folder.
	  Step-3 - work on xlate
              DEFAULT IS PASS THROUGHT.  The name of module should be [prefix_]event_trigger.lua
              Make sure that queue.push is in the xlate.  We have to do this to handle split of single message into multiple messages.
	  Step-4 - test, test and more test
--]==]