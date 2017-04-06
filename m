Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45122 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754577AbdDFLXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 07:23:25 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 5/6] lockd: Introduce nlmclnt_operations
Date: Thu,  6 Apr 2017 07:23:21 -0400
Message-Id: <1e8da8e98e4dad013328ad5b7974e9d11256e863.1491477181.git.bcodding@redhat.com>
In-Reply-To: <cover.1491477181.git.bcodding@redhat.com>
References: <cover.1491477181.git.bcodding@redhat.com>
In-Reply-To: <cover.1491477181.git.bcodding@redhat.com>
References: <cover.1491477181.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS would enjoy the ability to modify the behavior of the NLM client's
unlock RPC task in order to delay the transmission of the unlock until IO
that was submitted under that lock has completed.  This ability can ensure
that the NLM client will always complete the transmission of an unlock even
if the waiting caller has been interrupted with fatal signal.

A struct nlmclnt_operations and callback data pointer can be passed to
nlmclnt_proc(). The struct nlmclnt_operations defines three callback
operations that will be used in a following patch:

nlmclnt_alloc_call - used to call back after a successful allocation of
	a struct nlm_rqst in nlmclnt_proc().

nlmclnt_unlock_prepare - used to call back during NLM unlock's
	rpc_call_prepare.  The NLM client defers calling rpc_call_start()
	until this callback returns false.

nlmclnt_release_call - used to call back when the NLM client's struct
	nlm_rqst is freed.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/clntproc.c         | 26 +++++++++++++++++++++++++-
 fs/nfs/nfs3proc.c           |  2 +-
 fs/nfs/proc.c               |  2 +-
 include/linux/lockd/bind.h  | 11 +++++++++--
 include/linux/lockd/lockd.h |  2 ++
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 112952037933..d2744f4960ed 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -150,9 +150,12 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
  * @host: address of a valid nlm_host context representing the NLM server
  * @cmd: fcntl-style file lock operation to perform
  * @fl: address of arguments for the lock operation
+ * @nlmclnt_ops: operations to call back out of nlm
+ * @data: address of data to be sent along with callback
  *
  */
-int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
+int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl,
+		const struct nlmclnt_operations *nlmclnt_ops, void *data)
 {
 	struct nlm_rqst		*call;
 	int			status;
@@ -161,6 +164,9 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 	if (call == NULL)
 		return -ENOMEM;
 
+	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_alloc_call)
+		nlmclnt_ops->nlmclnt_alloc_call(data);
+
 	nlmclnt_locks_init_private(fl, host);
 	if (!fl->fl_u.nfs_fl.owner) {
 		/* lockowner allocation has failed */
@@ -169,6 +175,8 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 	}
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
+	call->nlmclnt_ops = nlmclnt_ops;
+	call->callback_data = data;
 
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->fl_type != F_UNLCK) {
@@ -216,6 +224,8 @@ void nlmclnt_release_call(struct nlm_rqst *call)
 {
 	if (!atomic_dec_and_test(&call->a_count))
 		return;
+	if (call->nlmclnt_ops && call->nlmclnt_ops->nlmclnt_release_call)
+		call->nlmclnt_ops->nlmclnt_release_call(call->callback_data);
 	nlmclnt_release_host(call->a_host);
 	nlmclnt_release_lockargs(call);
 	kfree(call);
@@ -687,6 +697,19 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 	return status;
 }
 
+static void nlmclnt_unlock_prepare(struct rpc_task *task, void *data)
+{
+	struct nlm_rqst	*req = data;
+	const struct nlmclnt_operations *nlmclnt_ops = req->nlmclnt_ops;
+	bool defer_call = false;
+
+	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_unlock_prepare)
+		defer_call = nlmclnt_ops->nlmclnt_unlock_prepare(task, req->callback_data);
+
+	if (!defer_call)
+		rpc_call_start(task);
+}
+
 static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)
 {
 	struct nlm_rqst	*req = data;
@@ -720,6 +743,7 @@ static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)
 }
 
 static const struct rpc_call_ops nlmclnt_unlock_ops = {
+	.rpc_call_prepare = nlmclnt_unlock_prepare,
 	.rpc_call_done = nlmclnt_unlock_callback,
 	.rpc_release = nlmclnt_rpc_release,
 };
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index dc925b531f32..086623ab07b1 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -870,7 +870,7 @@ nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = file_inode(filp);
 
-	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
+	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl, NULL, NULL);
 }
 
 static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b7bca8303989..fb8cbdf0a980 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -638,7 +638,7 @@ nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = file_inode(filp);
 
-	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
+	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl, NULL, NULL);
 }
 
 /* Helper functions for NFS lock bounds checking */
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 140edab64446..00c3c2a62bb5 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -18,6 +18,7 @@
 
 /* Dummy declarations */
 struct svc_rqst;
+struct rpc_task;
 
 /*
  * This is the set of functions for lockd->nfsd communication
@@ -52,8 +53,14 @@ struct nlmclnt_initdata {
 extern struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init);
 extern void	nlmclnt_done(struct nlm_host *host);
 
-extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
-					struct file_lock *fl);
+struct nlmclnt_operations {
+	void (*nlmclnt_alloc_call)(void *);
+	bool (*nlmclnt_unlock_prepare)(struct rpc_task*, void *);
+	void (*nlmclnt_release_call)(void *);
+};
+
+extern int	nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl,
+	const struct nlmclnt_operations *nlmclnt_ops, void *data);
 extern int	lockd_up(struct net *net);
 extern void	lockd_down(struct net *net);
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index c15373894a42..0c6f777dde53 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -142,6 +142,8 @@ struct nlm_rqst {
 	struct nlm_block *	a_block;
 	unsigned int		a_retries;	/* Retry count */
 	u8			a_owner[NLMCLNT_OHSIZE];
+	const struct nlmclnt_operations * nlmclnt_ops;
+	void * callback_data;
 };
 
 /*
-- 
2.9.3

