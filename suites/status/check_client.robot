*** Settings ***
Variables    Variables.py
Library    Remote    ${REMOTE_SERVER1_URL}    AS   ${REMOTE_SERVER1}
Library    Remote    ${REMOTE_SERVER2_URL}    AS   ${REMOTE_SERVER2}
Library    Remote    ${REMOTE_SERVER3_URL}    AS   ${REMOTE_SERVER3}
Library    Remote    ${REMOTE_CLIENT1_URL}    AS   ${REMOTE_CLIENT1}
Library    Remote    ${REMOTE_CLIENT2_URL}    AS   ${REMOTE_CLIENT2}

*** Test Cases ***
Ping all servers
    server1.Command Should Succeed   true
    server2.Command Should Succeed   true
    server3.Command Should Succeed   true
    client1.Command Should Succeed   true
    client2.Command Should Succeed   true


Client1 - Test Bos Command
    ${rc}    ${output}=    client1.Run And Return Rc and Output    bos status server1
    Log    ${rc}
    Log    ${output}
    #Should Be Equal As Integers    ${rc}    0
