#include "types.h"
#include "user.h"
#include "fcntl.h"

int number_of_processes = 10;

int main(int argc, char *argv[])
{
  int j;
  psinfo();
  int stime=200;
  for (j = 0; j < number_of_processes; j++)
  {
    int pid = fork();
    if (pid < 0)
    {
      printf(1, "Fork failed\n");
      continue;
    }
    if (pid == 0)
    {
      volatile int i;
      for (volatile int k = 0; k < number_of_processes; k++)
      {
        if (k <= j)
        {
          sleep(stime); //io time
          if ((k % 2) == 1) 
            stime += 50;
          else
            stime -= 50;
        }
        else
        {
          if (k==j) 
            sleep(100);
          for (i = 0; i < 100000000; i++); // was acting like sleep 
          // {
            // printf(1, "%s",""); //cpu time
          // }
        }
      }
       //printf(1, "Process: %d Finished\n", j);
       psinfo();
      exit();
    }
    else{
        
       set_priority(100-(20+j),pid); // will only matter for PBS, comment it out if not implemented yet (better priorty for more IO intensive jobs)
    }
  }
  for (j = 0; j < number_of_processes+5; j++)
  {
    wait();
  }
  exit();
}
