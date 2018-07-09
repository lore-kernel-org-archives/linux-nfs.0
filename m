Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:35214 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933283AbeGIT0d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:26:33 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 7/9] NFSD handle OFFLOAD_CANCEL op
Date: Mon, 9 Jul 2018 15:26:36 -0400
Message-ID: <20180709192638.44799-8-kolga@netapp.com>
In-Reply-To: <20180709192638.44799-1-kolga@netapp.com>
References: <20180709192638.44799-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <olga.kornievskaia@gmail.com>

Upon receiving OFFLOAD_CANCEL search the list of copy stateids,
if found then set the SIGPENDING signal so that do_splice stops
copying and also send kthread_stop to the copy thread to stop
and wait for it. Take a reference on the copy from the
offload_cancel thread so that it won't go away while we are
trying to process it.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 40 +++++++++++++++++++++++++++++++++++++---
 fs/nfsd/state.h    |  1 +
 fs/nfsd/xdr4.h     |  1 +
 3 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e805e29..7247fb0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1100,11 +1100,19 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+
+void nfs4_put_copy(struct nfsd4_copy *copy)
+{
+	if (!refcount_dec_and_test(&copy->refcount))
+		return;
+	kfree(copy);
+}
+
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
 {
 	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
 
-	kfree(copy);
+	nfs4_put_copy(copy);
 }
 
 static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
@@ -1135,6 +1143,8 @@ static ssize_t _nfsd_copy_file_range(struct nfsd4_copy *copy)
 	u64 dst_pos = copy->cp_dst_pos;
 
 	do {
+		if (signalled() || kthread_should_stop())
+			break;
 		bytes_copied = nfsd_copy_file_range(copy->file_src, src_pos,
 				copy->file_dst, dst_pos, bytes_total);
 		if (bytes_copied <= 0)
@@ -1188,7 +1198,7 @@ static void cleanup_async_copy(struct nfsd4_copy *copy)
 	spin_lock(&copy->cp_clp->async_lock);
 	list_del(&copy->copies);
 	spin_unlock(&copy->cp_clp->async_lock);
-	kfree(copy);
+	nfs4_put_copy(copy);
 }
 
 static int nfsd4_do_async_copy(void *data)
@@ -1238,6 +1248,7 @@ static int nfsd4_do_async_copy(void *data)
 			goto out;
 		if (!nfs4_init_cp_state(nn, copy))
 			goto out;
+		refcount_set(&async_copy->refcount, 1);
 		memcpy(&copy->cp_res.cb_stateid, &copy->cp_stateid,
 			sizeof(copy->cp_stateid));
 		dup_copy_fields(copy, async_copy);
@@ -1267,7 +1278,30 @@ static int nfsd4_do_async_copy(void *data)
 		     struct nfsd4_compound_state *cstate,
 		     union nfsd4_op_u *u)
 {
-	return 0;
+	struct nfsd4_offload_status *os = &u->offload_status;
+	__be32 status = 0;
+	struct nfsd4_copy *copy;
+	bool found = false;
+	struct nfs4_client *clp = cstate->clp;
+
+	spin_lock(&clp->async_lock);
+	list_for_each_entry(copy, &clp->async_copies, copies) {
+		if (memcmp(&copy->cp_stateid, &os->stateid,
+				NFS4_STATEID_SIZE))
+			continue;
+		found = true;
+		refcount_inc(&copy->refcount);
+		break;
+	}
+	spin_unlock(&clp->async_lock);
+	if (found) {
+		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
+		kthread_stop(copy->copy_task);
+		nfs4_put_copy(copy);
+	} else
+		status = nfserr_bad_stateid;
+
+	return status;
 }
 
 static __be32
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d8893427..0ee2ed3 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -641,6 +641,7 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 
 struct nfs4_file *find_file(struct knfsd_fh *fh);
 void put_nfs4_file(struct nfs4_file *fi);
+extern void nfs4_put_copy(struct nfsd4_copy *copy);
 static inline void get_nfs4_file(struct nfs4_file *fi)
 {
 	refcount_inc(&fi->fi_ref);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 7ff6ff8..beb048d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -542,6 +542,7 @@ struct nfsd4_copy {
 
 	struct list_head	copies;
 	struct task_struct	*copy_task;
+	refcount_t		refcount;
 };
 extern bool async_copy_offload_enable;
 
-- 
1.8.3.1

