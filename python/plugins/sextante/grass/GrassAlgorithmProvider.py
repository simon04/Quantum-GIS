# -*- coding: utf-8 -*-

"""
***************************************************************************
    GrassAlgorithmProvider.py
    ---------------------
    Date                 : August 2012
    Copyright            : (C) 2012 by Victor Olaya
    Email                : volayaf at gmail dot com
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""
from sextante.grass.nviz import nviz

__author__ = 'Victor Olaya'
__date__ = 'August 2012'
__copyright__ = '(C) 2012, Victor Olaya'
# This will get replaced with a git SHA1 when you do a git archive
__revision__ = '$Format:%H$'

import os
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from sextante.core.SextanteConfig import SextanteConfig, Setting
from sextante.core.AlgorithmProvider import AlgorithmProvider
from sextante.core.SextanteLog import SextanteLog
from sextante.grass.GrassUtils import GrassUtils
from sextante.grass.GrassAlgorithm import GrassAlgorithm
from sextante.core.SextanteUtils import SextanteUtils

class GrassAlgorithmProvider(AlgorithmProvider):

    def __init__(self):
        AlgorithmProvider.__init__(self)
        self.createAlgsList() #preloading algorithms to speed up

    def initializeSettings(self):
        AlgorithmProvider.initializeSettings(self)
        if SextanteUtils.isWindows() or SextanteUtils.isMac():
            SextanteConfig.addSetting(Setting(self.getDescription(), GrassUtils.GRASS_FOLDER, "GRASS folder", GrassUtils.grassPath()))
            SextanteConfig.addSetting(Setting(self.getDescription(), GrassUtils.GRASS_WIN_SHELL, "Msys folder", GrassUtils.grassWinShell()))
        SextanteConfig.addSetting(Setting(self.getDescription(), GrassUtils.GRASS_LOG_COMMANDS, "Log execution commands", False))
        SextanteConfig.addSetting(Setting(self.getDescription(), GrassUtils.GRASS_LOG_CONSOLE, "Log console output", False))
        SextanteConfig.addSetting(Setting(self.getDescription(), GrassUtils.GRASS_LATLON, "Coordinates are lat/lon", False))
        SextanteConfig.addSetting(Setting(self.getDescription(), GrassUtils.GRASS_HELP_FOLDER, "GRASS help folder", GrassUtils.grassHelpPath()))

    def unload(self):
        AlgorithmProvider.unload(self)
        if SextanteUtils.isWindows() or SextanteUtils.isMac():
            SextanteConfig.removeSetting(GrassUtils.GRASS_FOLDER)
            SextanteConfig.removeSetting(GrassUtils.GRASS_WIN_SHELL)
        SextanteConfig.removeSetting(GrassUtils.GRASS_LATLON)
        SextanteConfig.removeSetting(GrassUtils.GRASS_HELP_FOLDER)
        SextanteConfig.removeSetting(GrassUtils.GRASS_LOG_COMMANDS)
        SextanteConfig.removeSetting(GrassUtils.GRASS_LOG_CONSOLE)

    def createAlgsList(self):
        self.preloadedAlgs = []
        folder = GrassUtils.grassDescriptionPath()
        for descriptionFile in os.listdir(folder):
            if descriptionFile.endswith("txt"):
                try:
                    alg = GrassAlgorithm(os.path.join(folder, descriptionFile))
                    if alg.name.strip() != "":
                        self.preloadedAlgs.append(alg)
                    else:
                        SextanteLog.addToLog(SextanteLog.LOG_ERROR, "Could not open GRASS algorithm: " + descriptionFile)
                except Exception,e:
                    SextanteLog.addToLog(SextanteLog.LOG_ERROR, "Could not open GRASS algorithm: " + descriptionFile)
        self.preloadedAlgs.append(nviz())

    def _loadAlgorithms(self):
        self.algs = self.preloadedAlgs

    def getDescription(self):
        return "GRASS commands"

    def getName(self):
        return "grass"

    def getIcon(self):
        return  QIcon(os.path.dirname(__file__) + "/../images/grass.png")

    def getSupportedOutputVectorLayerExtensions(self):
        return ["shp"]
    
    def getSupportedOutputRasterLayerExtensions(self):        
        return ["tif"]
        
    def createDescriptionFiles(self):
        folder = "C:\\descs\\grass"
        i = 0
        for alg in self.preloadedAlgs:
            f = open (os.path.join(folder, alg.name +".txt"), "w")
            f.write(alg.name + "\n")
            f.write(alg.name + "\n")
            f.write(alg.group + "\n")
            for param in alg.parameters:
                f.write(param.serialize() + "\n")
            for out in alg.outputs:
                f.write(out.serialize() + "\n")
            f.close()
            i+=1


