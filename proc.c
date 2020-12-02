#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

//my insert begin
int addtoq(struct proc *p, int cur_q);
int removefromq(struct proc *p, int cur_q);

//Queues for MLFQ
struct proc *queues[5][NPROC];
// Note that values will initially automatically be 0
int count_in_queues[5];
int max_ticks_in_queue[5] = {1, 2, 4, 8, 16};
//my insert end

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  
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

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  // my insert begins
  #ifdef MLFQ
      addtoq(p, 0);
  #endif
      // my insert ends

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;
  // my insert begins
  #ifdef MLFQ
      addtoq(np, 0);
      cprintf("in Fork process %d added to queue 0\n", pid);
 //     psinfo();
  #endif
  // my insert ends
  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  // my insert begins
  //update the end time of process
  curproc->etime = ticks;
  // my insert ends
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        //my insert begins
        #ifdef MLFQ
          removefromq(p, p->cur_q);
        #endif 
        // my insert ends

        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
//my insert
//waitx syscall
int waitx(int *wtime, int *rtime)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();

  acquire(&ptable.lock);
  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    {
      if (p->parent != curproc)
        continue;
      havekids = 1;
      if (p->state == ZOMBIE)
      {
        // Found one.

        //Update times
        *wtime = p->etime - p->ctime - p->rtime; // end time - create time - run time = wait time 
        *rtime = p->rtime;

        //Clean up times
        p->ctime = 0;
        p->etime = 0;
        p->rtime = 0;

        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        #ifdef MLFQ
          removefromq(p, p->cur_q); // remove from q if zombie
        #endif 


        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || curproc->killed)
    {
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock); //DOC: wait-sleep
  }
}

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
  // struct process_info *process_state_info;
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

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler_old(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
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

  }
}

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
//  p->
  
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
    // cprintf("PBS\n");
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

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  //my insert begins
	#ifdef MLFQ
	  p->q_in_current_slice = 0;
	#endif
  //my insert ends

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
      //my insert begins
      #ifdef MLFQ
        addtoq(p, p->cur_q);
      #endif
      // my insert ends
    }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// my insert begins
//Update running time for running processes
void update_running_time()
{
  //Acquire process table lock
  acquire(&ptable.lock);
  struct proc *p;
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
  {
    // if process is running
    if (p->state == RUNNING)
    {
      //update running time
      p->rtime++;

//update q_in_current_slice in case of MLFQ
#ifdef MLFQ
      p->q_in_current_slice++;
      p->q[p->cur_q]++;
      p->last_executed = ticks;
#endif
    }
  }

  //Release process table lock
  release(&ptable.lock);
}
//my insert ends	

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s %d", p->pid, state, p->name, p->priority);//my insert -> priority printed %d
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
