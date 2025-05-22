*** Settings ***
Documentation    Health check suite has test cases that will ensure that an openafs environment is properly
...    configured before the main openafs test cases are executed.
Variables    Variables.py
Library    DateTime
Library    Remote    http://server1.${DOMAIN_NAME}:${PORT}    AS   server1
Library    Remote    http://server2.${DOMAIN_NAME}:${PORT}    AS   server2
Library    Remote    http://server3.${DOMAIN_NAME}:${PORT}    AS   server3
Library    Remote    http://client1.${DOMAIN_NAME}:${PORT}    AS   client1
Library    Remote    http://client2.${DOMAIN_NAME}:${PORT}    AS   client2
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
    ...    Run bos status (unauthenticated) on both clients and ensure
    ...    openafs servers are running.
    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status server1
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status server2
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc And Output    bos status server3
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status server1
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status server2
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    bos status server3
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.
    ...    Instance vlserver, currently running normally.
    ...    Instance dafs, currently running normally.
    ...    Auxiliary status is: file server running.

Clients Can Run Cache Manager
    [Documentation]    Cache Manager Running
    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs checkservers
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    All servers are running

    ${rc}    ${output}=    client1.Run And Return Rc And Output    mount | grep afs
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS on /afs type afs

    ${rc}    ${output}=    client2.Run And Return Rc And Output    fs checkservers
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    All servers are running

    ${rc}    ${output}=    client2.Run And Return Rc And Output    mount | grep afs
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS on /afs type afs

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

Servers Have No Skew In Their Time
    [Documentation]    Servers have no skew in their time
    ...
    ...    There is a chance that server clocks in use can go out sync with each other
    ...    This test calls udebug utility and checks for the time differential value.

    ${rc}    ${output}=    server1.Run And Return Rc And Output    udebug -server server2 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    ****clock may be bad
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

    ${rc}    ${output}=    server1.Run And Return Rc And Output    udebug -server server3 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    ****clock may be bad
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

    ${rc}    ${output}=    server2.Run And Return Rc And Output    udebug -server server3 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    ****clock may be bad
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

    # Only on client1 check status of database quorum: 1f
    ${rc}    ${output}=    client1.Run And Return Rc And Output    udebug -server server1 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Recovery state 1f
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

Cell volumes exist in vldb
    [Documentation]    Cell volumes exist in vldb

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos listvldb
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    server server3.example.com partition /vicepa RW Site
    ...    server server3.example.com partition /vicepa RO Site
    ...    server server2.example.com partition /vicepa RO Site
    ...    server server1.example.com partition /vicepa RO Site
    ...    root.afs    root.cell    number of sites -> 4

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos listvol -server localhost
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Total volumes onLine 3

    ${rc}    ${output}=    server2.Run And Return Rc And Output    vos listvldb
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    server server3.example.com partition /vicepa RW Site
    ...    server server3.example.com partition /vicepa RO Site
    ...    server server2.example.com partition /vicepa RO Site
    ...    server server1.example.com partition /vicepa RO Site
    ...    root.afs    root.cell    number of sites -> 4

    ${rc}    ${output}=    server3.Run And Return Rc And Output    vos listvldb
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    server server3.example.com partition /vicepa RW Site
    ...    server server3.example.com partition /vicepa RO Site
    ...    server server2.example.com partition /vicepa RO Site
    ...    server server1.example.com partition /vicepa RO Site
    ...    root.afs    root.cell    number of sites -> 4

Partitions have available diskspace
    [Documentation]    Partitions have available diskspace
    ...   For each of the three servers, check whether vicepa, vicepb and vicepc
    ...   partitions have adequate amount of space.

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server1.example.com /vicepa
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepa does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepa
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    1    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server1: Partition vicepa disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server1.example.com /vicepb
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepb does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepb
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server1: Partition vicepb disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server1.example.com /vicepc
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepc does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepc
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server1: Partition vicepc disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server2.example.com /vicepa
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepa does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepa
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server2: Partition vicepa disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server2.example.com /vicepb
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepb does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepb
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server2: Partition vicepb disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server2.example.com /vicepc
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepc does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepc
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server2: Partition vicepc disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server3.example.com /vicepa
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepa does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepa
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server3: Partition vicepa disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server3.example.com /vicepb
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepb does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepb
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server3: Partition vicepb disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc And Output    vos partinfo server3.example.com /vicepc
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    partition /vicepc does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepc
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)    2
    Should Be True    int(${free_space}[0][0]) < int(${free_space}[0][1])
    ...    server3: Partition vicepc disk space is running out!

Cache manager health check
    [Documentation]    Cache manager health check
    ${rc}    ${output}=    client1.Run And Return Rc And Output    cmdebug -s client1 -port 7001 -long
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Lock example.com status: (none_waiting)    for 192.536870912.1.1 [example.com]
    ...    for 192.536870912.4.3 [example.com]    for 192.536870912.2.2 [example.com]
    ...    for 192.536870915.2.2 [example.com]    for 192.536870918.1.1 [example.com]
    ...    for 192.536870915.1.1 [example.com]

    ${rc}    ${output}=    client2.Run And Return Rc And Output    cmdebug -s client2 -port 7001 -long
    Should Be Equal As Integers    ${rc}    0
    Log    ${output}
    Should Contain Any    ${output}    Lock example.com status: (none_waiting)

Rxdebug executes on client systems
    [Documentation]    Rxdebug executes on client systems
    ${rc}    ${output}=    client1.Run And Return Rc And Output    rxdebug -servers localhost -port 7001
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

    ${rc}    ${output}=    client2.Run And Return Rc And Output    rxdebug -servers localhost -port 7001
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Free packets:    Done.

Client systems can get the current cell
    [Documentation]    Client systems can get the current cell
    ...    Use fs wscell to get the current cell

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs wscell
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    This workstation belongs to cell 'example.com'

    ${rc}    ${output}=    client1.Run And Return Rc And Output    fs wscell
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    This workstation belongs to cell 'example.com'

Mount point exists for AFS
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

Network check
    [Documentation]    Network check
    ...
    ...    Runs ping google.com and checks for 0% packet loss for all servers
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

Kernel module loaded
    [Documentation]    Kernel module loaded
    ${rc}    ${output}=    client1.Run And Return Rc And Output    lsmod | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    openafs
    ${rc}    ${output}=    client2.Run And Return Rc And Output    lsmod | grep afs
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    openafs

Client systems can get directory listing
    [Documentation]    Client systems can get directory listing
    ${rc}    ${output}=    client2.Run And Return Rc And Output    ls /afs/example.com/
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0

Server nodes are running kerberos server
    [Documentation]    Server nodes are running kerberos server
    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.server
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Active: active (running)    Loaded: loaded    enabled
    ${rc}    ${output}=    server1.Run And Return Rc And Output    systemctl status krb5kdc.server
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Active: active (running)    Loaded: loaded    enabled
