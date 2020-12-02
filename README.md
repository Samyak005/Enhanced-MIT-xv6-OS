### How to Run:
```bash
make clean
make SCHEDULER=DEFAULT/FCFS/PBS/MLFQ && make qemu
```

To measure time for different scheduling algos Run:
time benchmark 

Refer Assignment.pdf -> major code changes made are shown in README (tip: search 'insert' in all files to see my inserts)
### WAITX SYSCALL

For implementing waitx syscall in the struct proc, three values ctime, rtime, etime were maintained. The value ctime was initialised in allocproc and the value rtime was incremented after every clock tick. 
etime was set at the end of the process.//end time - create time - run time = wait time 

The syscall waitx simply obtains the required values from the struct proc. Rest of the implementation is identical to wait.

### PS SYSCALL - ADDED IN PROC.C 

Similar to waitx, we maintain the required info in the struct proc and obtain the info from process table whenever this syscall is called.

```c
//my insert
//psinfo syscall
int psinfo()
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleeping",
  [RUNNABLE]  "runnable",
  [RUNNING]   "running",
  [ZOMBIE]    "zombie"
  };

  //acquire process table lock
  acquire(&ptable.lock);
  //scan through process table
  struct proc *p;
  cprintf("pid, priority, state, ctime, rtime,  wtime, n_run, cur_q, q[0], q[1], q[2], q[3], q[4]\n");

  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
  	#ifdef MLFQ
  	if(p->pid!=0)
  	{
  		cprintf("%d %d %s %d %d %d %d %d %d %d %d %d %d\n", p->pid, p->priority, states[p->state], p->ctime,
      	p->rtime, ticks - p->q_in_current_slice - p->cur_qaddtime, p->n_run, p->cur_q, 
      	p->q[0], p->q[1], p->q[2], p->q[3], p->q[4]);
  	}
  	#else
  	if(p->pid!=0)
  	{
  		cprintf("%d %d %s %d %d %d %d %d %d %d %d %d %d\n", p->pid, p->priority, states[p->state], p->ctime,
      	p->rtime, p->etime - p->ctime - p->rtime, p->n_run, p->cur_q, 
      	p->q[0], p->q[1], p->q[2], p->q[3], p->q[4]);
  	}
  	#endif
  }

  //release process table lock
  release(&ptable.lock);
  return 1;
}
```

SET_PRIORITY SYSCALL - ADDED IN PROC.C 

If priority is reduced then yield

```c
//my insert
//set_priority syscall
int set_priority(int new_priority, int pid)
{
  int old_priority = -1;
  int yieldFlag = 0;
  //acquire process table lock
  acquire(&ptable.lock);

  //scan through process table
  struct proc *p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    yieldFlag =0;
    // cprintf("outside pid %d p->priority %d new_priority %d\n", pid, p->priority, new_priority);
    if (p->pid == pid)
    {
      //store old priority and change the priority
      cprintf("pid %d p->priority %d new_priority %d\n", pid, p->priority, new_priority);
      old_priority = p->priority;
      p->priority = new_priority;
      if (old_priority > p->priority)
          yieldFlag = 1;
    }
  }

  if (yieldFlag == 1)
    yield();
  //release process table lock
  release(&ptable.lock);

  //output old priority
  return old_priority;
}
```

CHANGES MADE IN PROC.C

```c
//my insert begin
int addtoq(struct proc *p, int cur_q);
int removefromq(struct proc *p, int cur_q);

//Queues for MLFQ
struct proc *queues[5][NPROC];
// Note that values will initially automatically be 0
int count_in_queues[5];
int max_ticks_in_queue[5] = {1, 2, 4, 8, 16};
//my insert end
```

ALLOCPROC:
```c
  // my insert begin 
  //Add times to process
  p->ctime = ticks;
  p->rtime = 0;
  p->etime = 0;

  //Set default priority of process
  p->priority = 60;

#ifdef MLFQ
  //Add process to queue 0 of MLFQ
  queues[0][count_in_queues[0]] = p;
  count_in_queues[0]++;

  p->cur_q = 0;
  p->q_in_current_slice = 0;

  p->n_run = 0;
  for (int i = 0; i < 5; i++)
  {
    p->q[i] = 0;
  }

#endif
  // my insert ends
```
  
