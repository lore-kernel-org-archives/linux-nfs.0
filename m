From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 08/15] knfsd: spawn kernel thread to probe callback
	channel
Date: Mon, 27 Aug 2007 16:22:49 -0400
Message-ID: <1188246177259-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, Adrian Bunk <bunk@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl6y-0004gz-Az
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:00 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl71-0000Vo-09
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:04 -0700
In-Reply-To: <11882461773396-git-send-email-bfields@fieldses.org>
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

From: J. Bruce Fields <bfields@citi.umich.edu>

We want to allow gss on the callback channel, so people using krb5 can
still get the benefits of delegations.

But looking up the rpc credential can take some time in that case.  And
we shouldn't delay the response to setclientid_confirm while we wait.

It may be inefficient, but for now the simplest solution is just to
spawn a new thread as necessary for the purpose.

(Thanks to Adrian Bunk for catching a missing static here.)

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: Adrian Bunk <bunk@kernel.org>
---
 fs/nfsd/nfs4callback.c |   71 +++++++++++++++++++++++-------------------------
 1 files changed, 34 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 31d6633..c17a520 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -39,6 +39,7 @@
 #include <linux/errno.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
+#include <linux/kthread.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/clnt.h>
@@ -365,6 +366,35 @@ nfsd4_lookupcred(struct nfs4_client *clp, int taskflags)
         return ret;
 }
 
+/* Reference counting, callback cleanup, etc., all look racy as heck.
+ * And why is cb_set an atomic? */
+
+static int do_probe_callback(void *data)
+{
+	struct nfs4_client *clp = data;
+	struct nfs4_callback *cb = &clp->cl_callback;
+	struct rpc_message msg = {
+		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
+		.rpc_argp       = clp,
+	};
+	int status;
+
+	msg.rpc_cred = nfsd4_lookupcred(clp, 0);
+	if (IS_ERR(msg.rpc_cred))
+		goto out;
+	status = rpc_call_sync(cb->cb_client, &msg, RPC_TASK_SOFT);
+	put_rpccred(msg.rpc_cred);
+
+	if (status) {
+		rpc_shutdown_client(cb->cb_client);
+		cb->cb_client = NULL;
+	} else
+		atomic_set(&cb->cb_set, 1);
+out:
+	put_nfs4_client(clp);
+	return 0;
+}
+
 /*
  * Set up the callback client and put a NFSPROC4_CB_NULL on the wire...
  */
@@ -390,11 +420,7 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 		.authflavor	= RPC_AUTH_UNIX,	/* XXX: need AUTH_GSS... */
 		.flags		= (RPC_CLNT_CREATE_NOPING),
 	};
-	struct rpc_message msg = {
-		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
-		.rpc_argp       = clp,
-	};
-	int status;
+	struct task_struct *t;
 
 	if (atomic_read(&cb->cb_set))
 		return;
@@ -426,16 +452,11 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	/* the task holds a reference to the nfs4_client struct */
 	atomic_inc(&clp->cl_count);
 
-	msg.rpc_cred = nfsd4_lookupcred(clp,0);
-	if (IS_ERR(msg.rpc_cred))
-		goto out_release_clp;
-	status = rpc_call_async(cb->cb_client, &msg, RPC_TASK_ASYNC, &nfs4_cb_null_ops, NULL);
-	put_rpccred(msg.rpc_cred);
+	t = kthread_run(do_probe_callback, clp, "nfs4_cb_probe");
 
-	if (status != 0) {
-		dprintk("NFSD: asynchronous NFSPROC4_CB_NULL failed!\n");
+	if (IS_ERR(t))
 		goto out_release_clp;
-	}
+
 	return;
 
 out_release_clp:
@@ -447,30 +468,6 @@ out_err:
 		(int)clp->cl_name.len, clp->cl_name.data);
 }
 
-static void
-nfs4_cb_null(struct rpc_task *task, void *dummy)
-{
-	struct nfs4_client *clp = (struct nfs4_client *)task->tk_msg.rpc_argp;
-	struct nfs4_callback *cb = &clp->cl_callback;
-	__be32 addr = htonl(cb->cb_addr);
-
-	dprintk("NFSD: nfs4_cb_null task->tk_status %d\n", task->tk_status);
-
-	if (task->tk_status < 0) {
-		dprintk("NFSD: callback establishment to client %.*s failed\n",
-			(int)clp->cl_name.len, clp->cl_name.data);
-		goto out;
-	}
-	atomic_set(&cb->cb_set, 1);
-	dprintk("NFSD: callback set to client %u.%u.%u.%u\n", NIPQUAD(addr));
-out:
-	put_nfs4_client(clp);
-}
-
-static const struct rpc_call_ops nfs4_cb_null_ops = {
-	.rpc_call_done = nfs4_cb_null,
-};
-
 /*
  * called with dp->dl_count inc'ed.
  * nfs4_lock_state() may or may not have been called.
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
