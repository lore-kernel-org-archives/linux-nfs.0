From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH] asynchronous unlock on exit
Date: Thu, 06 Mar 2008 15:43:03 -0500
Message-ID: <47D05757.30002@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000200030106010908070002"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754747AbYCFUnP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2008 15:43:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000200030106010908070002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

In the course of investigating testing failures in the locking phase of the
Connectathon testsuite, I discovered a couple of things.  One was that one
of the tests in the locking tests was racy when it didn't seem to need to be
and two, that the NFS client asynchronously releases locks when a process is
exiting.

I developed a patch for the testsuite locking test and am working to try to
find a way to get it included into the generally available testsuite.

The harder problem is that the NFS client kernel code asynchronously 
releasing
locks when a process is exiting.  I presume that this was added so that a
process, which was holding locks when a server goes down, can be completely
killed.  This sounds good, but leads to several problems.

The Single UNIX Specification Version 3 specifies that:  "All locks 
associated
with a file for a given process shall be removed when a file descriptor 
for that
file is closed by that process or the process holding that file descriptor
terminates.".

This does not specify whether those locks must be released prior to the
completion of the exit processing for the process or not.  However, general
assumptions seem to be that those locks will be released.  This leads to 
more
deterministic behavior under normal circumstances.

The test, test12(), in the Connectathon locking tests, tests the assumption
that if a process is holding a lock and gets signaled with a signal that 
causes
it to be killed, that it releases its lock.  The file, which was locked, can
then be successfully locked by another process.

After further analysis, it appears that only the NFSv2 and NFSv3 clients
release locks asynchronously when a process is exiting.  The NFSv4 client
releases any locks synchronously.

I would propose to make all three versions match and to modify the 
NFSv2/NFSv3
behavior to match the NFSv4 behavior.  The attached patch implements 
this change.

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------000200030106010908070002
Content-Type: text/x-patch;
 name="async_unlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="async_unlock.patch"

--- linux-2.6.24.i686/fs/lockd/clntproc.c.org
+++ linux-2.6.24.i686/fs/lockd/clntproc.c
@@ -155,8 +155,6 @@ static void nlmclnt_release_lockargs(str
 int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 {
 	struct nlm_rqst		*call;
-	sigset_t		oldset;
-	unsigned long		flags;
 	int			status;
 
 	nlm_get_host(host);
@@ -168,22 +166,6 @@ int nlmclnt_proc(struct nlm_host *host, 
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
 
-	/* Keep the old signal mask */
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	oldset = current->blocked;
-
-	/* If we're cleaning up locks because the process is exiting,
-	 * perform the RPC call asynchronously. */
-	if ((IS_SETLK(cmd) || IS_SETLKW(cmd))
-	    && fl->fl_type == F_UNLCK
-	    && (current->flags & PF_EXITING)) {
-		sigfillset(&current->blocked);	/* Mask all signals */
-		recalc_sigpending();
-
-		call->a_flags = RPC_TASK_ASYNC;
-	}
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->fl_type != F_UNLCK) {
 			call->a_args.block = IS_SETLKW(cmd) ? 1 : 0;
@@ -198,11 +180,6 @@ int nlmclnt_proc(struct nlm_host *host, 
 	fl->fl_ops->fl_release_private(fl);
 	fl->fl_ops = NULL;
 
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	current->blocked = oldset;
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
 	dprintk("lockd: clnt proc returns %d\n", status);
 	return status;
 }

--------------000200030106010908070002--
