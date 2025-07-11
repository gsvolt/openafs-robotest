*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Health check suite has test cases that will ensure that an OpenAFS environment is properly
...    configured before the main OpenAFS test cases are executed.

Variables    ../test_env_vars.py
Library    Remote    http://${SERVER1}.${DOMAIN}:${PORT}    AS   server1
Library    Remote    http://${SERVER2}.${DOMAIN}:${PORT}    AS   server2
Library    Remote    http://${SERVER3}.${DOMAIN}:${PORT}    AS   server3
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2
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
    ...    OpenAFS servers are running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status ${SERVER1}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status ${SERVER2}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status ${SERVER3}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status ${SERVER1}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status ${SERVER2}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status ${SERVER3}
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

OpenAFS-server Systemd Service Is Running
    [Documentation]    OpenAFS-server Systemd Service Is Running
    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl is-active openafs-server
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    server2.Run And Return Rc And Output    systemctl is-active openafs-server
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    server3.Run And Return Rc And Output    systemctl is-active openafs-server
    Log Many    ${rc}    ${output}
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
    Should Contain    ${output}    On-line
    Should Contain    ${output}    root.afs
    Should Contain    ${output}    number of sites -> 4

Kerberos KDC Is Running
    [Documentation]    Kerberos KDC Is Running
    ...
    ...    Check status of krb5kdc service and make sure it is active and running

    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.service
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Active: active (running)
    Should Contain    ${output}    Loaded: loaded
    Should Contain    ${output}    enabled

    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.service
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Active: active (running)
    Should Contain    ${output}    Loaded: loaded
    Should Contain    ${output}    enabled

Rxdebug version check
    [Documentation]    Rxdebug version check

    ${rc}    ${output}=    server1.Run And Return Rc And Output    rxdebug -server localhost -port 7002 -version
    Log Many    ${rc}    rxdebug version (server1): ${output}
    Should Match Regexp    ${output}    AFS version: OpenAFS

    ${rc}    ${output}=    server2.Run And Return Rc And Output    rxdebug -server localhost -port 7002 -version
    Log Many    ${rc}    rxdebug version (server2): ${output}
    Should Match Regexp    ${output}    AFS version: OpenAFS

    ${rc}    ${output}=    server3.Run And Return Rc And Output    rxdebug -server localhost -port 7002 -version
    Log Many    ${rc}    rxdebug version: ${output}
    Should Match Regexp    ${output}    AFS version: OpenAFS
