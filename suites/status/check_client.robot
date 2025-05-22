*** Settings ***
Variables    Variables.py
Library    DateTime
Library    String
Library    Remote    http://server1.${DOMAIN_NAME}:${PORT}    AS   server1
Library    Remote    http://server2.${DOMAIN_NAME}:${PORT}    AS   server2
Library    Remote    http://server3.${DOMAIN_NAME}:${PORT}    AS   server3
Library    Remote    http://client1.${DOMAIN_NAME}:${PORT}    AS   client1
Library    Remote    http://client2.${DOMAIN_NAME}:${PORT}    AS   client2


*** Test Cases ***
Ping all servers
    [Documentation]    Ping all servers
    server1.Command Should Succeed   true
    server2.Command Should Succeed   true
    server3.Command Should Succeed   true
    client1.Command Should Succeed   true
    client2.Command Should Succeed   true

Bos Status
    [Documentation]    Run bos status (unauthenticated) on both clients and ensure
    ...    openafs servers are running.
    ${rc}    ${output}=    client1.Run And Return Rc and Output    bos status server1
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.    Instance vlserver, currently running normally.    Instance dafs, currently running normally.    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc and Output    bos status server2
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.    Instance vlserver, currently running normally.    Instance dafs, currently running normally.    Auxiliary status is: file server running.

    ${rc}    ${output}=    client1.Run And Return Rc and Output    bos status server3
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.    Instance vlserver, currently running normally.    Instance dafs, currently running normally.    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc and Output    bos status server1
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.    Instance vlserver, currently running normally.    Instance dafs, currently running normally.    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc and Output    bos status server2
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.    Instance vlserver, currently running normally.    Instance dafs, currently running normally.    Auxiliary status is: file server running.

    ${rc}    ${output}=    client2.Run And Return Rc and Output    bos status server3
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain Any    ${output}    Instance ptserver, currently running normally.    Instance vlserver, currently running normally.    Instance dafs, currently running normally.    Auxiliary status is: file server running.


Cache Manager Running
    [Documentation]    Cache Manager Running
    ${rc}    ${output}=    client1.Run And Return Rc and Output    fs checkservers
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    All servers are running

    ${rc}    ${output}=    client1.Run And Return Rc and Output    mount | grep afs
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS on /afs type afs

    ${rc}    ${output}=    client2.Run And Return Rc and Output    fs checkservers
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    All servers are running

    ${rc}    ${output}=    client2.Run And Return Rc and Output    mount | grep afs
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    AFS on /afs type afs

Afs Client Running
    [Documentation]    
    ${rc}    ${output}=    client1.Run And Return Rc and Output    systemctl is-active openafs-client
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    client2.Run And Return Rc and Output    systemctl is-active openafs-client
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

Afs Server Running
    [Documentation]    Afs Server Running
    ${rc}    ${output}=    server1.Run And Return Rc and Output    systemctl is-active openafs-server
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    server2.Run And Return Rc and Output    systemctl is-active openafs-server
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

    ${rc}    ${output}=    server3.Run And Return Rc and Output    systemctl is-active openafs-server
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    active

Servers have no skew in their time
    [Documentation]    Servers have no skew in their time
    ...    
    ...    There is a chance that server clocks in use can go out sync with each other
    ...    This test calls udebug utility and checks for the time differential value.

    ${rc}    ${output}=    server1.Run And Return Rc and Output    udebug -server server2 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    ****clock may be bad
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

    ${rc}    ${output}=    server1.Run And Return Rc and Output    udebug -server server3 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    ****clock may be bad
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

    ${rc}    ${output}=    server2.Run And Return Rc and Output    udebug -server server3 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${output}    ****clock may be bad
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

    # Only on client1 check status of database quorum: 1f
    ${rc}    ${output}=    client1.Run And Return Rc and Output    udebug -server server1 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    Recovery state 1f
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 10    time difference ${time_diff} is more than 10 seconds

Cell volumes exist in vldb
    [Documentation]    Cell volumes exist in vldb

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos listvldb
    Log    ${rc}
    Log    ${output}
    Should Contain Any    ${output}    server server3.example.com partition /vicepa RW Site    server server3.example.com partition /vicepa RO Site    server server2.example.com partition /vicepa RO Site    server server1.example.com partition /vicepa RO Site    root.afs    root.cell    number of sites -> 4

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos listvol -server localhost
    Log    ${rc}
    Log    ${output}
    Should Contain    ${output}    Total volumes onLine 3

    ${rc}    ${output}=    server2.Run And Return Rc and Output    vos listvldb
    Log    ${rc}
    Log    ${output}
    Should Contain Any    ${output}    server server3.example.com partition /vicepa RW Site    server server3.example.com partition /vicepa RO Site    server server2.example.com partition /vicepa RO Site    server server1.example.com partition /vicepa RO Site    root.afs    root.cell    number of sites -> 4

    ${rc}    ${output}=    server3.Run And Return Rc and Output    vos listvldb
    Log    ${rc}
    Log    ${output}
    Should Contain Any    ${output}    server server3.example.com partition /vicepa RW Site    server server3.example.com partition /vicepa RO Site    server server2.example.com partition /vicepa RO Site    server server1.example.com partition /vicepa RO Site    root.afs    root.cell    number of sites -> 4

Partitions have available diskspace
    [Documentation]    Partitions have available diskspace
    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server1.example.com /vicepa
    Should Not Contain    ${output}    partition /vicepa does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepa
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server1: Partition vicepa disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server1.example.com /vicepb
    Should Not Contain    ${output}    partition /vicepb does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepb
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server1: Partition vicepb disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server1.example.com /vicepc
    Should Not Contain    ${output}    partition /vicepc does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepc
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server1: Partition vicepc disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server2.example.com /vicepa
    Should Not Contain    ${output}    partition /vicepa does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepa
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server2: Partition vicepa disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server2.example.com /vicepb
    Should Not Contain    ${output}    partition /vicepb does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepb
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server2: Partition vicepb disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server2.example.com /vicepc
    Should Not Contain    ${output}    partition /vicepc does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepc
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server2: Partition vicepc disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server3.example.com /vicepa
    Should Not Contain    ${output}    partition /vicepa does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepa
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server3: Partition vicepa disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server3.example.com /vicepb
    Should Not Contain    ${output}    partition /vicepb does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepb
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server3: Partition vicepb disk space is running out!

    ${rc}    ${output}=    server1.Run And Return Rc and Output    vos partinfo server3.example.com /vicepc
    Should Not Contain    ${output}    partition /vicepc does not exist on the server
    Should Contain    ${output}    Free space on partition /vicepc
    ${free_space}=    String.Get Regexp Matches    ${output}    (\\d+) K blocks out of total (\\d+)
    Should Be True    int(${free_space}[0]) < int(${free_space}[1])    server3: Partition vicepc disk space is running out!
