Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41904 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752046AbdDKQuQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Apr 2017 12:50:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 5/6] lockd: Introduce nlmclnt_operations
Date: Tue, 11 Apr 2017 12:50:11 -0400
Message-Id: <84b14792084a8e148fb3e2d8c22a6a828560eb66.1491917365.git.bcodding@redhat.com>
In-Reply-To: <cover.1491917365.git.bcodding@redhat.com>
References: <cover.1491917365.git.bcodding@redhat.com>
In-Reply-To: <cover.1491917365.git.bcodding@redhat.com>
References: <cover.1491917365.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS would enjoy the ability to modify the behavior of the NLM client's
unlock RPC task in order to delay the transmission of the unlock until IO
that was submitted under that lock has completed.  This ability can ensure
that the NLM client will always complete the transmission of an unlock even
if the waiting caller has been interrupted with fatal signal.

For this purpose, a pointer to a struct nlmclnt_operations can be assigned
in a nfs_module's nfs_rpc_ops that will install those nlmclnt_operations on
the nlm_host.  The struct nlmclnt_operations defines three callback
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
 fs/lockd/clntlock.c         |  1 +
 fs/lockd/clntproc.c         | 26 +++++++++++++++++++++++++-
 fs/nfs/client.c             |  1 +
 fs/nfs/nfs3proc.c           |  2 +-
 fs/nfs/proc.c               |  2 +-
 include/linux/lockd/bind.h  | 24 ++++++++++++++++++++++--
 include/linux/lockd/lockd.h |  2 ++
 include/linux/nfs_xdr.h     |  1 +
 8 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 41e491b8e5d7..27d577dbe51a 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -69,6 +69,7 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	if (host->h_rpcclnt == NULL && nlm_bind_host(host) == NULL)
 		goto out_nobind;
 
+	host->h_nlmclnt_ops = nlm_init->nlmclnt_ops;
 	return host;
 out_nobind:
 	nlmclnt_release_host(host);
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 112952037933..066ac313ae5c 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -150,17 +150,22 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
  * @host: address of a valid nlm_host context representing the NLM server
  * @cmd: fcntl-style file lock operation to perform
  * @fl: address of arguments for the lock operation
+ * @data: address of data to be sent to callback operations
  *
  */
-int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
+int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *data)
 {
 	struct nlm_rqst		*call;
 	int			status;
+	const struct nlmclnt_operations *nlmclnt_ops = host->h_nlmclnt_ops;
 
 	call = nlm_alloc_call(host);
 	if (call == NULL)
 		return -ENOMEM;
 
+	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_alloc_call)
+		nlmclnt_ops->nlmclnt_alloc_call(data);
+
 	nlmclnt_locks_init_private(fl, host);
 	if (!fl->fl_u.nfs_fl.owner) {
 		/* lockowner allocation has failed */
@@ -169,6 +174,7 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 	}
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
+	call->a_callback_data = data;
 
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->fl_type != F_UNLCK) {
@@ -214,8 +220,12 @@ struct nlm_rqst *nlm_alloc_call(struct nlm_host *host)
 
 void nlmclnt_release_call(struct nlm_rqst *call)
 {
+	const struct nlmclnt_operations *nlmclnt_ops = call->a_host->h_nlmclnt_ops;
+
 	if (!atomic_dec_and_test(&call->a_count))
 		return;
+	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_release_call)
+		nlmclnt_ops->nlmclnt_release_call(call->a_callback_data);
 	nlmclnt_release_host(call->a_host);
 	nlmclnt_release_lockargs(call);
 	kfree(call);
@@ -687,6 +697,19 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 	return status;
 }
 
+static void nlmclnt_unlock_prepare(struct rpc_task *task, void *data)
+{
+	struct nlm_rqst	*req = data;
+	const struct nlmclnt_operations *nlmclnt_ops = req->a_host->h_nlmclnt_ops;
+	bool defer_call = false;
+
+	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_unlock_prepare)
+		defer_call = nlmclnt_ops->nlmclnt_unlock_prepare(task, req->a_callback_data);
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
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c335c6dce285..f4c022e57541 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -536,6 +536,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 		.noresvport	= server->flags & NFS_MOUNT_NORESVPORT ?
 					1 : 0,
 		.net		= clp->cl_net,
+		.nlmclnt_ops 	= clp->cl_nfs_mod->rpc_ops->nlmclnt_ops,
 	};
 
 	if (nlm_init.nfs_version > 3)
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index dc925b531f32..03b3c3de28f1 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -870,7 +870,7 @@ nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = file_inode(filp);
 
-	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
+	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl, NULL);
 }
 
 static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index b7bca8303989..9872cf676a50 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -638,7 +638,7 @@ nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = file_inode(filp);
 
-	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
+	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl, NULL);
 }
 
 /* Helper functions for NFS lock bounds checking */
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 140edab64446..05728396a1a1 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -18,6 +18,7 @@
 
 /* Dummy declarations */
 struct svc_rqst;
+struct rpc_task;
 
 /*
  * This is the set of functions for lockd->nfsd communication
@@ -43,6 +44,7 @@ struct nlmclnt_initdata {
 	u32			nfs_version;
 	int			noresvport;
 	struct net		*net;
+	const struct nlmclnt_operations	*nlmclnt_ops;
 };
 
 /*
@@ -52,8 +54,26 @@ struct nlmclnt_initdata {
 extern struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init);
 extern void	nlmclnt_done(struct nlm_host *host);
 
-extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
-					struct file_lock *fl);
+/*
+ * NLM client operations provide a means to modify RPC processing of NLM
+ * requests.  Callbacks receive a pointer to data passed into the call to
+ * nlmclnt_proc().
+ */
+struct nlmclnt_operations {
+	/* Called on successful allocation of nlm_rqst, use for allocation or
+	 * reference counting. */
+	void (*nlmclnt_alloc_call)(void *);
+
+	/* Called in rpc_task_prepare for unlock.  A return value of true
+	 * indicates the callback has put the task to sleep on a waitqueue
+	 * and NLM should not call rpc_call_start(). */
+	bool (*nlmclnt_unlock_prepare)(struct rpc_task*, void *);
+
+	/* Called when the nlm_rqst is freed, callbacks should clean up here */
+	void (*nlmclnt_release_call)(void *);
+};
+
+extern int	nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *data);
 extern int	lockd_up(struct net *net);
 extern void	lockd_down(struct net *net);
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index c15373894a42..01c38992150d 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -69,6 +69,7 @@ struct nlm_host {
 	char			*h_addrbuf;	/* address eyecatcher */
 	struct net		*net;		/* host net */
 	char			nodename[UNX_MAXNODENAME + 1];
+	const struct nlmclnt_operations	*h_nlmclnt_ops;	/* Callback ops for NLM users */
 };
 
 /*
@@ -142,6 +143,7 @@ struct nlm_rqst {
 	struct nlm_block *	a_block;
 	unsigned int		a_retries;	/* Retry count */
 	u8			a_owner[NLMCLNT_OHSIZE];
+	void *	a_callback_data; /* sent to nlmclnt_operations callbacks */
 };
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 348f7c158084..3279ab2e1fee 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1550,6 +1550,7 @@ struct nfs_rpc_ops {
 	const struct inode_operations *dir_inode_ops;
 	const struct inode_operations *file_inode_ops;
 	const struct file_operations *file_ops;
+	const struct nlmclnt_operations *nlmclnt_ops;
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
-- 
2.9.3

