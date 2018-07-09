Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:26954 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933283AbeGIT0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:26:30 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 5/9] NFSD introduce async copy feature
Date: Mon, 9 Jul 2018 15:26:34 -0400
Message-ID: <20180709192638.44799-6-kolga@netapp.com>
In-Reply-To: <20180709192638.44799-1-kolga@netapp.com>
References: <20180709192638.44799-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <olga.kornievskaia@gmail.com>

Upon receiving a request for async copy, create a new kthread.
If we get asynchronous request, make sure to copy the needed
arguments/state from the stack before starting the copy. Then
start the thread and reply back to the client indicating copy
is asynchronous.

nfsd_copy_file_range() will copy in a loop over the total
number of bytes is needed to copy. In case a failure happens
in the middle, we ignore the error and return how much we
copied so far. Once done creating a workitem for the callback
workqueue and send CB_OFFLOAD with the results.

In the following patches the unique stateid will be generated
for the async COPY to return, at that point will enable the
async feature.

Async copy feature is turned on by an nfsd module parameter
async_copy_offload_enable.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 161 ++++++++++++++++++++++++++++++++++++++++++++++------
 fs/nfsd/nfs4state.c |   2 +
 fs/nfsd/nfssvc.c    |   6 ++
 fs/nfsd/state.h     |   2 +
 fs/nfsd/xdr4.h      |   9 +++
 5 files changed, 163 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 07ff6d0..9fb7bff 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -36,6 +36,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/slab.h>
+#include <linux/kthread.h>
 
 #include "idmap.h"
 #include "cache.h"
@@ -1099,38 +1100,164 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
+{
+	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
+
+	kfree(copy);
+}
+
+static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
+				 struct rpc_task *task)
+{
+	return 1;
+}
+
+static const struct nfsd4_callback_ops nfsd4_cb_offload_ops = {
+	.release = nfsd4_cb_offload_release,
+	.done = nfsd4_cb_offload_done
+};
+
+static __be32 nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
+{
+	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
+		sizeof(copy->cp_dst_stateid));
+	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
+	copy->cp_synchronous = sync;
+	gen_boot_verifier(&copy->cp_res.wr_verifier, copy->cp_clp->net);
+
+	return nfs_ok;
+}
+
+static ssize_t _nfsd_copy_file_range(struct nfsd4_copy *copy)
+{
+	ssize_t bytes_copied = 0;
+	size_t bytes_total = copy->cp_count;
+	u64 src_pos = copy->cp_src_pos;
+	u64 dst_pos = copy->cp_dst_pos;
+
+	do {
+		bytes_copied = nfsd_copy_file_range(copy->file_src, src_pos,
+				copy->file_dst, dst_pos, bytes_total);
+		if (bytes_copied <= 0)
+			break;
+		bytes_total -= bytes_copied;
+		copy->cp_res.wr_bytes_written += bytes_copied;
+		src_pos += bytes_copied;
+		dst_pos += bytes_copied;
+	} while (bytes_total > 0 && !copy->cp_synchronous);
+	return bytes_copied;
+}
+
+static __be32 nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
+{
+	__be32 status;
+	ssize_t bytes;
+
+	bytes = _nfsd_copy_file_range(copy);
+	/* for async copy, we ignore the error, client can always retry
+	 * to get the error
+	 */
+	if (bytes < 0 && !copy->cp_res.wr_bytes_written)
+		status = nfserrno(bytes);
+	else
+		status = nfsd4_init_copy_res(copy, sync);
+
+	fput(copy->file_src);
+	fput(copy->file_dst);
+	return status;
+}
+
+static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
+{
+	dst->cp_src_pos = src->cp_src_pos;
+	dst->cp_dst_pos = src->cp_dst_pos;
+	dst->cp_count = src->cp_count;
+	dst->cp_synchronous = src->cp_synchronous;
+	memcpy(&dst->cp_res, &src->cp_res, sizeof(src->cp_res));
+	memcpy(&dst->fh, &src->fh, sizeof(src->fh));
+	dst->cp_clp = src->cp_clp;
+	dst->file_dst = get_file(src->file_dst);
+	dst->file_src = get_file(src->file_src);
+}
+
+static void cleanup_async_copy(struct nfsd4_copy *copy)
+{
+	fput(copy->file_dst);
+	fput(copy->file_src);
+	spin_lock(&copy->cp_clp->async_lock);
+	list_del(&copy->copies);
+	spin_unlock(&copy->cp_clp->async_lock);
+	kfree(copy);
+}
+
+static int nfsd4_do_async_copy(void *data)
+{
+	struct nfsd4_copy *copy = (struct nfsd4_copy *)data;
+	struct nfsd4_copy *cb_copy;
+
+	copy->nfserr = nfsd4_do_copy(copy, 0);
+	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
+	if (!cb_copy)
+		goto out;
+	memcpy(&cb_copy->cp_res, &copy->cp_res, sizeof(copy->cp_res));
+	cb_copy->cp_clp = copy->cp_clp;
+	cb_copy->nfserr = copy->nfserr;
+	memcpy(&cb_copy->fh, &copy->fh, sizeof(copy->fh));
+	nfsd4_init_cb(&cb_copy->cp_cb, cb_copy->cp_clp,
+			&nfsd4_cb_offload_ops, NFSPROC4_CLNT_CB_OFFLOAD);
+	nfsd4_run_cb(&cb_copy->cp_cb);
+out:
+	cleanup_async_copy(copy);
+	return 0;
+}
 
 static __be32
 nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
 {
 	struct nfsd4_copy *copy = &u->copy;
-	struct file *src, *dst;
 	__be32 status;
-	ssize_t bytes;
+	struct nfsd4_copy *async_copy = NULL;
 
-	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
-				   &copy->cp_dst_stateid, &dst);
+	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
+				   &copy->file_src, &copy->cp_dst_stateid,
+				   &copy->file_dst);
 	if (status)
 		goto out;
 
