             PGM

             DCL        VAR(&CURCOUNT) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&CURCOUNTC) TYPE(*CHAR) LEN(3)
             DCL        VAR(&TOTALCOUNT) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&USERID) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USERLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&HOMEDIR) TYPE(*CHAR) LEN(255)
             DCL        VAR(&PROFILE) TYPE(*CHAR) LEN(255)
             DCL        VAR(&BASHRC) TYPE(*CHAR) LEN(255)
             DCL        VAR(&BASHPROF) TYPE(*CHAR) LEN(255)
             DCL        VAR(&PASSWORD) TYPE(*CHAR) LEN(10)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERRORS))

/* SET NUMBER OF USERS TO CREATE */
             CHGVAR     VAR(&TOTALCOUNT) VALUE(2)
             CHGVAR     VAR(&CURCOUNT) VALUE(1)
             CHGVAR     VAR(&PASSWORD) VALUE(DEMO2100)

/* SET USER INFO FOR USER HOME DIR */
TOP:
             CHGVAR     VAR(&CURCOUNTC) VALUE(&CURCOUNT)
             CHGVAR     VAR(&USERID) VALUE('GITLAB' || +
                          &CURCOUNTC)
             CHGVAR     VAR(&USERLIB) VALUE(&USERID)
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

/* CREATE OUTQ FOR USER */
             CRTOUTQ    OUTQ(QUSRSYS/&USERID)
             MONMSG     MSGID(CPF0000)

/* CREATE NEW USER PROFILE */
             CRTUSRPRF  USRPRF(&USERID) PASSWORD(&PASSWORD) +
                          PWDEXP(*NO) STATUS(*ENABLED) +
                          USRCLS(*PGMR) SPCAUT(*USRCLS) +
                          OUTQ(QUSRSYS/&USERID) HOMEDIR(&HOMEDIR)
             MONMSG     MSGID(CPF0000)

             CHGVAR     VAR(&CURCOUNT) VALUE(&CURCOUNT +1)

/* DO NEXT ENTRY */
             IF         COND(&CURCOUNT *LE &TOTALCOUNT) THEN(GOTO +
                          CMDLBL(TOP))

             RETURN

ERRORS:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('Errors +
                          occurred while creating git lab users. +
                          Check joblog') MSGTYPE(*ESCAPE)