USERINIT:
```c
  // my insert begins
  #ifdef MLFQ
      addtoq(p, 0);
  #endif
  // my insert ends
```

FORK:
```c
  // my insert begins
  #ifdef MLFQ
      addtoq(np, 0);
      cprintf("in Fork process %d added to queue 0\n", pid);
 //     psinfo();
  #endif
  // my insert ends
```
 
EXIT:
```c
  // my insert begins
  //update the end time of process
  curproc->etime = ticks;
  // my insert ends   
```
  
WAIT:
```c
        //my insert begins
        #ifdef MLFQ
          removefromq(p, p->cur_q);
        #endif 
        // my insert ends
```
        
```c
// this function adds a process to the queue
int addtoq(struct proc *p, int cur_q)
{ 
  // check if the process is already present in the current queue
  for(int i=0; i < count_in_queues[cur_q]; i++)
  {
    if(p->pid == queues[cur_q][i]->pid)
      return -1;
  }
  // reset paremeters of process p
  p->cur_q= cur_q;
  p->cur_qaddtime = ticks;
  p->q_in_current_slice=0;

  count_in_queues[cur_q]++;
  queues[cur_q][count_in_queues[cur_q]-1] = p;

  return 1;
}

int removefromq(struct proc *p, int cur_q)
{
  // cprintf("in delete process to q %d \n", cur_q);
  int found = 0;
  int qindex = 0;
  for(int i=0; i <= count_in_queues[cur_q]; i++)
  {
    if(queues[cur_q][i] -> pid == p->pid)
    {
      qindex = i;
      found = 1;
      break;
    }
  }
// process not found - already exited
  if(found  == 0)
  {
    return -1;
  }

  for(int i = qindex; i < count_in_queues[cur_q]; i++)
    queues[cur_q][i] = queues[cur_q][i+1]; 

  count_in_queues[cur_q]--;

  // reset parameters of process p
  p->cur_qaddtime = -1;
  p->q_in_current_slice = 0;
  return 1;

}

void printQueueStatus()
{
// Print queue status 
    for (int i=0;i<5;i++)
    {
      if (count_in_queues[i] >0) 
        {
          cprintf("num in queue %d is %d \n", i, count_in_queues[i]);
          for (int j=0; j<count_in_queues[i]; j++)
          {
            cprintf("process waiting in queue %d %d \n", i, queues[i][j]->pid);
          }
        }
    }
}
```

