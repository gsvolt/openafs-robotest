*** Comments ***
# Copyright (c) 2014-2025 Sine Nomine Associates
# See LICENSE


*** Settings ***
Documentation    Health check suite has test cases that will ensure that an openafs environment is properly
...    configured before the main openafs test cases are executed.
Variables    Variables.py
Library    DateTime
Library    Remote    http://${REMOTE_SERVER1}.${DOMAIN_NAME}:${PORT}    AS   server1
Library    Remote    http://${REMOTE_SERVER2}.${DOMAIN_NAME}:${PORT}    AS   server2
Library    Remote    http://${REMOTE_SERVER3}.${DOMAIN_NAME}:${PORT}    AS   server3
Library    Remote    http://${REMOTE_CLIENT1}.${DOMAIN_NAME}:${PORT}    AS   client1
Library    Remote    http://${REMOTE_CLIENT2}.${DOMAIN_NAME}:${PORT}    AS   client2
Library    String


*** Test Cases ***
Robot Servers Are Running
    [Documentation]    Robot Servers Are Running
    server1.Command Should Succeed   true
    server2.Command Should Succeed   true
    server3.Command Should Succeed   true

File Servers Are Running
    [Documentation]    File Servers Are Running
    ...
    ...    Run bos status (unauthenticated) on both clients and ensure
    ...    openafs servers are running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status ${REMOTE_SERVER1}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status ${REMOTE_SERVER2}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status ${REMOTE_SERVER3}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status ${REMOTE_SERVER1}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status ${REMOTE_SERVER2}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status ${REMOTE_SERVER3}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

Openafs-server Systemd Service Is Running
    [Documentation]    Openafs-server Systemd Service Is Running
    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl is-active openafs-server
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    server2.Run And Return Rc And Output    systemctl is-active openafs-server
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    server3.Run And Return Rc And Output    systemctl is-active openafs-server
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

Cell Volumes Exist And Are Online
    [Documentation]    Cell Volumes Exist And Are Online
    ...
    ...    Calls vos listvldb and vos listvol -server localhost to ensure that
    ...    cell volumes exist in vldb.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    vos examine root.afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    On-line    root.afs    number of sites -> 4

Kerberos KDC Is Running
    [Documentation]    Kerberos KDC Is Running
    ...
    ...    Check status of krb5kdc service and make sure it is active and running

    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.service
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Active: active (running)    Loaded: loaded    enabled
    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.service
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Active: active (running)    Loaded: loaded    enabled
