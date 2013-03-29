hugit
=====
Script for using of git really easy. You can use much less commands to manage your shared directory than with GIT.

## Commands
* **h, --help** prints help.
* **check-in MESSAGE** saves data to the shared repository. MESSAGE is required parameter - it's a short comment, what did you change.
* **check-in --continue** If there is a conflict, you have to resolve it and use this command to continue.

* **get-lastest-version** gets the lastest version from the shared repository.
* **get-lastest-version --continue** If there is a conflict, you have to resolve it and use this command to continue.

* **init-shared** initializes shared repository + creates initial commit.
* **clone SHARED_DIR DEST_DIR** clones shared repository in SHARED_DIR to DEST_DIR.
 
## Examples
### Creating shared directory
Just type inside folder, that you want to share:

```
./hugit.sh init-shared
```

And it's done. Inside this folder will be current version of whole project.

### Creating local version
Only one command will clone the repository to your local directory`:

```
./hugit.sh clone alesh@server.example.com/mnt/data/folder/shared_repository ./my_local_dir
```

### Getting changes of your workmates
During the work you want to see changes, that made others. Type:

```
./hugit.sh get-lastest-version
```

In most cases it's done. Remember, now you have other's changes, but your changes are not saved in shared directory.
Sometimes you can edit the same line of code as your workmate - and you have to decide, which version is corret.

If this happend, you will receive error message like this:
```
# You have to resolve conflict in these files:
file1
file2
file3

# Then you can use 'get-lastest-version --continue'

# If you beleive, that this is an error and file is resolved, use command 'resolved FILE'.
```

Now you have to resolve all the conflicts. Open each file (file1, file2, file3) and edit the code. For example, you have to replace this:

```
<<<<<<< HEAD
printf("This is code, that you've written.");
=======
printf("This is code, that is now in the shared repository.");
>>>>>>> 8480daae5e9dab797277a869fa20f89288e40ca9
```

By this:
```
printf("This is code, that you want.");
```

After resolving all conflicts you will use this command:
```
./hugit.sh get-lastest-version --continue
```

### Sending your changes to shared directory
When you're satisfied with your work and you want to share it, type:
```
./hugit.sh check-in "Fixed some bugs."
```

If there is a conflict, resolve it (that is described above) and type:
```
./hugit.sh check-in --continue
```

