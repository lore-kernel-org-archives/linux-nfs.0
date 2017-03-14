Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26345 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751200AbdCNHIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:08:11 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 11/12] fs, nfs: convert nfs_client.cl_count from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:19 +0200
Message-Id: <1489475240-6594-12-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfs/client.c                        | 12 ++++++------
 fs/nfs/filelayout/filelayout.c         | 12 ++++++------
 fs/nfs/flexfilelayout/flexfilelayout.c | 12 ++++++------
 fs/nfs/nfs4client.c                    | 16 ++++++++--------
 fs/nfs/nfs4proc.c                      | 12 ++++++------
 fs/nfs/nfs4state.c                     |  6 +++---
 include/linux/nfs_fs_sb.h              |  3 ++-
 7 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 91a8d61..6c67d2e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -163,7 +163,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 
 	clp->rpc_ops = clp->cl_nfs_mod->rpc_ops;
 
-	atomic_set(&clp->cl_count, 1);
+	refcount_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
@@ -271,10 +271,10 @@ void nfs_put_client(struct nfs_client *clp)
 	if (!clp)
 		return;
 
-	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
+	dprintk("--> nfs_put_client({%d})\n", refcount_read(&clp->cl_count));
 	nn = net_generic(clp->cl_net, nfs_net_id);
 
-	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
+	if (refcount_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
 		nfs_cb_idr_remove_locked(clp);
 		spin_unlock(&nn->nfs_client_lock);
@@ -319,7 +319,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 							   sap))
 				continue;
 
-		atomic_inc(&clp->cl_count);
+		refcount_inc(&clp->cl_count);
 		return clp;
 	}
 	return NULL;
@@ -1029,7 +1029,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	/* Copy data from the source */
 	server->nfs_client = source->nfs_client;
 	server->destroy = source->destroy;
-	atomic_inc(&server->nfs_client->cl_count);
+	refcount_inc(&server->nfs_client->cl_count);
 	nfs_server_copy_userdata(server, source);
 
 	server->fsid = fattr->fsid;
@@ -1195,7 +1195,7 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
-		   atomic_read(&clp->cl_count),
+		   refcount_read(&clp->cl_count),
 		   clp->cl_hostname);
 	rcu_read_unlock();
 
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 18f98e0..526bd6e 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -498,10 +498,10 @@ filelayout_read_pagelist(struct nfs_pgio_header *hdr)
 		return PNFS_NOT_ATTEMPTED;
 
 	dprintk("%s USE DS: %s cl_count %d\n", __func__,
-		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
+		ds->ds_remotestr, refcount_read(&ds->ds_clp->cl_count));
 
 	/* No multipath support. Use first DS */
-	atomic_inc(&ds->ds_clp->cl_count);
+	refcount_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
 	hdr->ds_commit_idx = idx;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
@@ -542,10 +542,10 @@ filelayout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 
 	dprintk("%s ino %lu sync %d req %zu@%llu DS: %s cl_count %d\n",
 		__func__, hdr->inode->i_ino, sync, (size_t) hdr->args.count,
-		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count));
+		offset, ds->ds_remotestr, refcount_read(&ds->ds_clp->cl_count));
 
 	hdr->pgio_done_cb = filelayout_write_done_cb;
-	atomic_inc(&ds->ds_clp->cl_count);
+	refcount_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
 	hdr->ds_commit_idx = idx;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
@@ -1038,9 +1038,9 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 		goto out_err;
 
 	dprintk("%s ino %lu, how %d cl_count %d\n", __func__,
-		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count));
+		data->inode->i_ino, how, refcount_read(&ds->ds_clp->cl_count));
 	data->commit_done_cb = filelayout_commit_done_cb;
