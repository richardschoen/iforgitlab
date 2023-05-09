             PGM        PARM(&USERID)

             DCL        VAR(&CURCOUNT) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&CURCOUNTC) TYPE(*CHAR) LEN(3)
             DCL        VAR(&TOTALCOUNT) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&USERID) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USERIDLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&HOMEDIR) TYPE(*CHAR) LEN(255)
             DCL        VAR(&PROFILE) TYPE(*CHAR) LEN(255)
             DCL        VAR(&BASHRC) TYPE(*CHAR) LEN(255)
             DCL        VAR(&BASHPROF) TYPE(*CHAR) LEN(255)
             DCL        VAR(&PASSWORD) TYPE(*CHAR) LEN(10)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERRORS))


/* SET USER INFO FOR USER HOME DIR */
             CHGVAR     VAR(&USERIDLIB) VALUE(&USERID)
             CHGVAR     VAR(&HOMEDIR) VALUE('/home/' |< &USERID)
             CHGVAR     VAR(&PROFILE) VALUE(&HOMEDIR |< '/.profile')
             CHGVAR     VAR(&BASHRC) VALUE(&HOMEDIR |< '/.bashrc')
             CHGVAR     VAR(&BASHPROF) VALUE(&HOMEDIR |< +
                          '/.bash_profile')

/* CREATE HOME DIR FOR NEW USER */
             MKDIR      DIR(&HOMEDIR) DTAAUT(*RWX) OBJAUT(*ALL)
             MONMSG     MSGID(CPF0000)

/* COPY QSHELL PROFILE AND SET AUTH */
             CPYTOSTMF  +
                          FROMMBR('/QSYS.LIB/GITLAB.LIB/SOURCE.FILE/Q+
                          SHPROFILE.MBR') TOSTMF(&PROFILE) +
                          STMFOPT(*REPLACE) CVTDTA(*AUTO) +
                          ENDLINFMT(*LF) AUT(*INDIR) STMFCODPAG(819)
             CHGAUT     OBJ(&PROFILE) USER(*PUBLIC) DTAAUT(*RWX) +
                          OBJAUT(*ALL)

/* COPY BASHRC PROFILE AND SET AUTH */
             CPYTOSTMF  +
                          FROMMBR('/QSYS.LIB/GITLAB.LIB/SOURCE.FILE/Q+
                          SHPROFILE.MBR') TOSTMF(&BASHRC) +
                          STMFOPT(*REPLACE) CVTDTA(*AUTO) +
                          ENDLINFMT(*LF) AUT(*INDIR) STMFCODPAG(819)
             CHGAUT     OBJ(&BASHRC) USER(*PUBLIC) DTAAUT(*RWX) +
                          OBJAUT(*ALL)

/* COPY BASH_PROFILE PROFILE AND SET AUTH */
             CPYTOSTMF  +
                          FROMMBR('/QSYS.LIB/GITLAB.LIB/SOURCE.FILE/Q+
                          SHPROFILE.MBR') TOSTMF(&BASHPROF) +
                          STMFOPT(*REPLACE) CVTDTA(*AUTO) +
                          ENDLINFMT(*LF) AUT(*INDIR) STMFCODPAG(819)
             CHGAUT     OBJ(&BASHPROF) USER(*PUBLIC) DTAAUT(*RWX) +
                          OBJAUT(*ALL)

/* COPY SOURCE FILES */
             CRTSRCPF   FILE(&USERID/QRPGLESRC) RCDLEN(120) AUT(*ALL)
             CPYSRCF    FROMFILE(GITLAB/QRPGLESRC) +
                          TOFILE(&USERID/QRPGLESRC) FROMMBR(*ALL) +
                          TOMBR(*FROMMBR) TOMBRID(*GEN) +
                          MBROPT(*REPLACE) SRCCHGDATE(*FROMMBR) +
                          TEXT(*SAME) SRCTYPE(*SAME) SRCOPT(*SAME)
             CRTSRCPF   FILE(&USERID/QCLSRC) RCDLEN(120) AUT(*ALL)
             CPYSRCF    FROMFILE(GITLAB/QCLSRC) TOFILE(&USERID/QCLSRC) +
                          FROMMBR(*ALL) TOMBR(*FROMMBR) +
                          TOMBRID(*GEN) MBROPT(*REPLACE) +
                          SRCCHGDATE(*FROMMBR) TEXT(*SAME) +
                          SRCTYPE(*SAME) SRCOPT(*SAME)

/* GRANT LIBRARY ACCESS */
             GRTOBJAUT  OBJ(QSYS/&USERID) OBJTYPE(*LIB) +
                          USER(*PUBLIC) AUT(*ALL)
             GRTOBJAUT  OBJ(&USERID/*ALL) OBJTYPE(*ALL) +
                          USER(*PUBLIC) AUT(*ALL)

             RETURN

ERRORS:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('Errors +
                          occurred while creating git lab users. +
                          Check joblog') MSGTYPE(*ESCAPE)