-	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
-			dst, copy->cp_dst_pos, copy->cp_count);
-
-	if (bytes < 0)
-		status = nfserrno(bytes);
-	else {
-		copy->cp_res.wr_bytes_written = bytes;
-		copy->cp_res.wr_stable_how = NFS_UNSTABLE;
-		copy->cp_synchronous = 1;
-		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
+	copy->cp_clp = cstate->clp;
+	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
+		sizeof(struct knfsd_fh));
+	/* for now disable asynchronous copy feature */
+	copy->cp_synchronous = 1;
+	if (!copy->cp_synchronous && async_copy_offload_enable) {
+		status = nfserrno(-ENOMEM);
+		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
+		if (!async_copy)
+			goto out;
+		dup_copy_fields(copy, async_copy);
+		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
+			sizeof(copy->cp_dst_stateid));
+		async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
+				async_copy, "%s", "copy thread");
+		if (IS_ERR(async_copy->copy_task))
+			goto out_err;
+		spin_lock(&async_copy->cp_clp->async_lock);
+		list_add(&async_copy->copies,
+				&async_copy->cp_clp->async_copies);
+		spin_unlock(&async_copy->cp_clp->async_lock);
+		wake_up_process(async_copy->copy_task);
 		status = nfs_ok;
+	} else {
+		copy->cp_synchronous = 1;
+		status = nfsd4_do_copy(copy, 1);
 	}
-
-	fput(src);
-	fput(dst);
 out:
 	return status;
+out_err:
+	cleanup_async_copy(async_copy);
+	goto out;
 }
 
 static __be32
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8571414..64ecdde 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1827,6 +1827,8 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 #ifdef CONFIG_NFSD_PNFS
 	INIT_LIST_HEAD(&clp->cl_lo_states);
 #endif
+	INIT_LIST_HEAD(&clp->async_copies);
+	spin_lock_init(&clp->async_lock);
 	spin_lock_init(&clp->cl_lock);
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	return clp;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 89cb484..efb9545 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -30,6 +30,12 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
+bool async_copy_offload_enable;
+EXPORT_SYMBOL_GPL(async_copy_offload_enable);
+module_param(async_copy_offload_enable, bool, 0644);
+MODULE_PARM_DESC(async_copy_offload_enable,
+		 "Enable asynch copy offload. Default: false");
+
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5c16d35..491030e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -355,6 +355,8 @@ struct nfs4_client {
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
 	struct net		*net;
+	struct list_head	async_copies;	/* list of async copies */
+	spinlock_t		async_lock;	/* lock for async copies */
 };
 
 /* struct nfs4_client_reset
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 06cf218..ca5e868 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -532,7 +532,16 @@ struct nfsd4_copy {
 	struct nfsd4_callback	cp_cb;
 	__be32			nfserr;
 	struct knfsd_fh		fh;
+
+	struct nfs4_client      *cp_clp;
+
+	struct file             *file_src;
+	struct file             *file_dst;
+
+	struct list_head	copies;
+	struct task_struct	*copy_task;
 };
+extern bool async_copy_offload_enable;
 
 struct nfsd4_seek {
 	/* request */
-- 
1.8.3.1

