      *>===========================================================
      *> READ-FILE-TASK.
      *>
      *> We can imagine a task that reads a large file from disk,
      *> performs some processing on the file data, and returns a
      *> result. For demo purposes, we just simulate the long
      *> processing with a "sleep".
      *> For simplicity, the return value is text.
      *>===========================================================
       PROGRAM-ID. READ-FILE-TASK.
       DATA DIVISION.

       LOCAL-STORAGE SECTION.
      *> Pointer to procedure which will perform the background work.
       01 LS-PTR-DO-IN-BACKGROUND PROCEDURE-POINTER.
      *> Pointer to procedure to be called when the result is ready.
       01 LS-PTR-ON-POST-EXECUTE PROCEDURE-POINTER.

       LINKAGE SECTION.
      *> Arguments for DO-IN-BACKGROUND:
       01 IN-PARAM PIC X(50). *> The task input.
       01 OUT-RESULT PIC X(50). *> The result of the task.

      *> Arguments for ON-POST-EXECUTE:
       01 IN-RESULT PIC X(50). *> The result is then input to the post
                               *> execution task

       PROCEDURE DIVISION USING IN-PARAM.
           *> Setup the procedure pointers and pass them to the
           *> AsyncTask.
           SET LS-PTR-DO-IN-BACKGROUND TO ENTRY "DO-IN-BACKGROUND"
           SET LS-PTR-ON-POST-EXECUTE TO ENTRY "ON-POST-EXECUTE"
           CALL "ASYNC-TASK" USING
               IN-PARAM
               LS-PTR-DO-IN-BACKGROUND
               LS-PTR-ON-POST-EXECUTE
           GOBACK.

      *> Our background work is here.
      *> This procedure is called in a child process.
      *>
      *> Simulate a long-running task with a "sleep".
      *> Return some fake task result as a string "Some result".
      *> @WorkerThread
       ENTRY "DO-IN-BACKGROUND" USING
           IN-PARAM
           OUT-RESULT.
           DISPLAY "doInBackground: process input " IN-PARAM
          *> Simulate long-running operation with a sleep
           CALL "C$SLEEP" USING 3
           STRING "Some result for " IN-PARAM INTO OUT-RESULT
           GOBACK
           .

      *> This entry point is called after the background work
      *> completes.
      *> This procedure is called in the main process.
      *> @MainThread
       ENTRY "ON-POST-EXECUTE" USING IN-RESULT.
           DISPLAY "onPostExecute: result = " IN-RESULT
           GOBACK
           .
       
       END PROGRAM READ-FILE-TASK.
