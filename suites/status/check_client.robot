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
Ping All Servers
    [Documentation]    Ping all servers
    server1.Command Should Succeed   true
    server2.Command Should Succeed   true
    server3.Command Should Succeed   true
    client1.Command Should Succeed   true
    client2.Command Should Succeed   true

Clients Can Run Bos Status
    [Documentation]    Clients Can Run Bos Status
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

Clients Can Run Cache Manager
    [Documentation]    Clients Can Run Cache Manager
    ...
    ...    Run fs checkservers to check whether all servers are running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs checkservers
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    All servers are running

    ${rc}    ${output}=    client2.Run And Return Rc And Output    fs checkservers
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    All servers are running

Afs Client Running
    [Documentation]    Afs Client Running
    ${rc}    ${output}=    client1.Run And Return Rc And Output    systemctl is-active openafs-client
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    client2.Run And Return Rc And Output    systemctl is-active openafs-client
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

Afs Server Running
    [Documentation]    Afs Server Running
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

Cell Volumes Exist In Vldb
    [Documentation]    Cell volumes exist in vldb
    ...
    ...    Calls vos listvldb and vos listvol -server localhost to ensure that
    ...    cell volumes exist in vldb.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    vos examine root.afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    On-line    root.afs    number of sites -> 4

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

Servers Are Running Kerberos Server
    [Documentation]    Servers Are Running Kerberos Server
    ...
    ...    Check status of krb5kdc service and make sure it is active and running

    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.service
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Active: active (running)    Loaded: loaded    enabled
    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.service
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Active: active (running)    Loaded: loaded    enabled

Clients Can Get Current Cell
    [Documentation]    Clients Can Get Current Cell
    ...
    ...    Uses fs command to check whether client can get current cell

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs wscell
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    This workstation belongs to cell 'example.com'

    ${rc}    ${output}=    client2.Run And Return Rc And Output    fs wscell
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    This workstation belongs to cell 'example.com'

Clients And Servers Can Access Internet
    [Documentation]    Clients And Servers Can Access Internet
    ...
    ...    Runs ping google.com and checks for 0% packet loss for all servers
    ...    (Note: Last test in this suite)

    ${rc}    ${output}=    client1.Run And Return Rc And Output    ping -c4 google.com
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    0% packet loss

    ${rc}    ${output}=    client2.Run And Return Rc And Output    ping -c4 google.com
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    0% packet loss

    ${rc}    ${output}=    server1.Run And Return Rc And Output    ping -c4 google.com
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    0% packet loss

    ${rc}    ${output}=    server2.Run And Return Rc And Output    ping -c4 google.com
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    0% packet loss

    ${rc}    ${output}=    server3.Run And Return Rc And Output    ping -c4 google.com
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    0% packet loss
