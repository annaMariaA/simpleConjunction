#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy3 Experiment Builder (v2020.2.4),
    on December 16, 2020, at 15:27
If you publish work using this script the most relevant publication is:

    Peirce J, Gray JR, Simpson S, MacAskill M, Höchenberger R, Sogo H, Kastman E, Lindeløv JK. (2019) 
        PsychoPy2: Experiments in behavior made easy Behav Res 51: 195. 
        https://doi.org/10.3758/s13428-018-01193-y

"""

from __future__ import absolute_import, division

from psychopy import locale_setup
from psychopy import prefs
from psychopy import sound, gui, visual, core, data, event, logging, clock
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)

import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys  # to get file system encoding

from psychopy.hardware import keyboard



# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
psychopyVersion = '2020.2.4'
expName = 'conSearch3'  # from the Builder filename that created this script
expInfo = {'participant': '', 'session': '001'}
dlg = gui.DlgFromDict(dictionary=expInfo, sort_keys=False, title=expName)
if dlg.OK == False:
    core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
expInfo['psychopyVersion'] = psychopyVersion

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + u'data/%s_%s_%s' % (expInfo['participant'], expName, expInfo['date'])

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath='C:\\Users\\s03an7\\Desktop\\simpleConjunction\\conSearch3.py',
    savePickle=True, saveWideText=True,
    dataFileName=filename)
# save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp
frameTolerance = 0.001  # how close to onset before 'same' frame

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(
    size=[1600, 900], fullscr=True, screen=1, 
    winType='pyglet', allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True, 
    units='height')
# store frame rate of monitor if we can measure it
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0  # could not measure, so guess

# create a default keyboard (e.g. to check for escape)
defaultKeyboard = keyboard.Keyboard()

# Initialize components for Routine "trial1"
trial1Clock = core.Clock()
target = visual.ImageStim(
    win=win,
    name='target', units='cm', 
    image='images/redHor.jpg', mask=None,
    ori=1, pos=[4,-8], size=[3,1],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)
dist1 = visual.ImageStim(
    win=win,
    name='dist1', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(0, -8), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-2.0)
dist2 = visual.ImageStim(
    win=win,
    name='dist2', units='cm', 
    image='images/greenHor.jpg', mask=None,
    ori=0, pos=(-4, -4), size=(3, 1),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-3.0)
dist3 = visual.ImageStim(
    win=win,
    name='dist3', units='cm', 
    image='images/greenVer.jpg', mask=None,
    ori=0, pos=(-8, 4), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-4.0)
dist4 = visual.ImageStim(
    win=win,
    name='dist4', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(4, -4), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-5.0)
dist5 = visual.ImageStim(
    win=win,
    name='dist5', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(-8,-4), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-6.0)
dist6 = visual.ImageStim(
    win=win,
    name='dist6', units='cm', 
    image='images/greenHor.jpg', mask=None,
    ori=0, pos=(-8, 8), size=(3, 1),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-7.0)
dist7 = visual.ImageStim(
    win=win,
    name='dist7', units='cm', 
    image='images/greenHor.jpg', mask=None,
    ori=0, pos=(8, 8), size=(3, 1),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-8.0)
dist8 = visual.ImageStim(
    win=win,
    name='dist8', units='cm', 
    image='images/greenVer.jpg', mask=None,
    ori=0, pos=(-4, 8), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-9.0)
dist9 = visual.ImageStim(
    win=win,
    name='dist9', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(4,4), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-10.0)
dist10 = visual.ImageStim(
    win=win,
    name='dist10', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(0,-4), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-11.0)
dist11 = visual.ImageStim(
    win=win,
    name='dist11', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(-8, 0), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-12.0)
dist12 = visual.ImageStim(
    win=win,
    name='dist12', units='cm', 
    image='images/redVer.jpg', mask=None,
    ori=0, pos=(8, 4), size=(1, 3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-13.0)
dist13 = visual.ImageStim(
    win=win,
    name='dist13', units='cm', 
    image='images/greenVer.jpg', mask=None,
    ori=0, pos=(8, -4), size=(1,3),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-14.0)
dist14 = visual.ImageStim(
    win=win,
    name='dist14', units='cm', 
    image='images/greenHor.jpg', mask=None,
    ori=0, pos=(0, 0), size=(3, 1),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-15.0)
dist15 = visual.ImageStim(
    win=win,
    name='dist15', units='cm', 
    image='images/greenHor.jpg', mask=None,
    ori=0, pos=(8, -8), size=(3, 1),
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-16.0)

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

# ------Prepare to start Routine "trial1"-------
continueRoutine = True
routineTimer.add(1.000000)
# update component parameters for each repeat
# keep track of which components have finished
trial1Components = [target, dist1, dist2, dist3, dist4, dist5, dist6, dist7, dist8, dist9, dist10, dist11, dist12, dist13, dist14, dist15]
for thisComponent in trial1Components:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
trial1Clock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "trial1"-------
while continueRoutine and routineTimer.getTime() > 0:
    # get current time
    t = trial1Clock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=trial1Clock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *target* updates
    if target.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        target.frameNStart = frameN  # exact frame index
        target.tStart = t  # local t and not account for scr refresh
        target.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(target, 'tStartRefresh')  # time at next scr refresh
        target.setAutoDraw(True)
    if target.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > target.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            target.tStop = t  # not accounting for scr refresh
            target.frameNStop = frameN  # exact frame index
            win.timeOnFlip(target, 'tStopRefresh')  # time at next scr refresh
            target.setAutoDraw(False)
    
    # *dist1* updates
    if dist1.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist1.frameNStart = frameN  # exact frame index
        dist1.tStart = t  # local t and not account for scr refresh
        dist1.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist1, 'tStartRefresh')  # time at next scr refresh
        dist1.setAutoDraw(True)
    if dist1.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist1.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist1.tStop = t  # not accounting for scr refresh
            dist1.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist1, 'tStopRefresh')  # time at next scr refresh
            dist1.setAutoDraw(False)
    
    # *dist2* updates
    if dist2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist2.frameNStart = frameN  # exact frame index
        dist2.tStart = t  # local t and not account for scr refresh
        dist2.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist2, 'tStartRefresh')  # time at next scr refresh
        dist2.setAutoDraw(True)
    if dist2.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist2.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist2.tStop = t  # not accounting for scr refresh
            dist2.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist2, 'tStopRefresh')  # time at next scr refresh
            dist2.setAutoDraw(False)
    
    # *dist3* updates
    if dist3.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist3.frameNStart = frameN  # exact frame index
        dist3.tStart = t  # local t and not account for scr refresh
        dist3.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist3, 'tStartRefresh')  # time at next scr refresh
        dist3.setAutoDraw(True)
    if dist3.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist3.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist3.tStop = t  # not accounting for scr refresh
            dist3.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist3, 'tStopRefresh')  # time at next scr refresh
            dist3.setAutoDraw(False)
    
    # *dist4* updates
    if dist4.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist4.frameNStart = frameN  # exact frame index
        dist4.tStart = t  # local t and not account for scr refresh
        dist4.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist4, 'tStartRefresh')  # time at next scr refresh
        dist4.setAutoDraw(True)
    if dist4.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist4.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist4.tStop = t  # not accounting for scr refresh
            dist4.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist4, 'tStopRefresh')  # time at next scr refresh
            dist4.setAutoDraw(False)
    
    # *dist5* updates
    if dist5.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist5.frameNStart = frameN  # exact frame index
        dist5.tStart = t  # local t and not account for scr refresh
        dist5.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist5, 'tStartRefresh')  # time at next scr refresh
        dist5.setAutoDraw(True)
    if dist5.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist5.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist5.tStop = t  # not accounting for scr refresh
            dist5.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist5, 'tStopRefresh')  # time at next scr refresh
            dist5.setAutoDraw(False)
    
    # *dist6* updates
    if dist6.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist6.frameNStart = frameN  # exact frame index
        dist6.tStart = t  # local t and not account for scr refresh
        dist6.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist6, 'tStartRefresh')  # time at next scr refresh
        dist6.setAutoDraw(True)
    if dist6.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist6.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist6.tStop = t  # not accounting for scr refresh
            dist6.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist6, 'tStopRefresh')  # time at next scr refresh
            dist6.setAutoDraw(False)
    
    # *dist7* updates
    if dist7.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist7.frameNStart = frameN  # exact frame index
        dist7.tStart = t  # local t and not account for scr refresh
        dist7.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist7, 'tStartRefresh')  # time at next scr refresh
        dist7.setAutoDraw(True)
    if dist7.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist7.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist7.tStop = t  # not accounting for scr refresh
            dist7.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist7, 'tStopRefresh')  # time at next scr refresh
            dist7.setAutoDraw(False)
    
    # *dist8* updates
    if dist8.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist8.frameNStart = frameN  # exact frame index
        dist8.tStart = t  # local t and not account for scr refresh
        dist8.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist8, 'tStartRefresh')  # time at next scr refresh
        dist8.setAutoDraw(True)
    if dist8.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist8.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist8.tStop = t  # not accounting for scr refresh
            dist8.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist8, 'tStopRefresh')  # time at next scr refresh
            dist8.setAutoDraw(False)
    
    # *dist9* updates
    if dist9.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist9.frameNStart = frameN  # exact frame index
        dist9.tStart = t  # local t and not account for scr refresh
        dist9.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist9, 'tStartRefresh')  # time at next scr refresh
        dist9.setAutoDraw(True)
    if dist9.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist9.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist9.tStop = t  # not accounting for scr refresh
            dist9.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist9, 'tStopRefresh')  # time at next scr refresh
            dist9.setAutoDraw(False)
    
    # *dist10* updates
    if dist10.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist10.frameNStart = frameN  # exact frame index
        dist10.tStart = t  # local t and not account for scr refresh
        dist10.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist10, 'tStartRefresh')  # time at next scr refresh
        dist10.setAutoDraw(True)
    if dist10.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist10.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist10.tStop = t  # not accounting for scr refresh
            dist10.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist10, 'tStopRefresh')  # time at next scr refresh
            dist10.setAutoDraw(False)
    
    # *dist11* updates
    if dist11.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist11.frameNStart = frameN  # exact frame index
        dist11.tStart = t  # local t and not account for scr refresh
        dist11.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist11, 'tStartRefresh')  # time at next scr refresh
        dist11.setAutoDraw(True)
    if dist11.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist11.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist11.tStop = t  # not accounting for scr refresh
            dist11.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist11, 'tStopRefresh')  # time at next scr refresh
            dist11.setAutoDraw(False)
    
    # *dist12* updates
    if dist12.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist12.frameNStart = frameN  # exact frame index
        dist12.tStart = t  # local t and not account for scr refresh
        dist12.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist12, 'tStartRefresh')  # time at next scr refresh
        dist12.setAutoDraw(True)
    if dist12.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist12.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist12.tStop = t  # not accounting for scr refresh
            dist12.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist12, 'tStopRefresh')  # time at next scr refresh
            dist12.setAutoDraw(False)
    
    # *dist13* updates
    if dist13.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist13.frameNStart = frameN  # exact frame index
        dist13.tStart = t  # local t and not account for scr refresh
        dist13.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist13, 'tStartRefresh')  # time at next scr refresh
        dist13.setAutoDraw(True)
    if dist13.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist13.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist13.tStop = t  # not accounting for scr refresh
            dist13.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist13, 'tStopRefresh')  # time at next scr refresh
            dist13.setAutoDraw(False)
    
    # *dist14* updates
    if dist14.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist14.frameNStart = frameN  # exact frame index
        dist14.tStart = t  # local t and not account for scr refresh
        dist14.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist14, 'tStartRefresh')  # time at next scr refresh
        dist14.setAutoDraw(True)
    if dist14.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist14.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist14.tStop = t  # not accounting for scr refresh
            dist14.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist14, 'tStopRefresh')  # time at next scr refresh
            dist14.setAutoDraw(False)
    
    # *dist15* updates
    if dist15.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        dist15.frameNStart = frameN  # exact frame index
        dist15.tStart = t  # local t and not account for scr refresh
        dist15.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(dist15, 'tStartRefresh')  # time at next scr refresh
        dist15.setAutoDraw(True)
    if dist15.status == STARTED:
        # is it time to stop? (based on global clock, using actual start)
        if tThisFlipGlobal > dist15.tStartRefresh + 1.0-frameTolerance:
            # keep track of stop time/frame for later
            dist15.tStop = t  # not accounting for scr refresh
            dist15.frameNStop = frameN  # exact frame index
            win.timeOnFlip(dist15, 'tStopRefresh')  # time at next scr refresh
            dist15.setAutoDraw(False)
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in trial1Components:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "trial1"-------
for thisComponent in trial1Components:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
thisExp.addData('target.started', target.tStartRefresh)
thisExp.addData('target.stopped', target.tStopRefresh)
win.getMovieFrame()
win.saveMovieFrames("unsw_logo_blend_example.png")

thisExp.addData('dist1.started', dist1.tStartRefresh)
thisExp.addData('dist1.stopped', dist1.tStopRefresh)
thisExp.addData('dist2.started', dist2.tStartRefresh)
thisExp.addData('dist2.stopped', dist2.tStopRefresh)
thisExp.addData('dist3.started', dist3.tStartRefresh)
thisExp.addData('dist3.stopped', dist3.tStopRefresh)
thisExp.addData('dist4.started', dist4.tStartRefresh)
thisExp.addData('dist4.stopped', dist4.tStopRefresh)
thisExp.addData('dist5.started', dist5.tStartRefresh)
thisExp.addData('dist5.stopped', dist5.tStopRefresh)
thisExp.addData('dist6.started', dist6.tStartRefresh)
thisExp.addData('dist6.stopped', dist6.tStopRefresh)
thisExp.addData('dist7.started', dist7.tStartRefresh)
thisExp.addData('dist7.stopped', dist7.tStopRefresh)
thisExp.addData('dist8.started', dist8.tStartRefresh)
thisExp.addData('dist8.stopped', dist8.tStopRefresh)
thisExp.addData('dist9.started', dist9.tStartRefresh)
thisExp.addData('dist9.stopped', dist9.tStopRefresh)
thisExp.addData('dist10.started', dist10.tStartRefresh)
thisExp.addData('dist10.stopped', dist10.tStopRefresh)
thisExp.addData('dist11.started', dist11.tStartRefresh)
thisExp.addData('dist11.stopped', dist11.tStopRefresh)
thisExp.addData('dist12.started', dist12.tStartRefresh)
thisExp.addData('dist12.stopped', dist12.tStopRefresh)
thisExp.addData('dist13.started', dist13.tStartRefresh)
thisExp.addData('dist13.stopped', dist13.tStopRefresh)
thisExp.addData('dist14.started', dist14.tStartRefresh)
thisExp.addData('dist14.stopped', dist14.tStopRefresh)
thisExp.addData('dist15.started', dist15.tStartRefresh)
thisExp.addData('dist15.stopped', dist15.tStopRefresh)

# Flip one final time so any remaining win.callOnFlip() 
# and win.timeOnFlip() tasks get executed before quitting
win.flip()

# these shouldn't be strictly necessary (should auto-save)
thisExp.saveAsWideText(filename+'.csv', delim='auto')
thisExp.saveAsPickle(filename)
logging.flush()
# make sure everything is closed down
thisExp.abort()  # or data files will save again on exit
win.close()
core.quit()
