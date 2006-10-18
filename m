From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch 0/4] correct kernel locking for RPC
	rpc_release	callbacks
Date: Wed, 18 Oct 2006 18:41:11 -0400
Message-ID: <1161211271.6095.207.camel@lade.trondhjem.org>
References: <1161105870.3315.20.camel@dyn9047022153>
	<76bd70e30610181322j639e1ea9ifb5965cb61612934@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilzlnx@us.ibm.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaK6I-0007P7-LE
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 15:41:26 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaK6F-0006Vu-UZ
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 15:41:27 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30610181322j639e1ea9ifb5965cb61612934@mail.gmail.com>
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

On Wed, 2006-10-18 at 16:22 -0400, Chuck Lever wrote:
> I am a little concerned that the RPC scheduler is taking and dropping
> such a heavy-weight serialization primitive multiple times per RPC.
> Perhaps the next step should be removing the requirement for the
> lock/unlock calls around the tk_action call to reduce this overhead.

I've already applied and tested the following patch. It should push the
BKL out of the actual RPC code, but keeps it for the auth_gss and
NFS/NLM encode/decode routines. The next step should be to review the
latter...

Cheers,
 Trond

-------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 18 Oct 2006 16:01:06 -0400
Subject: SUNRPC: Remove BKL around the RPC socket operations etc.

All internal RPC client operations should no longer depend on the BKL,
however lockd and NFS callbacks may still require it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c  |    8 +++++++-
 net/sunrpc/sched.c |    8 ++++----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a17cf0e..90a0fb1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -27,6 +27,7 @@ #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/smp_lock.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
 
@@ -811,8 +812,10 @@ call_encode(struct rpc_task *task)
 	if (encode == NULL)
 		return;
 
+	lock_kernel();
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
+	unlock_kernel();
 	if (task->tk_status == -ENOMEM) {
 		/* XXX: Is this sane? */
 		rpc_delay(task, 3*HZ);
@@ -1143,9 +1146,12 @@ call_decode(struct rpc_task *task)
 
 	task->tk_action = rpc_exit_task;
 
-	if (decode)
+	if (decode) {
+		lock_kernel();
 		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
 						      task->tk_msg.rpc_resp);
+		unlock_kernel();
+	}
 	dprintk("RPC: %4d call_decode result %d\n", task->tk_pid,
 					task->tk_status);
 	return;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 287fe9a..7cb888a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -561,7 +561,9 @@ void rpc_delay(struct rpc_task *task, un
  */
 static void rpc_prepare_task(struct rpc_task *task)
 {
+	lock_kernel();
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);
+	unlock_kernel();
 }
 
 /*
@@ -571,7 +573,9 @@ void rpc_exit_task(struct rpc_task *task
 {
 	task->tk_action = NULL;
 	if (task->tk_ops->rpc_call_done != NULL) {
+		lock_kernel();
 		task->tk_ops->rpc_call_done(task, task->tk_calldata);
+		unlock_kernel();
 		if (task->tk_action != NULL) {
 			WARN_ON(RPC_ASSASSINATED(task));
 			/* Always release the RPC slot and buffer memory */
@@ -624,9 +628,7 @@ static int __rpc_execute(struct rpc_task
 			 */
 			save_callback=task->tk_callback;
 			task->tk_callback=NULL;
-			lock_kernel();
 			save_callback(task);
-			unlock_kernel();
 		}
 
 		/*
@@ -637,9 +639,7 @@ static int __rpc_execute(struct rpc_task
 		if (!RPC_IS_QUEUED(task)) {
 			if (task->tk_action == NULL)
 				break;
-			lock_kernel();
 			task->tk_action(task);
-			unlock_kernel();
 		}
 
 		/*



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