-	atomic_inc(&ds->ds_clp->cl_count);
+	refcount_inc(&ds->ds_clp->cl_count);
 	data->ds_clp = ds->ds_clp;
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 18d4c5a..341b02f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1771,10 +1771,10 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	vers = nfs4_ff_layout_ds_version(lseg, idx);
 
 	dprintk("%s USE DS: %s cl_count %d vers %d\n", __func__,
-		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count), vers);
+		ds->ds_remotestr, refcount_read(&ds->ds_clp->cl_count), vers);
 
 	hdr->pgio_done_cb = ff_layout_read_done_cb;
-	atomic_inc(&ds->ds_clp->cl_count);
+	refcount_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
 	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
 	if (fh)
@@ -1830,11 +1830,11 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 
 	dprintk("%s ino %lu sync %d req %zu@%llu DS: %s cl_count %d vers %d\n",
 		__func__, hdr->inode->i_ino, sync, (size_t) hdr->args.count,
-		offset, ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count),
+		offset, ds->ds_remotestr, refcount_read(&ds->ds_clp->cl_count),
 		vers);
 
 	hdr->pgio_done_cb = ff_layout_write_done_cb;
-	atomic_inc(&ds->ds_clp->cl_count);
+	refcount_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
 	hdr->ds_commit_idx = idx;
 	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
@@ -1899,11 +1899,11 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	vers = nfs4_ff_layout_ds_version(lseg, idx);
 
 	dprintk("%s ino %lu, how %d cl_count %d vers %d\n", __func__,
-		data->inode->i_ino, how, atomic_read(&ds->ds_clp->cl_count),
+		data->inode->i_ino, how, refcount_read(&ds->ds_clp->cl_count),
 		vers);
 	data->commit_done_cb = ff_layout_commit_done_cb;
 	data->cred = ds_cred;
-	atomic_inc(&ds->ds_clp->cl_count);
+	refcount_inc(&ds->ds_clp->cl_count);
 	data->ds_clp = ds->ds_clp;
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 5ae9d64..6984760 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -506,7 +506,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		/* If "pos" isn't marked ready, we can't trust the
 		 * remaining fields in "pos" */
 		if (pos->cl_cons_state > NFS_CS_READY) {
-			atomic_inc(&pos->cl_count);
+			refcount_inc(&pos->cl_count);
 			spin_unlock(&nn->nfs_client_lock);
 
 			nfs_put_client(prev);
@@ -541,7 +541,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		 * way that a SETCLIENTID_CONFIRM to pos can succeed is
 		 * if new and pos point to the same server:
 		 */
-		atomic_inc(&pos->cl_count);
+		refcount_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
 		nfs_put_client(prev);
@@ -558,7 +558,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			prev = NULL;
 			*result = pos;
 			dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
-				__func__, pos, atomic_read(&pos->cl_count));
+				__func__, pos, refcount_read(&pos->cl_count));
 			goto out;
 		case -ERESTARTSYS:
 		case -ETIMEDOUT:
@@ -750,7 +750,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		 * ID and serverowner fields.  Wait for CREATE_SESSION
 		 * to finish. */
 		if (pos->cl_cons_state > NFS_CS_READY) {
-			atomic_inc(&pos->cl_count);
+			refcount_inc(&pos->cl_count);
 			spin_unlock(&nn->nfs_client_lock);
 
 			nfs_put_client(prev);
@@ -784,11 +784,11 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (!nfs4_match_client_owner_id(pos, new))
 			continue;
 found:
-		atomic_inc(&pos->cl_count);
+		refcount_inc(&pos->cl_count);
 		*result = pos;
 		status = 0;
 		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
-			__func__, pos, atomic_read(&pos->cl_count));
+			__func__, pos, refcount_read(&pos->cl_count));
 		break;
 	}
 
@@ -820,7 +820,7 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
 	spin_lock(&nn->nfs_client_lock);
 	clp = idr_find(&nn->cb_ident_idr, cb_ident);
 	if (clp)
-		atomic_inc(&clp->cl_count);
+		refcount_inc(&clp->cl_count);
 	spin_unlock(&nn->nfs_client_lock);
 	return clp;
 }
