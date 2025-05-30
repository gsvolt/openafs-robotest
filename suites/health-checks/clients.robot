*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Health check suite has test cases that will ensure that an openafs environment is properly
...    configured before the main openafs test cases are executed.
Variables    Variables.py
Library    Remote    http://${SERVER1}.${DOMAIN}:${PORT}    AS   server1
Library    Remote    http://${SERVER2}.${DOMAIN}:${PORT}    AS   server2
Library    Remote    http://${SERVER3}.${DOMAIN}:${PORT}    AS   server3
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2
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

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cmdebug -s ${CLIENT1} -port 7001 -long
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Lock example.com status: (none_waiting)    for 192.536870912.1.1 [example.com]
    ...    for 192.536870912.4.3 [example.com]    for 192.536870912.2.2 [example.com]
    ...    for 192.536870915.2.2 [example.com]    for 192.536870918.1.1 [example.com]
    ...    for 192.536870915.1.1 [example.com]

    ${rc}    ${output}=    client2.Run And Return Rc And Output    cmdebug -s ${CLIENT2} -port 7001 -long
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

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers ${SERVER1} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers ${SERVER2} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers ${SERVER3} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers ${SERVER1} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers ${SERVER2} -port 7003
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers ${SERVER3} -port 7003
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

Keytabs Exist On Client Systems
    [Documentation]    Keytabs Exist On Client Systems
    ...
    ...    This test checks for the existance of robot.keytab and admin.keytab
    ...    on client systems

    client1.File Should Exist    /home/robot/robot.keytab
    client1.File Should Exist    /home/robot/admin.keytab
    client2.File Should Exist    /home/robot/robot.keytab
    client2.File Should Exist    /home/robot/admin.keytab

Binaries Exist And Can Run
    [Documentation]    Binaries Exist And Can Run
    ...
    ...    This test ensures that certain binaries that other client tests rely
    ...    upon are available on the system and can run.

    # OpenAFS fs command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which fs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    fs
    Should Not Contain    ${output}    no fs in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs -help
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    fs: Commands are:

    # OpenAFS cmdebug command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which cmdebug
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    cmdebug
    Should Not Contain    ${output}    no cmdebug in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cmdebug -help
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Usage: cmdebug

    # OpenAFS rxdebug command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which rxdebug
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    rxdebug
    Should Not Contain    ${output}    no rxdebug in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -help
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Usage: rxdebug

    # OpenAFS vos command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which vos
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    vos
    Should Not Contain    ${output}    no vos in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    vos -help
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    vos: Commands are:

    # OpenAFS bos command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which bos
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    bos
    Should Not Contain    ${output}    no bos in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos help
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    bos: Commands are:
