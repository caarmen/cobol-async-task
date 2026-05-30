      *>===========================================================
      *> ASYNC-TASK.
      *>
      *> Simulate behavior of Android's AsyncTask.
      *> We don't have a class (no object-oriented programming
      *> in GnuCOBOL 3.2).
      *>
      *> @RequiresOptIn
      *> @deprecated use COB-COROUTINE or COB-WORK-MANAGER
      *>===========================================================

       IDENTIFICATION DIVISION.
       PROGRAM-ID. ASYNC-TASK.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT F-RESULT-FILE ASSIGN TO WS-INTERPROCESS-FILENAME
           ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
      *> We choose to use a file as inter-process communication.
      *> When the child process finishes the background work, it
      *> writes the result to a file.
       FILE SECTION.
       FD F-RESULT-FILE.
       01 F-RESULT PIC X(50).

      *> Define in working-storage the data items that need to
      *> persist across invocations.
       WORKING-STORAGE SECTION.
      *> Constant for the filename that holds the task result.
       01 WS-INTERPROCESS-FILENAME CONSTANT "asynctask.dat".
      *> The status of the task, which can be:
      *> - PENDING
      *> - RUNNING
      *> - FINISHED
       01 WS-STATUS PIC X(8) VALUE "PENDING".
      *> The result of the background work.
       01 WS-RESULT PIC X(50) VALUE SPACES.
      *> Pointer to the procedure to execute upon completion of
      *> background work.
       01 WS-PTR-ON-POST-EXECUTE PROCEDURE-POINTER.
      *> The process id of the background work process.
       01 WS-FORK-PID PIC S9(9) BINARY.

      *> Define in local-storage the data items that are only
      *> needed local to a subpgram, and not needed to be persisted
      *> across invocations.
       LOCAL-STORAGE SECTION.
      *> File info about our inter-process file.
       01 LS-FILEINFO.
           05 LS-SIZE-BYTES PIC 9(18) COMP.
           *> Not interested in the rest of the data items
           *> of the file info.
           05 FILLER PIC X(8).

      *> Define in the linkage section those data items
      *> that are passed to different invocations of our
      *> AsyncTask. Note that "return values" are passed
      *> as OUT-xyz arguments.
       LINKAGE SECTION.
      *> 1. For calling the main AsyncTask entry point:
      *> User input passed to the background task.
       01 IN-PARAM PIC X(50).
      *> Pointer to the procedure which performs the background
      *> work.
       01 IN-PTR-DO-IN-BACKGROUND PROCEDURE-POINTER.
      *> Pointer to the procedure to call after the background
      *> work has completed.
       01 IN-PTR-ON-POST-EXECUTE PROCEDURE-POINTER.

      *> 2. For calling the "GET-STATUS" entry point.
      *> The current status of the task, one of:
      *> - RUNNING
      *> - FINISHED
       01 OUT-STATUS PIC X(8).

      *> 3. For calling the "GET" entry point.
      *> The result of the background task.
       01 OUT-RESULT PIC X(50).

      *> 1. Main entry point.
       PROCEDURE DIVISION USING
           IN-PARAM
           IN-PTR-DO-IN-BACKGROUND
           IN-PTR-ON-POST-EXECUTE.

          *> Update the task status.
           SET WS-STATUS TO "RUNNING"
          *> Save the reference to the on post execute procedure.
           SET WS-PTR-ON-POST-EXECUTE TO IN-PTR-ON-POST-EXECUTE
          *> Clean any file from previous runs.
           CALL "CBL_DELETE_FILE" USING WS-INTERPROCESS-FILENAME
          *> Fork our process.
           CALL "CBL_GC_FORK" RETURNING WS-FORK-PID END-CALL
           IF WS-FORK-PID IS ZERO
           THEN
               *> If the pid is 0, this means we're the child process.
               CALL IN-PTR-DO-IN-BACKGROUND USING
                   IN-PARAM
                   WS-RESULT
               OPEN OUTPUT F-RESULT-FILE
               WRITE F-RESULT FROM WS-RESULT
               CLOSE F-RESULT-FILE
               STOP RUN
           END-IF
          *> Otherwise we're the parent process.
           GOBACK.

          *> Entry point to get the result of the task.
           ENTRY "GET" USING OUT-RESULT.
              *> 1. If we've already finished, no need
              *> trying to wait for the result.
               IF WS-STATUS = "FINISHED"
               THEN
                   MOVE WS-RESULT TO OUT-RESULT
                   GOBACK
               END-IF
               *> 2. Do a blocking wait for the task to
               *>    finish.
               CALL "CBL_GC_WAITPID" USING WS-FORK-PID
               *> 3. Call our post execute procedure.
               PERFORM POST-RESULT
               *> 4. "Return" the result of the task.
               MOVE WS-RESULT TO OUT-RESULT
           GOBACK.

          *> Entry point to get the current status of the task.
           ENTRY "GET-STATUS" USING OUT-STATUS.
              *> 1. If we've already finished, no need
              *> trying to read the file again to get the result.
               IF WS-STATUS = "FINISHED"
               THEN
                   MOVE WS-STATUS TO OUT-STATUS
                   GOBACK
               END-IF
              *> 2. Simplified assumption: if the inter-process
              *>    file exists and isn't empty, assume the
              *>    background work is done.
               CALL "C$FILEINFO" USING
                   WS-INTERPROCESS-FILENAME
                   LS-FILEINFO

              *> 3. If the background work is done, call our
              *>    post execute procedure.
               IF RETURN-CODE = 0 AND LS-SIZE-BYTES > 0
               THEN
                   PERFORM POST-RESULT
               END-IF

              *> 3. "Return" the status of the task. At this point,
              *>    it may be RUNNING or FINISHED.
               MOVE WS-STATUS TO OUT-STATUS
           GOBACK.

          *> Reusable paragraph to publish the result to
          *> our on post execute procedure.
           POST-RESULT.
              *> 1. Read the result from the file.
               OPEN INPUT F-RESULT-FILE
               READ F-RESULT-FILE INTO WS-RESULT

              *> 2. Cleanup the file.
               CLOSE F-RESULT-FILE
               CALL "CBL_DELETE_FILE" USING WS-INTERPROCESS-FILENAME

              *> 3. Call our on post execute procedure.
               CALL WS-PTR-ON-POST-EXECUTE USING WS-RESULT

              *> 4. Finally, our task is done!
               SET WS-STATUS TO "FINISHED"
               .

       END PROGRAM ASYNC-TASK.

