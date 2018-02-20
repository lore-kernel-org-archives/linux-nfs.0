Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:20680 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752812AbeBTQwU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 11:52:20 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v7 08/10] NFSD handle OFFLOAD_CANCEL op
Date: Tue, 20 Feb 2018 11:42:27 -0500
Message-ID: <20180220164229.65404-9-kolga@netapp.com>
In-Reply-To: <20180220164229.65404-1-kolga@netapp.com>
References: <20180220164229.65404-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upon receiving OFFLOAD_CANCEL search the list of copy stateids,
if found then set the SIGPENDING signal so that do_splice stops
copying and also send kthread_stop to the copy thread to stop
and wait for it. Take a reference on the copy from the
offload_cancel thread so that it won't go away while we are
trying to process it. Server won't be sending CB_OFFLOAD to the
client since it received a cancel.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h     |  1 +
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index eb9f528..3d190b3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1088,6 +1088,14 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+
+static void nfs4_put_copy(struct nfsd4_copy *copy)
+{
+	if (!refcount_dec_and_test(&copy->refcount))
+		return;
+	kfree(copy);
+}
+
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
 {
 	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
@@ -1125,6 +1133,8 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
 	u64 dst_pos = copy->cp_dst_pos;
 
 	do {
+		if (signalled() || kthread_should_stop())
+			return -1;
 		bytes_copied = nfsd_copy_file_range(copy->fh_src, src_pos,
 				copy->fh_dst, dst_pos, bytes_total);
 		if (bytes_copied <= 0)
@@ -1143,11 +1153,16 @@ static int nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
 	ssize_t bytes;
 
 	bytes = _nfsd_copy_file_range(copy);
+	if (signalled() || kthread_should_stop()) {
+		status = -1;
+		goto cleanup;
+	}
 	if (bytes < 0 && !copy->cp_res.wr_bytes_written)
 		status = nfserrno(bytes);
 	else
 		status = nfsd4_init_copy_res(copy, sync);
 
+cleanup:
 	fput(copy->fh_src);
 	fput(copy->fh_dst);
 	return status;
@@ -1187,7 +1202,7 @@ static void cleanup_async_copy(struct nfsd4_copy *copy, bool remove)
 		spin_unlock(&copy->cp_clp->async_lock);
 	}
 	atomic_dec(&copy->cp_clp->cl_refcount);
-	kfree(copy);
+	nfs4_put_copy(copy);
 }
 
 static int nfsd4_do_async_copy(void *data)
@@ -1196,6 +1211,9 @@ static int nfsd4_do_async_copy(void *data)
 	struct nfsd4_copy *cb_copy;
 
 	copy->nfserr = nfsd4_do_copy(copy, 0);
+	if (signalled() || kthread_should_stop())
+		goto out;
+
 	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 	if (!cb_copy)
 		goto out;
@@ -1278,7 +1296,30 @@ static int nfsd4_do_async_copy(void *data)
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
+		if (memcmp(&copy->cps->cp_stateid, &os->stateid,
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
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 5d493b9..47bfe64 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -540,6 +540,7 @@ struct nfsd4_copy {
 
 	struct list_head	copies;
 	struct task_struct	*copy_task;
+	refcount_t		refcount;
 };
 
 struct nfsd4_seek {
-- 
1.8.3.1

