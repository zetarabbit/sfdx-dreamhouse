#!/bin/bash

# Run this script after you have created a scratch org with the debugger-scratch-def.json

sfdx force:source:push
sfdx force:user:permset:assign -n DreamHouse
sfdx force:user:permset:assign -n DebugApex
sfdx force:data:tree:import -p data/sample-data-plan.json 