```c
// renamed the old scheduler 
// my insert begins
void scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  psinfo();

  for (;;)
  {
    // Enable interrupts on this processor.
    sti();

#ifdef FCFS
    //cprintf("FCFS\n");
    //FCFS scheduling
    // Loop over process table looking for first process
    acquire(&ptable.lock);

    struct proc *first_p = 0;

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->state != RUNNABLE)
        continue;

      if (!first_p)
      {
        first_p = p;
      }
      else
      {
        if (p->ctime < first_p->ctime)
        {
          first_p = p;
        }
      }
    }
    if ((first_p) && (first_p->state == RUNNABLE))
    {
      p = first_p;
      //cprintf("pid of first_p %d\n", first_p->pid);
      // Switch to chosen process
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;
      p->n_run++;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state
      c->proc = 0;
    }
    release(&ptable.lock);
#endif

#ifdef PBS
    //cprintf("PBS\n");
    //Priority based scheduling
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    struct proc *highest_priority_process = 0;

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->state != RUNNABLE)
        continue;

      if (!highest_priority_process)
      {
        highest_priority_process = p;
      }
      else
      {
        if (p->priority < highest_priority_process->priority)
        {
          highest_priority_process = p;
        }
      }
    }
    if (highest_priority_process)
    {
      p = highest_priority_process;
      //cprintf("pid of highest_priority_process %d\n", p->pid);
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);

#endif

#ifdef MLFQ
    // Multilevel feedback queue scheduling

    //psinfo();


    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    //See which processes have expired their time slices
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->state != RUNNABLE)
        continue;
      if (p->q_in_current_slice >= max_ticks_in_queue[p->cur_q])
      {
        //cprintf("Process %d hit %d ticks\n",p->pid,p->q_in_current_slice);
        if (p->cur_q != 4)
        {
          //demote priority
          removefromq(p, p->cur_q);
          p->cur_q++;
          p->q_in_current_slice = 0;
          addtoq(p,p->cur_q);

          //cprintf("Process %d priority demoted to %d\n",p->pid,p->cur_q);
        }
        else
        {
          // delete from the queue 4 and add to end of queue
          if (count_in_queues[4] >=1)
          {
            removefromq(p, p->cur_q);
            addtoq(p,p->cur_q);
          }
          p->q_in_current_slice = 0;
        }
      }
    }
    //implements aging
    //promote processes with longer wait times
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->state != RUNNABLE)
        continue;
      // if waiting too long in low priority queue
      if((ticks - p->cur_qaddtime > 100) && (p->cur_q!=0))
       {
          //cprintf("Process %d priority promoted to %d\n",p->pid,p->cur_q);
          removefromq(p, p->cur_q);
          p->cur_q--;
          p->q_in_current_slice = 0;
          addtoq(p,p->cur_q);
       }
    }

    // printQueueStatus();

    struct proc *process_to_run = 0;
    int priority=0; //queue number
    
    // Run processes in order of priority
    while ((priority<5) && (!process_to_run))
    {
        if (count_in_queues[priority] >0)
        {
          //cprintf("non empty queue %d \n", priority);
          int qindex =0;
          while ((qindex < count_in_queues[priority]) && (queues[priority][qindex]->state != RUNNABLE))
          {
            //cprintf("Non Runnable state in queue %d index of queue %d process id %d \n", priority, qindex, queues[priority][qindex]->pid);
            qindex++;          
          }

          //cprintf("non empty queue %d with sequence %d \n", priority, qindex);
          
          if((qindex < count_in_queues[priority]) && (queues[priority][qindex]->state == RUNNABLE))
          {
            process_to_run = queues[priority][qindex];
           // cprintf("Process to run %d\n", process_to_run->pid);
          }

        }
        priority++;
    }
    // If process found
    if (process_to_run)
    {
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      // cprintf("MLFQ 3\n");
      p = process_to_run;
      p->n_run++;
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }

    release(&ptable.lock);

#endif

#ifdef DEFAULT
    //cprintf("DEFAULT\n");
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
#endif
  }
}
// my insert ends
```

### FCFS
Search for the process that is runnable and has minimum ctime and make it run.

### PBS 
Search for the process that is runnable and has minimum priority(numerically) or maximum priority and make it run.
All processes are given a default priority of 60 when allocated.

### MLFQ
Queues have been initialised in the beginning. Number of processes in each queue is maintained.
Two functions have been created addtoq and removefromq. 
Aging has been implemented by increasing priority for a process taking longer time to execute.

For each process, queue and q_in_current_slice have been initialised that maintain the queue it is in and the 
number of ticks it has consumed in the current time slice.

When processes are created, we add them to queue 0 initially.
If process has taken longer time than it should in the queue, it is demoted to a lower queue.

When scheduling, check first queue and check if any process is ready to execute.
After that we go to the lower queues and check.

### General
If a process voluntarily relinquishes control of the CPU, it leaves the queuing
network, and when the process becomes ready again after the I/O, it is​ ​inserted
at the tail of the same queue, from which it was relinquished earlier​.

A process could potentially take advantage of this scheduling policy by giving up CPU just before time slice is over, 
so that it is not demoted to a lower queue and gets a fresh time slice.

Time comparisons:
FCFS - Status is 4, Wait time is 3615, Running time is 4
PBS - Status is 15, Wait time is 2050, Running time is 5
DEFAULT - Status is 4, Wait time is 2064, Running time is 4
MLFQ - Status is 4, Wait time is 2088, Running time is 7

In trap.c : 
FCFS is non-preemptive. For other scheduling algos yield.
#ifndef FCFS
		yield();
#endif


update_running_time -> function in proc.c called in trap.c -> updates running time if process is in RUNNING state