From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] SUNRPC: Invalid BUG_ON() popping in rpc_release_task()
Date: Sun, 21 Jan 2007 06:53:05 -0500
Message-ID: <45B35421.1010908@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090506030703050803010406"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H8bG6-0002xJ-Cd
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 03:53:16 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H8bG6-0001RJ-AR
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 03:53:14 -0800
To: nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------090506030703050803010406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Over the weekend, while doing some Secure NFS testing, I found
that the BUG_ON() in  rpc_release_task() would pop when
the Kerberos server was not set up correctly (which I know is a
very common problem when people start using this feature).

The code path looks like:
rpc_call_sync() calls rpc_call_setup() which calls rpcauth_bindcred()
which fails (due to a krb5 problem) and sets tk_status to -EACCES.

Back in rpc_call_sync(), since (tk_status != 0) rpc_release_task()
is called. Unfortunately, since this task was never active,
(meaning rpc_execute() and rpc_set_active() were never called)
the tk_magic id was never set and the global task list was
never set up. So when rpc_release_task() is call, the world
come tumbling down...

So the attached patch ensures the RPC_TASK_ACTIVE run state bit
is set before calling the BUG_ON() and cleaning up the task
list.


steved.


--------------090506030703050803010406
Content-Type: text/x-patch;
 name="linux-2.6.20-rpc-sec-error.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.20-rpc-sec-error.patch"

Only check the magic number and clean the tk_task queue
iff the task was active. 

Signed-off-by: Steve Dickson <steved@redhat.com>
-------------------------------------------------
--- nfs-2.6/net/sunrpc/sched.c.orig	2006-12-23 07:03:31.000000000 -0500
+++ nfs-2.6/net/sunrpc/sched.c	2007-01-21 06:17:32.000000000 -0500
@@ -898,16 +898,18 @@ EXPORT_SYMBOL(rpc_put_task);
 
 void rpc_release_task(struct rpc_task *task)
 {
-#ifdef RPC_DEBUG
-	BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);
-#endif
 	dprintk("RPC: %4d release task\n", task->tk_pid);
 
-	/* Remove from global task list */
-	spin_lock(&rpc_sched_lock);
-	list_del(&task->tk_task);
-	spin_unlock(&rpc_sched_lock);
+	if (test_bit(RPC_TASK_ACTIVE, &task->tk_runstate)) {
+#ifdef RPC_DEBUG
+		BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);
+#endif
 
+		/* Remove from global task list */
+		spin_lock(&rpc_sched_lock);
+		list_del(&task->tk_task);
+		spin_unlock(&rpc_sched_lock);
+	}
 	BUG_ON (RPC_IS_QUEUED(task));
 
 	/* Synchronously delete any running timer */

--------------090506030703050803010406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------090506030703050803010406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090506030703050803010406--
