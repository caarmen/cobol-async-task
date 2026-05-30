      *>===========================================================
      *> ACTIVITY.
      *>
      *> This is where the user interacts with the application.
      *> The user provides some input for the AsyncTask.
      *> The input is provided on the command line.
      *>===========================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACTIVITY.

       DATA DIVISION.
       LOCAL-STORAGE SECTION.
       01 LS-PARAM PIC X(50). *> User input.
       01 LS-STATUS PIC X(8). *> The task's status.
       01 LS-RESULT PIC X(50). *> The result of the task.

       PROCEDURE DIVISION.
          *> 1. Read user input from the command line.
           ACCEPT LS-PARAM FROM COMMAND-LINE

          *> 2. Call our task.
           CALL "READ-FILE-TASK" USING LS-PARAM

          *> 3. Get the status.
           CALL "GET-STATUS" USING LS-STATUS
           DISPLAY "Executed task, status is " LS-STATUS

          *> While the task is working:
          *> Option 4a: Uncomment this for a blocking wait
          *>            for the task to finish.
          *>            This option requires GnuCobol to be
          *>            built with support for CBL_GC_WAITPID.
           *> CALL "GET" USING LS-RESULT
          *> Option 4b: Periodically check if the task is finished.
           PERFORM UNTIL LS-STATUS = "FINISHED"
               CALL "C$SLEEP" USING 1
               CALL "GET-STATUS" USING LS-STATUS
               DISPLAY "Polling, status is " LS-STATUS
           END-PERFORM
           .
       END PROGRAM ACTIVITY.
