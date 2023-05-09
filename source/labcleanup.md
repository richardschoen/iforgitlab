# Cleaning up GITLAB* libraries and IFS directories after class 

```
Make sure none of your production libraries or IFS directories 
start with a prefic of GITLAB before using these instructions.
You don't want to inadvertently remove production libraries and directories.
```

## Delete all GITLIB* users
WRKUSRPF GITLAB*

## Delete all subdirs with SUBTREE(*ALL)
WRKLNK OBJ('/home/GITLAB*') DSPOPT(*ALL)

## Delete all GITLIB* libraries
WRKLIB GITLIB*

