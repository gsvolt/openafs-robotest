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
    client1.Command Should Succeed   true
    client2.Command Should Succeed   true

OpenAFS Cache Manager Is Running
    [Documentation]    OpenAFS Cache Manager Is Running
    ...
    ...    Run fs wscell to check whether cache manager is running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs wscell
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    example.com

    ${rc}    ${output}=    client2.Run And Return Rc And Output    fs wscell
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    example.com

Openafs-client Systemd Service Is Running
    [Documentation]    Openafs-client Systemd Service Is Running
    ${rc}    ${output}=    client1.Run And Return Rc And Output    systemctl is-active openafs-client
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    client2.Run And Return Rc And Output    systemctl is-active openafs-client
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

Cache Manager Health Check
    [Documentation]    Cache Manager Health Check
    ...
    ...    Runs cmdebug to determine if cache manager is working

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cmdebug -s ${REMOTE_CLIENT1} -port 7001 -long
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Lock example.com status: (none_waiting)    for 192.536870912.1.1 [example.com]
    ...    for 192.536870912.4.3 [example.com]    for 192.536870912.2.2 [example.com]
    ...    for 192.536870915.2.2 [example.com]    for 192.536870918.1.1 [example.com]
    ...    for 192.536870915.1.1 [example.com]

    ${rc}    ${output}=    client2.Run And Return Rc And Output    cmdebug -s ${REMOTE_CLIENT2} -port 7001 -long
    Should Be Equal As Integers    ${rc}    0
    Log    ${output}
    Should Contain Any    ${output}    Lock example.com status: (none_waiting)

Clients Can Execute Rxdebug Locally
    [Documentation]    Clients Can Execute Rxdebug Locally
    ...
    ...    Runs rxdebug with server name localhost to check if the command succeeds.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers localhost -port 7001
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers localhost -port 7001
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

Clients Can Reach Servers With Rxdebug
    [Documentation]    Clients Can Reach Servers With Rxdebug
    ...
    ...    Runs rxdebug with server names to check if the command succeeds.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers ${REMOTE_SERVER1} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers ${REMOTE_SERVER2} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers ${REMOTE_SERVER3} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers ${REMOTE_SERVER1} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers ${REMOTE_SERVER2} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers ${REMOTE_SERVER3} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

Mount Point Exists For AFS
    [Documentation]    Mount point exists for AFS
    ...
    ...    Use mount command to verify if AFS mount point exists

    ${rc}    ${output}=    client1.Run And Return Rc And Output    mount
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS on /afs type afs (rw,relatime)

    ${rc}    ${output}=    client2.Run And Return Rc And Output    mount
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS on /afs type afs (rw,relatime)

Kernel Module Loaded
    [Documentation]    Kernel Module Loaded
    ...
    ...    Use lsmod to check if openafs kernel module is loaded.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    lsmod | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    openafs

    ${rc}    ${output}=    client2.Run And Return Rc And Output    lsmod | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    openafs

Clients Can Get Afs Directory Listing
    [Documentation]    Clients Can Get Afs Directory Listing
    ...
    ...    Calls ls command to get a directory listing from /afs/example.com

    ${rc}    ${output}=    client2.Run And Return Rc And Output    ls /afs/example.com/
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
