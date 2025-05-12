*** Settings ***
Library    Remote    http://client1.example.com:8270    AS   client1

*** Test Cases ***
Ping robot server
    client1.Command Should Succeed   true
