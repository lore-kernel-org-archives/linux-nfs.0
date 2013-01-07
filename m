Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:44597 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab3AGS7L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 13:59:11 -0500
Received: by mail-ie0-f178.google.com with SMTP id c12so24767647ieb.9
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jan 2013 10:59:10 -0800 (PST)
Date: Mon, 7 Jan 2013 13:58:48 -0500
From: Chris Perl <chris.perl@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Possible Race Condition on SIGKILL
Message-ID: <20130107185848.GB16957@nyc-qws-132.nyc.delacy.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="6WlEvdN9Dv0WHSBl"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

(Apologies up front for the long email, just trying to be thorough)

I have come across a hang in the Linux NFS client that is reproducible.  I've
been testing with a Fedora 17 system (3.6.10-2.fc17.x86_64), but I've also seen
the same issues on CentOS 6.3 systems (2.6.32-279.5.2.el6.centos.plus.x86_64).
I have not had a chance to test the latest 3.8 rc kernels yet, but quickly
browsing their code, I didn't see major changes in the key areas to make me
think it would make a difference (but I could certainly be wrong).

Unfortunately, the problem is not easily reproducible.  So far, the only way
that I've been able to trigger it is with the attached OCaml program [1].

Even more unfortunate, for you to compile and use that program, you'll need to
have a functioning OCaml environment with Jane Street's Core and Async
libraries available.  I can give details about the easiest way to set that up
if you want, but will hold off on that for now.  Please let me know if you want
these details.

The idea of the program is that it spawns many threads that start stat'ing and
reading files over NFS (the paths to each file are command line args) and then
abruptly exits.

Originally, I came across a system that hung and forced a crash dump of the
kernel that I then inspected with crash [2].  With crash I could see that the
rpc_task referenced by the snd_task member in the relevant rpc_xprt didn't
exist.

Then after talking with some coworkers (and inspecting several more hung
systems), eventually came up with a way to reproduce the problem.  To reproduce
the problem, you actually need to take the compiled OCaml program (which
purposely exits very quickly after starting) and wrap it in a loop that will
immediately restart it when it exits:

$ while :; do ./hang.opt /mnt/nfs/file{01..10} >/dev/null 2>&1; done                  

In this case, file01 through 10 are 10k text files filled entirely with the
character "A".  /mnt/nfs is the mount point with the following options

$ nfsstat -m
/mnt/nfs from 127.0.0.1:/var/tmp
Flags: rw,relatime,vers=3rsize=524288,wsize=524288,namelen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=127.0.0.1,mountvers=3,mountport=20048,mountproto=tcp,local_lock=none,addr=127.0.0.1

And the hang should happen within a few minutes (although sometimes it did
take quite a while for it to hang).

I believe the problem is a race condition where one thread that currently has
the `rpc_xprt' for a given NFS mount locked tries to give it to another thread
on the `sending' wait queue for that `rpc_xprt' (via __xprt_lock_write_next),
but the thread that is presumably sleeping on that wait queue never made it to
sleep because it received a SIGKILL before it could do so.

Here is the interaction that I believe is causing the problem:

thread 1					     thread 2
--------					     --------
__rpc_execute
...
call_reserve
xprt_reserve
xprt_lock_and_alloc_slot
xprt_lock_write
xprt_reserve_xprt (locks rpc_xprt)
xprt_alloc_slot
						     __rpc_execute
						     ...
						     call_reserve
						     xprt_reserve
						     xprt_lock_and_alloc_slot
						     xprt_lock_write
						     xprt_reserve_xprt
						     rpc_sleep_on ("sending" wait queue)
						     out_of_line_wait_on_bit
xprt_release_write
xprt_release_xprt
xprt_clear_locked
__xprt_lock_write_next
						     (receives SIGKILL from a 3rd thread)
						     rpc_wait_bit_killable
						      (will return ERESTARTSYS b/c of SIGNAL)
rpc_wake_up_first (wq:sending,
                    f:__xprt_lock_write_func) 
__xprt_lock_write_func (w/ task from sending)
                                                     rpc_exit
						     rpc_exit_task
...                                                  ...

At this point the first thread has updated rpc_xprt->snd_task to point to the
second thread, and left the rpc_xprt locked, but the second thread is exiting
because of the SIGKILL.  The real issue is the second thread was added to the
"sending" wait queue (by rpc_sleep_on), but never actually made it to sleep.

The net effect of this is that the transport remains locked by a phantom
rpc_task.  Any other requests that come in now just go to sleep on the
rpc_xprt's sending wait queue, and no progress is made.  Any mount point that
winds up using this rpc_xprt is now hung.

To help me understand what was happening, I used the attached systemtap script
[3] to watch the system and upon each return from __rpc_execute, check to see
if our task is the task currently listed in the associated rpc_xprt's snd_task
member, as I believe this should never be the case.  Running that script
produced output like the following when it hung:


