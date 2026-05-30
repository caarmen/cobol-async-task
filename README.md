# `AsyncTask` implementation for COBOL inspired from the Android framework.

## Why?

Why not?

## Timeline
* [2020](https://developer.android.com/tools/releases/platforms#expandable-7): [`AsyncTask`](https://developer.android.com/reference/android/os/AsyncTask) is deprecated in API level 30.
* [2023](https://gnucobol.sourceforge.io/index.html#Releases):  GnuCOBOL's latest release, 3.2, is released.

So, COBOL is officially more modern and maintained than Android's `AsyncTask`.

## Contents
|File|Description|
|---|---|
|[src/AsyncTask.cob](src/AsyncTask.cob)|`ASYNC-TASK` COBOL procedure, supporting task parameters, and pointers to procedures `DO-IN-BACKGROUND` and `ON-POST-EXECUTE`.|
|[src/ReadFileTask.cob](src/ReadFileTask.cob)|Demo/example of one "implementation" of an AsyncTask, called `READ-FILE-TASK`, that simulates a long-running process, returning a result at the end.
|[src/Activity.cob](src/Activity.cob)|Accepts user input, launches the `READ-FILE-TASK` and displays the result.|

## Running the program.

### Using docker
`./run_docker.sh`

The first time it may take a couple of minutes to build the Docker image.

Subsequent executions should be fast.

### Using your GnuCOBOL development environment
`./run_local.sh`

