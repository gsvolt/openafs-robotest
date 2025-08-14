*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Client health checks ensure that client environment is properly
...    configured (pre-requisite for other test cases in the project).

Variables    ../test_env_vars.py
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2
Library    String


*** Test Cases ***
Robot remote server works successfully on all clients
    [Documentation]    Runs 'true' command on each OpenAFS client to verify
    ...    that Robot Framework remote server is accessible and operational.

    client1.Command Should Succeed   true
    client2.Command Should Succeed   true

Test user keytabs are present on all clients
    [Documentation]    Checks for the existence of robot.keytab and admin.keytab
    ...    keytab files in the home directory of all clients.

    ${rc}    ${current_dir}=    client1.Run And Return Rc And Output    pwd
    ${home_dir}=    client1.Get Environment Variable    HOME
    Log Many    ${rc}    ${current_dir}    ${home_dir}

    client1.File Should Exist    ${home_dir}/robot.keytab
    client1.File Should Exist    ${home_dir}/admin.keytab
    client2.File Should Exist    ${home_dir}/robot.keytab
    client2.File Should Exist    ${home_dir}/admin.keytab

Fs command shows cell name on all clients
    [Documentation]    Runs "fs wscell" command to get the name of the cell to
    ...    which the system belongs.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs wscell
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    example.com

    ${rc}    ${output}=    client2.Run And Return Rc And Output    fs wscell
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    example.com

Cache manager is running on all clients
    [Documentation]    This test checks whether openafs-client systemd service
    ...    is running on all clients.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    systemctl is-active openafs-client
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    client2.Run And Return Rc And Output    systemctl is-active openafs-client
    Log Many   ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

Cmdebug shows cell name for all clients
    [Documentation]    Runs cmdebug to verify if cache manager is working.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cmdebug -server ${CLIENT1} -port 7001 -long
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Lock example.com status: (none_waiting)

    ${rc}    ${output}=    client2.Run And Return Rc And Output    cmdebug -server ${CLIENT2} -port 7001 -long
    Should Be Equal As Integers    ${rc}    0
    Log    ${output}
    Should Contain    ${output}    Lock example.com status: (none_waiting)

Cache manager's Rx server is running on all clients
    [Documentation]    Runs rxdebug locally to verify cache manager's rx server
    ...    is operational.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers localhost -port 7001
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Free packets:
    Should Contain    ${output}    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers localhost -port 7001
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Free packets:
    Should Contain    ${output}    Done.

Run bos command for all clients and ensure that OpenAFS services are running on all servers
    [Documentation]    Runs bos status on client systems to get status from servers.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status -server ${SERVER1}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status -server ${SERVER2}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status -server ${SERVER3}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status -server ${SERVER1}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status -server ${SERVER2}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status -server ${SERVER3}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Instance ptserver, currently running normally.
    Should Contain    ${output}    Instance vlserver, currently running normally.
    Should Contain    ${output}    Instance dafs, currently running normally.
    Should Contain    ${output}    Auxiliary status is: file server running.

Run mount command for all clients and ensure that there is an afs mount point
    [Documentation]    Mount point exists for afs
    ...
    ...    Use mount command to verify if AFS mount point exists

    ${rc}    ${output}=    client1.Run And Return Rc And Output    mount | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0

    ${rc}    ${output}=    client2.Run And Return Rc And Output    mount | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0

OpenAFS is mounted as a filesystem on all clients
    [Documentation]    Checks the directory listing of /proc/fs to verify that
    ...    OpenAFS is mounted.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    ls /proc/fs | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0

    Should Contain    ${output}    afs

    ${rc}    ${output}=    client2.Run And Return Rc And Output    ls /proc/fs | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0

    Should Contain    ${output}    afs

OpenAFS is mounted and CellServDB contains test and production cell names on all clients
    [Documentation]    Checks the /proc/fs/openafs/CellServDB file contains
    ...    cell names: example.com and sinenomine.net on all clients.

    ${rc}    ${output}=    client1.Run And Return Rc And Output
    ...    cat /proc/fs/openafs/CellServDB | grep -E "example.com|sinenomine.net"
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    example.com
    Should Contain    ${output}    sinenomine.net

    ${rc}    ${output}=    client2.Run And Return Rc And Output
    ...    cat /proc/fs/openafs/CellServDB | grep -E "example.com|sinenomine.net"
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    example.com
    Should Contain    ${output}    sinenomine.net