[cperl@cesium ~/tmp/2013-01-05]$ sudo stap -DMAXMAPENTRIES=4096 -g ./catch_locked.stp --vp 00101
Pass 3: translated to C into "/tmp/stapMZvjDF/stap_23115b4269a0722946b88ddf556678e4_18614_src.c" using 354096virt/32668res/6728shr/25096data kb, in 90usr/10sys/101real ms.
Pass 5: starting run.
1357430209194595979: 30246: thread-pool thr -> __rpc_execute: task=0xffff88011f39ec00: GETATTR
1357430209194599327: 30246: thread-pool thr    tk_callback: 0x0, tk_action: call_start
1357430209194602139: 30246: thread-pool thr    tk_callback: 0x0, tk_action: call_reserve
1357430209195083066: 30246: thread-pool thr    status: -512
1357430209195085888: 30246: thread-pool thr    -> rpc_exit:
1357430209195088144: 30246: thread-pool thr    tk_callback: 0x0, tk_action: rpc_exit_task
1357430209195090865: 30246: thread-pool thr    tk_callback: 0x0, tk_action: 0x0
1357430209195093517: 30246: thread-pool thr <- __rpc_execute: tk_status: 0x0
^CPass 5: run completed in 10usr/30sys/33870real ms.

After this happened, I used crash on the live system and indeed, this task was
the one that was listed in rpc_xprt->snd_task for the transport.  The rest of
the circumstances of the hang I inferred by looking at the code, so I
could definitely be wrong.

The systemtap script places probe points at specific lines within the
code (to be able to look at tk_action and tk_callback), so it would need
to be tweaked if run on a different kernel than the fedora 17 kernel I'm
running it against.

Of course its entirely possible that I've missed some lock or something that
makes what I've outlined above safe and fine, but in that case, I still have an
NFS hang that I need to figure out.

[1] hang.ml
[2] http://people.redhat.com/anderson/crash_whitepaper/
[3] catch_locked.stp


--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hang.ml"

open Core.Std
open Async.Std

let bytes_read = ref 0;;

let () =
  let files = List.tl_exn (Array.to_list Sys.argv) in
  let fts =
    List.map files ~f:(fun file -> File_tail.create file)
  in
  Deferred.List.iter fts ~f:(fun ft ->
    Pipe.iter_without_pushback ft ~f:(fun update ->
      let amt =
        match update with
        | File_tail.Update.Data s -> bytes_read := String.length s + !bytes_read; !bytes_read
        | File_tail.Update.Warning (s,w) -> ignore s; ignore w; !bytes_read
        | _ -> failwith "foo"
      in
      if amt < 8192 then
        ()
      else
        failwith ("Read: " ^ string_of_int amt)
    )
  )
  >>> fun () ->
  shutdown 0
;;

let () = never_returns (Scheduler.go ())

--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="catch_locked.stp"

%{
#include <linux/sunrpc/xprt.h>
%}

probe module("sunrpc").function("__rpc_execute").call {
    t = task_current();
    msg = sprintf("%d: %d: %s -> %s: %s: %s\n",
        gettimeofday_ns(), pid(), execname(), "__rpc_execute", $$parms, kernel_string($task->tk_msg->rpc_proc->p_name));
    speculate(t, msg);
}

probe module("sunrpc").function("__rpc_execute").return {
    t = task_current();
    status = $task->tk_status;
    msg = sprintf("%d: %d: %s <- %s: tk_status: %d\n", gettimeofday_ns(), pid(), execname(), "__rpc_execute", status);
    speculate(t, msg);
    xprt = $task->tk_client->cl_xprt;
    xprt_lock(xprt);
    task = @cast(xprt, "rpc_xprt")->snd_task;
    xprt_unlock(xprt)
    if (task == $task) {
        commit(t);
    }
    else {
        discard(t);
    }
}

probe module("sunrpc").function("rpc_exit").call {
    t = task_current();
    msg = sprintf("%d: %d: %s    -> %s:\n", gettimeofday_ns(), pid(), execname(), "rpc_exit");
    speculate(t, msg);
}

/*
probe module("sunrpc").function("rpc_exit").return {
    t = task_current();
    msg = sprintf("%d: %d: %s   <- %s\n", gettimeofday_ns(), pid(), execname(), "rpc_exit");
    speculate(t, msg);
}
*/

probe module("sunrpc").statement("*@net/sunrpc/sched.c:703") {
    t = task_current();
    msg = sprintf("%d: %d: %s    tk_callback: %s, tk_action: %s\n",
        gettimeofday_ns(), pid(), execname(),  symname($task->tk_callback), symname($task->tk_action));
    speculate(t, msg);
}

probe module("sunrpc").statement("*@net/sunrpc/sched.c:762") {
    t = task_current();
    msg = sprintf("%d: %d: %s    status: 0x%d\n", gettimeofday_ns(), pid(), execname(), $status);
    speculate(t, msg);
}

function xprt_lock(xprt:long)
%{
    struct rpc_xprt *xp = (struct rpc_xprt *) STAP_ARG_xprt;
    spin_lock_bh(&(xp->transport_lock));
%}

function xprt_unlock(xprt:long)
%{
    struct rpc_xprt *xp = (struct rpc_xprt *) STAP_ARG_xprt;
    spin_unlock_bh(&(xp->transport_lock));
%}


--6WlEvdN9Dv0WHSBl--
