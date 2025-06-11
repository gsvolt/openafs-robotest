*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Token checks

Variables    ../Variables.py
Library    Remote    http://${SERVER1}.${DOMAIN}:${PORT}    AS   server1
Library    Remote    http://${SERVER2}.${DOMAIN}:${PORT}    AS   server2
Library    Remote    http://${SERVER3}.${DOMAIN}:${PORT}    AS   server3
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2


*** Test Cases ***
Robot User Account Can Acquire Token
    [Documentation]    Robot User Account Can Acquire Token

    client1.Login    ${AFS_USER}    keytab=${AFS_USER_KEYTAB}
    client1.Logout

Admin User Account Can Acquire Token
    [Documentation]    Admin User Account Can Acquire Token

    client1.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    client1.Logout

Create And Remove Volume and File
    [Documentation]    Create And Remove Volume and File

    client1.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    client1.Create Volume    test.fs
    ...    server=server1
    ...    part=a
    ...    path=/afs/.example.com/test/fs
    ...    acl=system:anyuser,read
    client1.Volume Should Exist    test.fs
    client1.Create File    path=/afs/.example.com/test/fs/testfs.txt    content=testfs
    client1.File Should Exist    path=/afs/.example.com/test/fs/testfs.txt
    client1.Remove File    path=/afs/.example.com/test/fs/testfs.txt
    client1.File Should Not Exist    path=/afs/.example.com/test/fs/testfs.txt
    client1.Remove Volume    test.fs    path=/afs/.example.com/test/fs    server=server1    part=a
    client1.Volume Should Not Exist    test.fs
    client1.Logout
