# deploy-mikrotik
script for autodeploy statrtup config. To launch copy command and paste to Mikrotik Terminal and press enter
{tool/fetch url=https://raw.githubusercontent.com/MedvedevV-iltus/deploy-mikrotik/refs/heads/main/preparation.rsc output=file dst-path=flash; 
:import flash/preparation.rsc ;
/system/script/run preparation }