@@ -875,7 +875,7 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0)
 			continue;
 
-		atomic_inc(&clp->cl_count);
+		refcount_inc(&clp->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 		return clp;
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2c85c9f..7046e56 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4873,7 +4873,7 @@ static void nfs4_renew_release(void *calldata)
 	struct nfs4_renewdata *data = calldata;
 	struct nfs_client *clp = data->client;
 
-	if (atomic_read(&clp->cl_count) > 1)
+	if (refcount_read(&clp->cl_count) > 1)
 		nfs4_schedule_state_renewal(clp);
 	nfs_put_client(clp);
 	kfree(data);
@@ -4921,7 +4921,7 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred,
 
 	if (renew_flags == 0)
 		return 0;
-	if (!atomic_inc_not_zero(&clp->cl_count))
+	if (!refcount_inc_not_zero(&clp->cl_count))
 		return -EIO;
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL)
@@ -7588,7 +7588,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	struct rpc_task *task;
 	int status = -EIO;
 
-	if (!atomic_inc_not_zero(&clp->cl_count))
+	if (!refcount_inc_not_zero(&clp->cl_count))
 		goto out;
 
 	status = -ENOMEM;
@@ -8150,7 +8150,7 @@ static void nfs41_sequence_release(void *data)
 	struct nfs4_sequence_data *calldata = data;
 	struct nfs_client *clp = calldata->clp;
 
-	if (atomic_read(&clp->cl_count) > 1)
+	if (refcount_read(&clp->cl_count) > 1)
 		nfs4_schedule_state_renewal(clp);
 	nfs_put_client(clp);
 	kfree(calldata);
@@ -8179,7 +8179,7 @@ static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	trace_nfs4_sequence(clp, task->tk_status);
 	if (task->tk_status < 0) {
 		dprintk("%s ERROR %d\n", __func__, task->tk_status);
-		if (atomic_read(&clp->cl_count) == 1)
+		if (refcount_read(&clp->cl_count) == 1)
 			goto out;
 
 		if (nfs41_sequence_handle_errors(task, clp) == -EAGAIN) {
@@ -8227,7 +8227,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
 	};
 
-	if (!atomic_inc_not_zero(&clp->cl_count))
+	if (!refcount_inc_not_zero(&clp->cl_count))
 		return ERR_PTR(-EIO);
 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
 	if (calldata == NULL) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 347cb18..8dd2aef 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1171,7 +1171,7 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
 	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		return;
 	__module_get(THIS_MODULE);
-	atomic_inc(&clp->cl_count);
+	refcount_inc(&clp->cl_count);
 
 	/* The rcu_read_lock() is not strictly necessary, as the state
 	 * manager is the only thread that ever changes the rpc_xprt
@@ -1263,7 +1263,7 @@ int nfs4_wait_clnt_recover(struct nfs_client *clp)
 
 	might_sleep();
 
-	atomic_inc(&clp->cl_count);
+	refcount_inc(&clp->cl_count);
 	res = wait_on_bit_action(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
 				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (res)
@@ -2498,7 +2498,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			break;
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 			break;
-	} while (atomic_read(&clp->cl_count) > 1);
+	} while (refcount_read(&clp->cl_count) > 1);
 	return;
 out_error:
 	if (strlen(section))
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b34097c..8a2be4d 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -9,6 +9,7 @@
 #include <linux/sunrpc/xprt.h>
 
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 
 struct nfs4_session;
 struct nfs_iostats;
@@ -24,7 +25,7 @@ struct nfs41_impl_id;
  * The nfs_client identifies our client state to the server.
  */
 struct nfs_client {
-	atomic_t		cl_count;
+	refcount_t		cl_count;
 	atomic_t		cl_mds_count;
 	int			cl_cons_state;	/* current construction state (-ve: init error) */
 #define NFS_CS_READY		0		/* ready to be used */
-- 
2.7.4

