nl.path <- "P:/MScUSM2016/netlogo-5.1.0"
NLStart(nl.path, gui = F)
model.path <- "P:/MScUSM2016/netlogo-5.1.0/models/Sample Models/Earth Science/Fire.nlogo"
NLLoadModel(model.path)
NLCommand("setup")
NLDoCommand(10, "go")
burned <- NLReport("burned-trees")
print(burned)
NLQuit()
