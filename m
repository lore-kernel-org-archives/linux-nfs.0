From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [patch 1/4] RPC: acquire BKL while calling rpc_release()
	callback
Date: Tue, 17 Oct 2006 10:24:33 -0700
Message-ID: <1161105873.3315.21.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZsgI-00019t-Ct
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:46 -0700
Received: from e34.co.us.ibm.com ([32.97.110.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZsgH-0000Iw-5E
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:47 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com
	[9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HHOTDK031004
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 13:24:29 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9HHOSHw210954
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:28 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9HHOSoW020845
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:28 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9HHOSTM020798
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:28 -0600
To: NFS List <nfs@lists.sourceforge.net>
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

The Big Kernel Lock must be held while calling rpc_release().

Signed-off-by: Frank Filz <ffilz@us.ibm.com>
---

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 78696f2..185e093 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -29,6 +29,7 @@ #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
+#include <linux/smp_lock.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -529,8 +530,11 @@ rpc_call_async(struct rpc_clnt *clnt, st
 	rpc_restore_sigmask(&oldset);		
 	return status;
 out_release:
-	if (tk_ops->rpc_release != NULL)
+	if (tk_ops->rpc_release != NULL) {
+		lock_kernel();
 		tk_ops->rpc_release(data);
+		unlock_kernel();
+	}
 	return status;
 }
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index a1ab4ee..406aae5 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -884,8 +884,11 @@ #ifdef RPC_DEBUG
 #endif
 	if (task->tk_flags & RPC_TASK_DYNAMIC)
 		rpc_free_task(task);
-	if (tk_ops->rpc_release)
+	if (tk_ops->rpc_release) {
+		lock_kernel();
 		tk_ops->rpc_release(calldata);
+		unlock_kernel();
+	}
 }
 
 /**
@@ -902,8 +905,11 @@ struct rpc_task *rpc_run_task(struct rpc
 	struct rpc_task *task;
 	task = rpc_new_task(clnt, flags, ops, data);
 	if (task == NULL) {
-		if (ops->rpc_release != NULL)
+		if (ops->rpc_release != NULL) {
+			lock_kernel();
 			ops->rpc_release(data);
+			unlock_kernel();
+		}
 		return ERR_PTR(-ENOMEM);
 	}
 	atomic_inc(&task->tk_count);



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
