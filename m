Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10414 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab3GSVD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:03:57 -0400
From: <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC 5/5] NFS: Change copy to support async servers
Date: Fri, 19 Jul 2013 17:03:50 -0400
Message-ID: <1374267830-30154-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Supporting CB_OFFLOAD is required by the spec, so if a server chooses to
copy in the background we have to wait for the copy to finish before
returning to userspace.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/callback.h       | 13 ++++++++++++
 fs/nfs/callback_proc.c  |  9 +++++++++
 fs/nfs/callback_xdr.c   | 54 ++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4_fs.h        |  3 +++
 fs/nfs/nfs4file.c       | 48 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c        |  4 ++--
 include/linux/nfs_xdr.h |  3 +++
 7 files changed, 129 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..ae5a5d2 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -187,6 +187,19 @@ extern __be32 nfs4_callback_devicenotify(
 	void *dummy, struct cb_process_state *cps);
 
 #endif /* CONFIG_NFS_V4_1 */
+
+#ifdef CONFIG_NFS_V4_2
+struct cb_offloadargs {
+	struct nfs_fh			dst_fh;
+	nfs4_stateid			stateid;
+	struct nfs42_write_response	write_res;
+};
+
+extern __be32 nfs4_callback_offload(struct cb_offloadargs *, void *,
+				    struct cb_process_state *);
+void wake_copy_offload(struct cb_offloadargs *);
+#endif /* CONFIG_NFS_V4_2 */
+
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_getattrres *res,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e6ebc4c..cdf4180 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -533,3 +533,12 @@ out:
 	return status;
 }
 #endif /* CONFIG_NFS_V4_1 */
+
+#ifdef CONFIG_NFS_V4_2
+__be32 nfs4_callback_offload(struct cb_offloadargs *args, void *dummy,
+			     struct cb_process_state *cps)
+{
+	wake_copy_offload(args);
+	return htonl(NFS4_OK);
+}
+#endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f4ccfe6..d8fcf1a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -35,6 +35,14 @@
 #define CB_OP_RECALLSLOT_RES_MAXSZ	(CB_OP_HDR_RES_MAXSZ)
 #endif /* CONFIG_NFS_V4_1 */
 
+#if defined(CONFIG_NFS_V4_2)
+#define CB_OP_OFFLOAD_RES_MAXSZ		(CB_OP_HDR_RES_MAXSZ + \
+					 1 + XDR_QUADLEN(NFS4_FHSIZE) + \
+					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 1 + XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+					 2 + 1 + XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#endif /* CONFIG_NFS_V4_2 */
+
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
 
 /* Internal error code */
@@ -527,6 +535,37 @@ static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#ifdef CONFIG_NFS_V4_2
+static inline __be32 decode_write_res(struct xdr_stream *xdr,
+				      struct nfs42_write_response *write_res)
+{
+	__be32 status = decode_write_response(xdr, write_res);
+	if (status == -EIO)
+		return htonl(NFS4ERR_RESOURCE);
+	return htonl(status);
+}
+
+static __be32 decode_offload_args(struct svc_rqst *rqstp,
+				  struct xdr_stream *xdr,
+				  struct cb_offloadargs *args)
+{
+	__be32 status;
+
+	status = decode_fh(xdr, &args->dst_fh);
+	if (unlikely(status != 0))
+		goto out;
+
+	status = decode_stateid(xdr, &args->stateid);
+	if (unlikely(status != 0))
+		goto out;
+
+	status = decode_write_res(xdr, &args->write_res);
+out:
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
+	return status;
+}
+#endif /* CONFIG_NFS_V4_2 */
+
 static __be32 encode_string(struct xdr_stream *xdr, unsigned int len, const char *str)
 {
 	__be32 *p;
@@ -794,9 +833,11 @@ preprocess_nfs42_op(int nop, unsigned int op_nr, struct callback_op **op)
 	if (status != htonl(NFS4ERR_OP_ILLEGAL))
 		return status;
 
-	if (op_nr == OP_CB_OFFLOAD)
-		return htonl(NFS4ERR_NOTSUPP);
-	return htonl(NFS4ERR_OP_ILLEGAL);
+	if (op_nr != OP_CB_OFFLOAD)
+		return htonl(NFS4ERR_OP_ILLEGAL);
+
+	*op = &callback_ops[op_nr];
+	return htonl(NFS4_OK);
 }
 #else /* CONFIG_NFS_V4_2 */
 static __be32
