*** Settings ***
Variables    Variables.py
Library    DateTime
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
    ${rc_client1}    ${output_client1}=    client1.Run And Return Rc and Output    date +${DATE_FORMAT}
    ${time_client1}=    Convert Date    ${output_client1}    result_format=datetime

    ${rc_client2}    ${output_client2}=    client2.Run And Return Rc and Output    date +${DATE_FORMAT}
    ${time_client2}=    Convert Date    ${output_client2}    result_format=datetime    date_format=%a %b %d %H:%M:%S %Z %Y

    ${rc_server1}    ${output_server1}=    client2.Run And Return Rc and Output    date +${DATE_FORMAT}
    ${time_server1}=    Convert Date    ${output_server1}    result_format=datetime    date_format=%a %b %d %H:%M:%S %Z %Y

    ${rc_server2}    ${output_server2}=    client2.Run And Return Rc and Output    date +${DATE_FORMAT}
    ${time_server2}=    Convert Date    ${output_server2}    result_format=datetime    date_format=%a %b %d %H:%M:%S %Z %Y

    ${rc_server3}    ${output_server3}=    client2.Run And Return Rc and Output    date +${DATE_FORMAT}
    ${time_server3}=    Convert Date    ${output_server3}    result_format=datetime    date_format=%a %b %d %H:%M:%S %Z %Y

    ${time_diff1}    Subtract Date From Date    ${time_client1}    ${time_client2}
    ${time_diff2}    Subtract Date From Date    ${time_client1}    ${time_server1}
    ${time_diff3}    Subtract Date From Date    ${time_client1}    ${time_server2}
    ${time_diff4}    Subtract Date From Date    ${time_client1}    ${time_server3}

    Should Be True    abs(${time_diff1}) <= 2.0    time difference ${time_diff1} is more than 2 seconds.
    Should Be True    abs(${time_diff2}) <= 2.0    time difference ${time_diff2} is more than 2 seconds.
    Should Be True    abs(${time_diff3}) <= 2.0    time difference ${time_diff3} is more than 2 seconds.
    Should Be True    abs(${time_diff4}) <= 2.0    time difference ${time_diff4} is more than 2 seconds.
