*** Comments ***
Copyright (c) 2025 Sine Nomine Associates
See LICENSE


*** Settings ***
Documentation    Tests that focus on being able to use shell commands to create
...    read and delete files in OpenAFS.

Variables    ../test_env_vars.py
Library    Remote    http://${CLIENT1}.${DOMAIN}:${PORT}    AS   client1
Library    Remote    http://${CLIENT2}.${DOMAIN}:${PORT}    AS   client2


*** Variables ***
${VOLUME_NAME}    test.fs
${VOLUME_PATH}    /afs/.example.com/test/fs
${FILE_PATH}    ${VOLUME_PATH}/testfs.txt


*** Test Cases ***
Create a file at a directory path and ensure file exists in directory listing
    [Documentation]    List directory contents using the ls command line utility.

    [Tags]    shell-commands
    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}
    ${rc}    ${output}=    client1.Run And Return Rc And Output    ls ${FILE_PATH}
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    testfs.txt

    [Teardown]    Teardown Test Path

Directory can be changed into
    [Documentation]    Uses change directory command to change directory path
    ...    into the test volume.

    [Tags]    shell-commands
    [Setup]    Setup Test Path

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cd ${VOLUME_PATH}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0

    [Teardown]    Teardown Test Path

Make and remove a new directory with mkdir and rmdir
    [Documentation]    Uses mkdir linux command to create a new directory within
    ...    a volume. Then, uses rmdir linux command to delete the newly added
    ...    directory.

    [Tags]    shell-commands
    [Setup]    Setup Test Path

    VAR    ${DIRECTORY}    test_dir

    ${rc}    ${output}=    client1.Run And Return Rc And Output    mkdir ${VOLUME_PATH}/${DIRECTORY}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    client1.Directory Should Exist    ${VOLUME_PATH}/${DIRECTORY}

    ${rc}    ${output}=    client1.Run And Return Rc And Output    rmdir ${VOLUME_PATH}/${DIRECTORY}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    client1.Directory Should Not Exist    ${VOLUME_PATH}/${DIRECTORY}

    [Teardown]    Teardown Test Path

Copy file with cp and check contents are copied successfully with cat command
    [Documentation]    Uses cp linux command to copy a file from one directory
    ...    path to another and checks if file contents are correct with the cat
    ...    command.

    [Tags]    shell-commands
    [Setup]    Setup Test Path

    VAR    ${FILE_COPY_PATH}    ${VOLUME_PATH}/testfs.copy.txt
    VAR    ${FILE_CONTENT}    "Hello world!\nWelcome to OpenAFS!!"

    client1.Create File    path=${FILE_PATH}    content=${FILE_CONTENT}
    client1.File Should Exist    path=${FILE_PATH}

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cp ${FILE_PATH} ${FILE_COPY_PATH}
    Log Many    ${rc}    ${output}
    Should Be Equal As Integers    ${rc}    0
    client1.File Should Exist    path=${FILE_COPY_PATH}

    ${rc}    ${output}=    client1.Run And Return Rc And Output    cat ${FILE_PATH}
    Log Many    ${rc}    ${output}

    Should Be Equal    ${output}    ${FILE_CONTENT}

    [Teardown]    Teardown Test Path

Create a symbolic link using ln and test its creation using library keyword
    [Documentation]    Creates a file, and then creates a symbolic link using
    ...    ln shell command and verifies that link is correct using library
    ...    keyword.

    [Tags]    link
    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}    content="Hello World!"
    client1.File Should Exist    path=${FILE_PATH}

    ${rc}    ${output}=    client1.Run And Return Rc And Output
    ...    ln --symbolic ${FILE_PATH} ${VOLUME_PATH}/symlink-testfs.txt
    Log Many    ${rc}    ${output}

    client1.Should Be Symlink    ${VOLUME_PATH}/symlink-testfs.txt

    [Teardown]    Teardown Test Path

Create a hard link using ln
    [Documentation]    Creates a file, and then create a hard link using ln.
    ...    Verifies that the inode of the hard link is the same as the inode of
    ...    the original file.

    [Tags]    link

    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}    content="Hello World!"
    client1.File Should Exist    path=${FILE_PATH}

    ${rc}    ${output}=    client1.Run And Return Rc And Output
    ...    ln ${FILE_PATH} ${VOLUME_PATH}/hardlink-testfs.txt

    Log Many    ${rc}    ${output}
    client1.Should Exist    ${VOLUME_PATH}/hardlink-testfs.txt

    ${inode_file}=    client1.Get Inode    ${FILE_PATH}
    ${inode_hardlink}=    client1.Get Inode    ${VOLUME_PATH}/hardlink-testfs.txt

    Should Be Equal As Integers    ${inode_file}    ${inode_hardlink}

    [Teardown]    Teardown Test Path

Create an archive using tar
    [Documentation]    Creates a file, and then adds the file to an archive file
    ...    using tar command. Verifies that the archive file type is correct
    ...    by calling 'file' linux shell command.

    [Tags]    shell-commands
    [Setup]    Setup Test Path

    client1.Create File    path=${FILE_PATH}    content="Hello World!"
    client1.File Should Exist    path=${FILE_PATH}

    ${rc}    ${output}=    client1.Run And Return Rc And Output
    ...    tar -cvf ${VOLUME_PATH}/testfs.tar ${FILE_PATH}
    Log Many    ${rc}    ${output}
    client1.Should Exist    ${VOLUME_PATH}/testfs.tar

    ${rc}    ${output}=    client1.Run And Return Rc And Output
    ...    file ${VOLUME_PATH}/testfs.tar
    Log Many    ${rc}    ${output}
    Should Contain    ${output}    tar archive

    [Teardown]    Teardown Test Path


*** Keywords ***
Setup Test Path
    [Documentation]    Create a volume as an admin user and login as regular
    ...    OpenAFS user for all other test cases.

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
    [Documentation]     Logout as regular OpenAFS user and remove the test
    ...    volume as admin user.

    client1.Logout
    client1.Login    ${AFS_ADMIN}    keytab=${AFS_ADMIN_KEYTAB}
    client1.Remove Volume    ${VOLUME_NAME}
    ...    path=${VOLUME_PATH}
    ...    server=server1.example.com
    ...    part=a
    client1.Volume Should Not Exist    ${VOLUME_NAME}
    client1.Logout
