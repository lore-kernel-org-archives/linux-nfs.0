Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57858 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752787AbdJTJ4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:56:08 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 11/11] fs, nfs: convert nfs_client.cl_count from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:38 +0300
Message-Id: <1508493218-27760-12-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nfs_client.cl_count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfs/client.c                        | 10 +++++-----
 fs/nfs/filelayout/filelayout.c         | 12 ++++++------
 fs/nfs/flexfilelayout/flexfilelayout.c | 12 ++++++------
 fs/nfs/nfs4client.c                    | 10 +++++-----
 fs/nfs/nfs4proc.c                      | 12 ++++++------
 fs/nfs/nfs4state.c                     |  6 +++---
 include/linux/nfs_fs_sb.h              |  3 ++-
 7 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 22880ef..0ac2fb1 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -163,7 +163,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 
 	clp->rpc_ops = clp->cl_nfs_mod->rpc_ops;
 
-	atomic_set(&clp->cl_count, 1);
+	refcount_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
 	memcpy(&clp->cl_addr, cl_init->addr, cl_init->addrlen);
@@ -269,7 +269,7 @@ void nfs_put_client(struct nfs_client *clp)
 
 	nn = net_generic(clp->cl_net, nfs_net_id);
 
-	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
+	if (refcount_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
 		list_del(&clp->cl_share_link);
 		nfs_cb_idr_remove_locked(clp);
 		spin_unlock(&nn->nfs_client_lock);
@@ -314,7 +314,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 							   sap))
 				continue;
 
-		atomic_inc(&clp->cl_count);
+		refcount_inc(&clp->cl_count);
 		return clp;
 	}
 	return NULL;
@@ -1006,7 +1006,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	/* Copy data from the source */
 	server->nfs_client = source->nfs_client;
 	server->destroy = source->destroy;
-	atomic_inc(&server->nfs_client->cl_count);
+	refcount_inc(&server->nfs_client->cl_count);
 	nfs_server_copy_userdata(server, source);
 
 	server->fsid = fattr->fsid;
@@ -1166,7 +1166,7 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
-		   atomic_read(&clp->cl_count),
+		   refcount_read(&clp->cl_count),
 		   clp->cl_hostname);
 	rcu_read_unlock();
 
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 508126e..4e54d8b 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -471,10 +471,10 @@ filelayout_read_pagelist(struct nfs_pgio_header *hdr)
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
@@ -515,10 +515,10 @@ filelayout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 
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
@@ -1064,9 +1064,9 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
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
index ff55a0a..c75ad98 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1726,10 +1726,10 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
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
@@ -1785,11 +1785,11 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 
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
@@ -1863,11 +1863,11 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
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
index e9bea90..31b5bc0 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -483,7 +483,7 @@ static int nfs4_match_client(struct nfs_client  *pos,  struct nfs_client *new,
 	 * ID and serverowner fields.  Wait for CREATE_SESSION
 	 * to finish. */
 	if (pos->cl_cons_state > NFS_CS_READY) {
-		atomic_inc(&pos->cl_count);
+		refcount_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
 		nfs_put_client(*prev);
@@ -559,7 +559,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		 * way that a SETCLIENTID_CONFIRM to pos can succeed is
 		 * if new and pos point to the same server:
 		 */
-		atomic_inc(&pos->cl_count);
+		refcount_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
 		nfs_put_client(prev);
@@ -715,7 +715,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 			continue;
 
 found:
-		atomic_inc(&pos->cl_count);
+		refcount_inc(&pos->cl_count);
 		*result = pos;
 		status = 0;
 		break;
@@ -749,7 +749,7 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
 	spin_lock(&nn->nfs_client_lock);
 	clp = idr_find(&nn->cb_ident_idr, cb_ident);
 	if (clp)
-		atomic_inc(&clp->cl_count);
+		refcount_inc(&clp->cl_count);
 	spin_unlock(&nn->nfs_client_lock);
 	return clp;
 }
@@ -804,7 +804,7 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0)
 			continue;
 
-		atomic_inc(&clp->cl_count);
+		refcount_inc(&clp->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 		return clp;
 	}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 57c38ea..350dbc9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4843,7 +4843,7 @@ static void nfs4_renew_release(void *calldata)
 	struct nfs4_renewdata *data = calldata;
 	struct nfs_client *clp = data->client;
 
-	if (atomic_read(&clp->cl_count) > 1)
+	if (refcount_read(&clp->cl_count) > 1)
 		nfs4_schedule_state_renewal(clp);
 	nfs_put_client(clp);
 	kfree(data);
@@ -4891,7 +4891,7 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred,
 
 	if (renew_flags == 0)
 		return 0;
-	if (!atomic_inc_not_zero(&clp->cl_count))
+	if (!refcount_inc_not_zero(&clp->cl_count))
 		return -EIO;
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL) {
@@ -7472,7 +7472,7 @@ nfs4_run_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	struct nfs41_exchange_id_data *calldata;
 	int status;
 
-	if (!atomic_inc_not_zero(&clp->cl_count))
+	if (!refcount_inc_not_zero(&clp->cl_count))
 		return ERR_PTR(-EIO);
 
 	status = -ENOMEM;
@@ -8072,7 +8072,7 @@ static void nfs41_sequence_release(void *data)
 	struct nfs4_sequence_data *calldata = data;
 	struct nfs_client *clp = calldata->clp;
 
-	if (atomic_read(&clp->cl_count) > 1)
+	if (refcount_read(&clp->cl_count) > 1)
 		nfs4_schedule_state_renewal(clp);
 	nfs_put_client(clp);
 	kfree(calldata);
@@ -8101,7 +8101,7 @@ static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	trace_nfs4_sequence(clp, task->tk_status);
 	if (task->tk_status < 0) {
 		dprintk("%s ERROR %d\n", __func__, task->tk_status);
-		if (atomic_read(&clp->cl_count) == 1)
+		if (refcount_read(&clp->cl_count) == 1)
 			goto out;
 
 		if (nfs41_sequence_handle_errors(task, clp) == -EAGAIN) {
@@ -8149,7 +8149,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
 	};
 
-	if (!atomic_inc_not_zero(&clp->cl_count))
+	if (!refcount_inc_not_zero(&clp->cl_count))
 		return ERR_PTR(-EIO);
 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
 	if (calldata == NULL) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1887134..3bd79b8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1177,7 +1177,7 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
 	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		return;
 	__module_get(THIS_MODULE);
-	atomic_inc(&clp->cl_count);
+	refcount_inc(&clp->cl_count);
 
 	/* The rcu_read_lock() is not strictly necessary, as the state
 	 * manager is the only thread that ever changes the rpc_xprt
@@ -1269,7 +1269,7 @@ int nfs4_wait_clnt_recover(struct nfs_client *clp)
 
 	might_sleep();
 
-	atomic_inc(&clp->cl_count);
+	refcount_inc(&clp->cl_count);
 	res = wait_on_bit_action(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
 				 nfs_wait_bit_killable, TASK_KILLABLE);
 	if (res)
@@ -2510,7 +2510,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			break;
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 			break;
-	} while (atomic_read(&clp->cl_count) > 1);
+	} while (refcount_read(&clp->cl_count) > 1);
 	return;
 out_error:
 	if (strlen(section))
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 74c4466..efcfe9d 100644
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

