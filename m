From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Odd bug with connectathon tlock test case on 2.6.16 kernel
Date: Wed, 23 May 2007 10:07:19 -0700
Message-ID: <1179940039.8988.29.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HquFd-0003hk-Vy
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 10:03:54 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HquFg-0006MN-Cd
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 10:03:56 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4NG1d6N001876
	for <nfs@lists.sourceforge.net>; Wed, 23 May 2007 12:01:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l4NH3jqK552802
	for <nfs@lists.sourceforge.net>; Wed, 23 May 2007 13:03:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l4NH3iTs012358
	for <nfs@lists.sourceforge.net>; Wed, 23 May 2007 13:03:44 -0400
Received: from [9.47.22.153] (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l4NH3iSC012320
	for <nfs@lists.sourceforge.net>; Wed, 23 May 2007 13:03:44 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

We are running connectathon tests using NFS v4 along with other tests on
a 2.6.16 kernel. We saw a problem where a hang occurs because of the
cl_sem being held. It turns out the problem is that the problem really
is that one of the child processes has exited, though it's still a
zombie process, and specifically has already gone through
__exit_files(), yet the process still holds a lock. When the parent
process attempts to request a conflicting lock, it blocks (unfortunately
holding the cl_sem - though I believe later patches may resolve that
specific issue - but as a result, might hide this issue).

In diagnosing, I added a bunch of printks to check what is going on. It
turns out to be very interesting, I see the child process releasing the
lock, yet, when the parent process goes to acquire the lock, the child
process appears to hold the lock, however, the lock turns out to be a
different struct file_lock (address is different).

Here are the relevant printk outputs (with line numbers added for ease
of reference):

01 process 7460 (tlocklfs) about_to_exit_files, files->count=1
02 process 7460, tgid=7460, files=0000000000000000 removing locks on file null
03 process 7460, tgid=7460, files=0000000000000000 removing locks on file cthon04.stdout
04 process 7460, tgid=7460, files=0000000000000000 removing locks on file cthon04.stderr
05 process 7460, tgid=7460, files=0000000000000000 removing locks on file null
06 process 7460, tgid=7460, files=0000000000000000 removing locks on file nohup.out
07 process 7460, tgid=7460, files=0000000000000000 removing locks on file nohup.out
08 process 7460, tgid=7460, files=0000000000000000 removing locks on file STAFProc.tmp
09 Done releasing
10 Printing locks for inode c0000000b507b748
11 POSIX lock c0000000bb0b96d0, owner=c00000000bcaab00, pid=3990, start=0, end=9223372036854775807
12 process 7460, tgid=7460, files=0000000000000000 removing locks on file lockfile20710
13 About to call f_op->lock
14 Printing locks for inode c00000001a6205d0
15 POSIX lock c0000000a7d63630, owner=c0000000567b4500, pid=7460, start=0, end=9223372036854775807
16 Returned from f_op->lock
17 Printing locks for inode c00000001a6205d0
18 process 20710 about_to_block on POSIX lock
19 Req c0000000a7d63310, pid=20710, owner=c0000000952e9780, start=0, end=9223372036854775807
20 Cnf c0000000a86d1130, pid=7460, owner=c0000000567b4500, start=0, end=9223372036854775807
21 ---------------------------------------
22 Task c0000000319880c0 pid=20710, comm=tlocklfs, files=c0000000952e9780, LOCK REQUESTER
23 Task c0000000101f4440 pid=19942, comm=sh, files=c0000000a3bc0480
24 Task c00000006c9182c0 pid=21743, comm=sh, files=c00000005cdfcc00
25 Task c000000057bc7060 pid=19069, comm=sh, files=c00000000bc3d480
26 Task c0000000b867e9d0 pid=4025, comm=STAFProc, files=c00000000bcaab00
27 Task c0000000bffa7060 pid=1, comm=init, files=c0000000bff91b00
28 Task c0000000004a2ae0 pid=0, comm=swapper, files=c0000000004b40f0
29 ---------------------------------------
30 Task c000000078b784c0 pid=7460, comm=tlocklfs, files=0000000000000000, LOCK HOLDER
31 Task c00000005e0f4f50 pid=20717, comm=tlocklfs, files=c0000000382a4400
32 Task c0000000319880c0 pid=20710, comm=tlocklfs, files=c0000000952e9780
33 Task c0000000101f4440 pid=19942, comm=sh, files=c0000000a3bc0480
34 Task c00000006c9182c0 pid=21743, comm=sh, files=c00000005cdfcc00
35 Task c000000057bc7060 pid=19069, comm=sh, files=c00000000bc3d480
36 Task c0000000b867e9d0 pid=4025, comm=STAFProc, files=c00000000bcaab00
37 Task c0000000bffa7060 pid=1, comm=init, files=c0000000bff91b00
38 Task c0000000004a2ae0 pid=0, comm=swapper, files=c0000000004b40f0
39 All locks on this file
40 Printing locks for inode c00000001a6205d0
41 POSIX lock c0000000a86d1130, owner=c0000000567b4500, pid=7460, start=0, end=9223372036854775807

Lines 1-17 are process 7460 in __exit_files(). Lines 12-17 are the
result of releasing locks on the file in question. Note how before it
calls f_op->lock, 7460 holds one lock on the file (line 14-15 result
from walking the lock list for the file in question and printing all
locks). After f_op->lock returns, the lock list is printed again, this
time it is empty.

Starting at line 18 is process 20710 in __posix_lock_file(). When a
conflicting lock is found, the requested lock and the conflicting lock
are displayed (line 19 and 20). Note that the address of the conflicting
lock is different from the one originally held by 7460, yet this new
lock appears to be held by 7460. It also has an fl_owner address that
matches the task->files address 7460 originally had (though these
printks don't show that, earlier debugging did show that).

Next, the process list is walked looking for interesting processes (the
requester process, the holding process, and the process that has a files
pointer the same as the conflicting lock's fl_owner (which is not found,
since 7460 now has a NULL files pointer). For each interesting process,
the parent process chain is followed (showing that 7460 is a grandchild
of 20710).

Finally, in lines 39-41, all locks held on the relevant file are shown.
My last round of debugging added the file_lock addresses and the inode
addresses to verify that the same file was indeed in question, and that
the file_lock was the same or different.

So somehow, it seems that AFTER 7460 went through __exit_files() and
released the lock, a new lock was created (or at least was floating
somewhere) and attached to the file.

Does anyone have any thoughts as to where this new/second lock came
from?

Thanks

Frank Filz



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
