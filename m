From: Bob Bell <b_linuxnfs@thebellsplace.com>
Subject: [PATCH] Forced unmount - fail future RPCs too
Date: Thu, 1 Nov 2007 17:58:23 -0400
Message-ID: <20071101215822.GA22035@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ini3Q-00059D-Qo
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 14:58:20 -0700
Received: from srv03.macroped.com ([74.52.9.226])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ini3W-0007vi-Ab
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 14:58:26 -0700
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id lA1LxGLG024463
	for <nfs@lists.sourceforge.net>; Thu, 1 Nov 2007 17:59:17 -0400
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

Modify NFS forced unmount behavior to not only return -EIO for all
currently scheduled RPCs, but to also return -EIO for future RPCs.  Only
a single forced unmount operation is therefore required to ensure that
all application will eventually return to userspace.

Signed-off-by: Bob Bell <b_linuxnfs@thebellsplace.com>
---

At EMC I've been looking into handling the case when an NFS server goes
down, and that's had me looking at forcibly unmounting NFS filesystems.
I've found that it takes two forced unmount operations to fail most NFS
filesystem operations (in particularly, read()) back to the application.
This is because an NFS forced unmount operation really translates to
"fail all RPC operations currently in progress".

Typically, a forced unmount during a read system call will result in
cancelling an RPC that was created as part of readahead.  Though the
readhead RPC is cancelled, another RPC is then started to perform the
read explicitly.  This requires another forced unmount attempt before
the read syscall returns to the userspace application.  Additionally, if
the read was partially successful, the syscall will return the number of
bytes read.  If the application attempts a read again to get the rest,
two more force unmount operations will be required before the
application gets an EIO error.  While the application has any of these
RPCs scheduled it is unkillable, even with SIGKILL.

My patch changes the behavior from "fail all RPC operations currently in
progress" to "fail all current and future RPC operations".
I accomplished this by setting a bit in the RPC client, and checking
that bit in the RPC finite-state machine.  I put the check in the FSM to
avoid needing to check every way that an RPC operation could be
scheduled.  It also means that I don't need to worry about synchronous
versus asynchronous scheduling, etc.  This was the best approach for me,
given my amount of experience with the NFS code, though perhaps you
would have a different approach.

With this patch, a forcible lazy unmount (MNT_FORCE|MNT_DETACH) works
particularly well.  It ensures that all RPC operations for the
filesystem will return -EIO, and that the resources for the filesystem
will be cleaned up once all applications release their associated file
descriptors (and that the applications will at least occasionally drop
back into userspace and handle signals if they fail to release those
open files).

Being new to the NFS code, I don't know how many awful coding
catastrophes I may have committed, but I hope that this feature can be
considered, even if the implementation may need to modifed.


 fs/nfs/super.c              |    2 +-
 include/linux/sunrpc/clnt.h |    3 ++-
 net/sunrpc/sched.c          |   10 ++++++++++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8ed5937..cd67788 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -602,7 +602,7 @@ static void nfs_umount_begin(struct vfsm
 
 	if (!(flags & MNT_FORCE))
 		return;
-	/* -EIO all pending I/O */
+	/* -EIO all pending and future I/O */
 	rpc = server->client_acl;
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c0d9d14..8db7da8 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -43,7 +43,8 @@ struct rpc_clnt {
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
 				cl_intr     : 1,/* interruptible */
 				cl_discrtry : 1,/* disconnect before retry */
-				cl_autobind : 1;/* use getport() */
+				cl_autobind : 1,/* use getport() */
+				cl_shutdown : 1;/* fail with -EIO */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 954d7ec..2da90ec 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -663,6 +663,15 @@ static void __rpc_execute(struct rpc_tas
 		}
 
 		/*
+		 * Fail with -EIO if the client has been shut down.
+		 */
+		if (task->tk_client->cl_shutdown &&
+		    !(task->tk_flags & RPC_TASK_KILLED)) {
+			task->tk_flags |= RPC_TASK_KILLED;
+			rpc_exit(task, -EIO);
+		}
+
+		/*
 		 * Perform the next FSM step.
 		 * tk_action may be NULL when the task has been killed
 		 * by someone else.
@@ -947,6 +956,7 @@ void rpc_killall_tasks(struct rpc_clnt *
 	 * Spin lock all_tasks to prevent changes...
 	 */
 	spin_lock(&clnt->cl_lock);
+	clnt->cl_shutdown = 1;
 	list_for_each_entry(rovr, &clnt->cl_tasks, tk_task) {
 		if (! RPC_IS_ACTIVATED(rovr))
 			continue;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
