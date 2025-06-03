*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Token checks

Variables    ../Variables.py
Library    Remote    http://${SERVER1}.${DOMAIN}:${PORT}    AS   server1
Library    Remote    http://${SERVER2}.${DOMAIN}:${PORT}    AS   server2
Library    Remote    http://${SERVER3}.${DOMAIN}:${PORT}    AS   server3
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2

*** Test Cases ***
Tokens Can Be Acquired
    [Documentation]    Check to see if tokens can be acquired using OpenAFSLibrary

    client1.Login    ${AFS_USER}    keytab=/home/robot/robot.keytab
    client1.Logout