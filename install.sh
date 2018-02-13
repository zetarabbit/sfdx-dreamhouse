#!/bin/bash

sfdx force:org:create -s -a debugging2 -f config/project-scratch-def.json -v ACdx
sfdx force:source:push
sfdx force:user:permset:assign -n dreamhouse
sfdx force:user:permset:assign -n debugging 
sfdx force:data:tree:import -p data/sample-data-plan.json
 