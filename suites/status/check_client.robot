*** Settings ***
Variables    Variables.py
Library    DateTime
Library    String
Library    Remote    ${REMOTE_SERVER1_URL}    AS   ${REMOTE_SERVER1}
Library    Remote    ${REMOTE_SERVER2_URL}    AS   ${REMOTE_SERVER2}
Library    Remote    ${REMOTE_SERVER3_URL}    AS   ${REMOTE_SERVER3}
Library    Remote    ${REMOTE_CLIENT1_URL}    AS   ${REMOTE_CLIENT1}
Library    Remote    ${REMOTE_CLIENT2_URL}    AS   ${REMOTE_CLIENT2}


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


Same clock on all servers
    [Documentation]    Same clock on all servers
    ...    
    ...    There is a chance that server clocks in use can go out sync with each other
    ...    This test calls udebug utility and checks for the time differential value.

    ${rc}    ${output}=    client1.Run And Return Rc and Output    udebug -server server1 -port 7002
    Log    ${rc}
    Log    ${output}
    Should Be Equal As Integers    ${rc}    0
    ${time_diff}=    String.Get Regexp Matches    ${output}    differential (\\d+) secs    1
    Log    int(${time_diff}[0])
    Should Be True    int(${time_diff}[0]) <= 2    time difference ${time_diff} is more than 10 seconds

