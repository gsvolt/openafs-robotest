*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Tests that focus on creating, reading and writing files.

Variables    ../test_env_vars.py
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2


*** Variables ***
${VOLUME_NAME}    test.fs
${VOLUME_PATH}    /afs/.example.com/test/fs
${FILE_PATH}    /afs/.example.com/test/fs/testfs.txt


*** Test Cases ***
Create and remove an empty file
    [Documentation]    Client1 creates an empty file and all clients check
    ...    for its existence. Client1 removes the file and both clients check
    ...    that it has been deleted successfully.

    [Tags]    distributed
    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}
    client1.Wait Until Created    path=${FILE_PATH}

    client1.File Should Exist    path=${FILE_PATH}
    client2.File Should Exist    path=${FILE_PATH}

    client1.Remove File    path=${FILE_PATH}

    client1.Should Not Exist    path=${FILE_PATH}
    client2.Should Not Exist    path=${FILE_PATH}

    [Teardown]    Teardown Test Path

After a file is created all clients can read it
    [Documentation]    Client1 creates a file and writes 'Hello World!' in it.
    ...    Client2 is able to read the file's contents successfully.

    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}
    client1.Wait Until Created    path=${FILE_PATH}
    client1.Append To File    path=${FILE_PATH}    content=Hello World!

    client1.File Should Exist    path=${FILE_PATH}
    client2.File Should Exist    path=${FILE_PATH}

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cat ${FILE_PATH}
    Log Many    ${rc}    ${output}
    Should Match Regexp    ${output}    Hello World!

    ${rc}    ${output}=    client2.Run And Return Rc And Output    cat ${FILE_PATH}
    Log Many    ${rc}    ${output}
    Should Match Regexp    ${output}    Hello World!

    [Teardown]    Teardown Test Path

After a file is created an unauthorized user cannot edit it
    [Documentation]    Client1 creates a file and writes 'Hello World!' in it.
    ...    Client2 is unable to read its contents successfully because it is
    ...    not logged in.

    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}
    client1.Wait Until Created    path=${FILE_PATH}
    client1.Append To File    path=${FILE_PATH}    content=Hello World!

    client1.File Should Exist    path=${FILE_PATH}
    client2.File Should Exist    path=${FILE_PATH}

    ${msg}=    Run Keyword And Expect Error    PermissionError*
    ...    client2.Append To File    path=${FILE_PATH}    content=OpenAFS
    Log    ${msg}

    [Teardown]    Teardown Test Path

After a file is created an authorized user can edit it
    [Documentation]    Client1 creates a file and writes 'Hello World!' in it.
    ...    Client2 is able to add content to the file successfully because it
    ...    is logged in.

    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}
    client1.Wait Until Created    path=${FILE_PATH}
    client1.Append To File    path=${FILE_PATH}    content=Hello World!

    client1.File Should Exist    path=${FILE_PATH}
    client2.File Should Exist    path=${FILE_PATH}

    client2.Login    ${AFS_USER}    keytab=${AFS_USER_KEYTAB}
    client2.Append To File    path=${FILE_PATH}    content=OpenAFS
    client2.Logout

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cat ${FILE_PATH}
    Log Many    ${rc}    ${output}

    Should Match Regexp    ${output}    Hello World!
    Should Match Regexp    ${output}    OpenAFS

    [Teardown]    Teardown Test Path


*** Keywords ***
Setup Test Path
    [Documentation]    Creates a volume as admin user and logs in as regular
    ...    OpenAFS user.

    client1.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    client1.Volume Should Not Exist    ${VOLUME_NAME}
    client1.Create Volume    ${VOLUME_NAME}
    ...    server=server1.example.com
    ...    part=a
    ...    path=${VOLUME_PATH}
    ...    acl=system:anyuser,read,system:authuser,write
    client1.Volume Should Exist    ${VOLUME_NAME}
    client1.Logout
    client1.Login    ${AFS_USER}    keytab=${AFS_USER_KEYTAB}

Teardown Test Path
    [Documentation]     Logs out as regular OpenAFS user and removes test
    ...    volume as an admin user.

    client1.Logout
    client1.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    client1.Remove Volume    ${VOLUME_NAME}
    ...    path=${VOLUME_PATH}
    ...    server=server1.example.com
    ...    part=a
    client1.Volume Should Not Exist    ${VOLUME_NAME}
    client1.Logout