OpenAFS kernel module is loaded for all clients
    [Documentation]    Uses lsmod to check if OpenAFS kernel module is loaded on
    ...    all clients.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    lsmod | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    openafs

    ${rc}    ${output}=    client2.Run And Return Rc And Output    lsmod | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    openafs

Top-level cell volume is mounted on all clients
    [Documentation]    Calls ls command to get a directory listing from
    ...    /afs/example.com

    ${rc}    ${output}=    client1.Run And Return Rc And Output    ls /afs/example.com/
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0

    ${rc}    ${output}=    client2.Run And Return Rc And Output    ls /afs/example.com/
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0

OpenAFS and kerberos commands are installed on all clients
    [Documentation]    Ensures binaries that other client tests rely upon are
    ...    available on the system and are operational.

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

    ${version_client1}=    client1.Get Version    localhost    7001
    Log    client1 rxdebug version: ${version_client1}
    Set Suite Metadata   Client1 OpenAFS Version    ${version_client1}

    ${version_client2}=    client2.Get Version    localhost    7001
    Log    client2 rxdebug version: ${version_client2}
    Set Suite Metadata   Client2 OpenAFS Version    ${version_client2}

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

    # OpenAFS pts command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which pts
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    pts
    Should Not Contain    ${output}    no pts in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    pts help
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    pts: Commands are:

    # OpenAFS udebug command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which udebug
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    udebug
    Should Not Contain    ${output}    no udebug in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    udebug -h
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Usage: udebug

    # OpenAFS aklog command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which aklog
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    aklog
    Should Not Contain    ${output}    no aklog in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    aklog -h
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Usage: aklog

    # OpenAFS tokens command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which tokens
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    tokens
    Should Not Contain    ${output}    no tokens in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    tokens -help
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Usage: tokens

    # OpenAFS unlog command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which unlog
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    unlog
    Should Not Contain    ${output}    no unlog in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    unlog -help
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    Usage: unlog

    # OpenAFS translate_et command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which translate_et
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    translate_et
    Should Not Contain    ${output}    no translate_et in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    translate_et
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    1
    Should Contain    ${output}    Usage is: translate_et

    # OpenAFS sys command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which sys
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    sys
    Should Not Contain    ${output}    no sys in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    sys
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    amd64_linux26

    # OpenAFS pagsh command.
    ${rc}    ${output_pagsh}=    client1.Run And Return Rc And Output    which pagsh
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output_pagsh}    pagsh
    Should Not Contain    ${output}    no pagsh in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    test -x ${output_pagsh}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0

    # Kerberos kinit command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which kinit
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    kinit
    Should Not Contain    ${output}    no kinit in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    kinit -V -h
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    2
    Should Contain    ${output}    Usage: kinit

    # Kerberos klist command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which klist
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    klist
    Should Not Contain    ${output}    no klist in

    # Kerberos kdestroy command.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    which kdestroy
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    kdestroy
    Should Not Contain    ${output}    no kdestroy in

    ${rc}    ${output}=    client1.Run And Return Rc And Output    kdestroy -h
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    2
    Should Contain    ${output}    Usage: kdestroy

Robot user account can acquire token with keytab on all clients
    [Documentation]    Robot user account can acquire token on all clients.

    client1.Login    ${AFS_USER}    keytab=${AFS_USER_KEYTAB}
    ${rc}    ${output}=    client1.Run And Return Rc And Output    tokens
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS ID
    client1.Logout

    client2.Login    ${AFS_USER}    keytab=${AFS_USER_KEYTAB}
    ${rc}    ${output}=    client2.Run And Return Rc And Output    tokens
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS ID
    client2.Logout

Admin user account can acquire token with keytab on all clients
    [Documentation]    Admin user account can acquire token on all clients.

    client1.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    ${rc}    ${output}=    client1.Run And Return Rc And Output    tokens
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS ID
    client1.Logout

    client2.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    ${rc}    ${output}=    client2.Run And Return Rc And Output    tokens
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS ID
    client2.Logout