@@ -991,6 +1032,13 @@ static struct callback_op callback_ops[] = {
 		.res_maxsize = CB_OP_RECALLSLOT_RES_MAXSZ,
 	},
 #endif /* CONFIG_NFS_V4_1 */
+#if defined(CONFIG_NFS_V4_2)
+	[OP_CB_OFFLOAD] = {
+		.process_op = (callback_process_op_t)nfs4_callback_offload,
+		.decode_args = (callback_decode_arg_t)decode_offload_args,
+		.res_maxsize = CB_OP_OFFLOAD_RES_MAXSZ,
+	},
+#endif
 };
 
 /*
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 26c7cf0..5c32fb5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -407,6 +407,9 @@ static inline void nfs4_unregister_sysctl(void)
 
 /* nfs4xdr.c */
 extern struct rpc_procinfo nfs4_procedures[];
+#if defined(CONFIG_NFS_V4_2)
+int decode_write_response(struct xdr_stream *, struct nfs42_write_response *);
+#endif /* CONFIG_NFS_V4_2 */
 
 struct nfs4_mount_data;
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index ca77ab4..fbd5f77 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -4,6 +4,7 @@
  *  Copyright (C) 1992  Rick Sladkey
  */
 #include <linux/nfs_fs.h>
+#include "callback.h"
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
@@ -118,6 +119,9 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 }
 
 #ifdef CONFIG_NFS_V4_2
+static LIST_HEAD(nfs_copy_async_list);
+static DEFINE_SPINLOCK(async_copy_lock);
+
 static int nfs4_find_copy_stateid(struct file *file, nfs4_stateid *stateid,
 				  fmode_t mode)
 {
@@ -137,6 +141,43 @@ static int nfs4_find_copy_stateid(struct file *file, nfs4_stateid *stateid,
 	return ret;
 }
 
+static void wait_for_offload(struct nfs42_copy_res *res)
+{
+	spin_lock(&async_copy_lock);
+	list_add(&res->wait_list, &nfs_copy_async_list);
+	spin_unlock(&async_copy_lock);
+
+	wait_for_completion(&res->completion);
+}
+
+static struct nfs42_copy_res *find_async_copy(nfs4_stateid *stateid)
+{
+	struct nfs42_copy_res *cur;
+
+	list_for_each_entry(cur, &nfs_copy_async_list, wait_list) {
+		if (memcmp(stateid, cur->cp_res.wr_stateid, sizeof(nfs4_stateid)) == 0)
+			return cur;
+	}
+	return NULL;
+}
+
+void wake_copy_offload(struct cb_offloadargs *offload)
+{
+	struct nfs42_copy_res *copy;
+
+	spin_lock(&async_copy_lock);
+	copy = find_async_copy(&offload->stateid);
+	if (copy == NULL) {
+		spin_unlock(&async_copy_lock);
+		return;
+	}
+	list_del(&copy->wait_list);
+	spin_unlock(&async_copy_lock);
+
+	copy->cp_res.wr_bytes_copied = offload->write_res.wr_bytes_copied;
+	complete(&copy->completion);
+}
+
 static ssize_t nfs4_copy_range(struct file *file_in, loff_t pos_in,
 			       struct file *file_out, loff_t pos_out,
 			       size_t count)
@@ -159,10 +200,17 @@ static ssize_t nfs4_copy_range(struct file *file_in, loff_t pos_in,
 	if (err)
 		return err;
 
+	init_completion(&res.completion);
+
 	err = nfs42_proc_copy(NFS_SERVER(file_inode(file_out)), &args, &res);
 	if (err)
 		return err;
 
+	if (res.cp_res.wr_stateid != NULL) {
+		wait_for_offload(&res);
+		kfree(res.cp_res.wr_stateid);
+	}
+
 	return res.cp_res.wr_bytes_copied;
 }
 #endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d70c6bc..465d1bc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6011,8 +6011,8 @@ out_overflow:
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
-static int decode_write_response(struct xdr_stream *xdr,
-				 struct nfs42_write_response *write_res)
+int decode_write_response(struct xdr_stream *xdr,
+			  struct nfs42_write_response *write_res)
 {
 	__be32 *p;
 	int num_ids;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0bc6b14..f603793 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1231,6 +1231,9 @@ struct nfs42_copy_res {
 	struct nfs4_sequence_res	seq_res;
 	unsigned int			status;
 	struct nfs42_write_response	cp_res;
+
+	struct list_head		wait_list;
+	struct completion		completion;
 };
 #endif
 
-- 
1.8.3.3

