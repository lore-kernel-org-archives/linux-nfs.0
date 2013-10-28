Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43799 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328Ab3J1PAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 11:00:45 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Date: Mon, 28 Oct 2013 11:00:17 -0400
Message-ID: <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clients are required to support CB_OFFLOAD for the NFS4_CONTENT_HOLE arm
of the WRITE_PLUS union.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfs/callback.h      | 13 ++++++++++++
 fs/nfs/callback_proc.c |  8 ++++++++
 fs/nfs/callback_xdr.c  | 54 +++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4_fs.h       |  3 +++
 fs/nfs/nfs4file.c      | 54 +++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4xdr.c       |  2 +-
 6 files changed, 129 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..1653958 100644
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
+	struct nfs42_write_res		write_res;
+};
+
+extern __be32 nfs4_callback_offload(struct cb_offloadargs *, void *,
+				    struct cb_process_state *);
+int nfs_wake_offload(struct cb_offloadargs *);
+#endif /* CONFIG_NFS_V4_2 */
+
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_getattrres *res,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ae2e87b..8ff6400 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -536,3 +536,11 @@ out:
 	return status;
 }
 #endif /* CONFIG_NFS_V4_1 */
+
+#ifdef CONFIG_NFS_V4_2
+__be32 nfs4_callback_offload(struct cb_offloadargs *args, void *dummy,
+			     struct cb_process_state *cps)
+{
+	return htonl(nfs_wake_offload(args));
+}
+#endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f4ccfe6..843e074 100644
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
+				      struct nfs42_write_res *write_res)
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
index 1557f15..f52fc5f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -464,6 +464,9 @@ static inline void nfs4_unregister_sysctl(void)
 
 /* nfs4xdr.c */
 extern struct rpc_procinfo nfs4_procedures[];
+#if defined(CONFIG_NFS_V4_2)
+int decode_write_response(struct xdr_stream *, struct nfs42_write_res *);
+#endif /* CONFIG_NFS_V4_2 */
 
 struct nfs4_mount_data;
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index ab2fbe0..caf0658 100644
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
@@ -119,6 +120,50 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 }
 
 #ifdef CONFIG_NFS_V4_2
+static LIST_HEAD(nfs_offload_waitlist);
+static DEFINE_SPINLOCK(nfs_offload_lock);
+
+static unsigned int nfs_wait_for_offload(struct nfs42_write_res *res)
+{
+	spin_lock(&nfs_offload_lock);
+	list_add(&res->wait_list, &nfs_offload_waitlist);
+	spin_unlock(&nfs_offload_lock);
+
+	wait_for_completion(&res->completion);
+
+	spin_lock(&nfs_offload_lock);
+	list_del(&res->wait_list);
+	spin_unlock(&nfs_offload_lock);
+
+	return res->wr_status;
+}
+
+static struct nfs42_write_res *nfs_find_waiting_offload(nfs4_stateid *stateid)
+{
+	struct nfs42_write_res *cur;
+
+	list_for_each_entry(cur, &nfs_offload_waitlist, wait_list) {
+		if (memcmp(stateid, &cur->wr_stateid, sizeof(nfs4_stateid)) == 0)
+			return cur;
+	}
+	return NULL;
+}
+
+int nfs_wake_offload(struct cb_offloadargs *offload)
+{
+	struct nfs42_write_res *write;
+
+	spin_lock(&nfs_offload_lock);
+	write = nfs_find_waiting_offload(&offload->stateid);
+	spin_unlock(&nfs_offload_lock);
+	if (write == NULL)
+		return NFS4ERR_BAD_STATEID;
+
+	write->wr_bytes_copied = offload->write_res.wr_bytes_copied;
+	complete(&write->completion);
+	return NFS4_OK;
+}
+
 static int nfs42_select_stateid(struct file *file, nfs4_stateid *stateid,
 				fmode_t mode, struct nfs_open_context **ctx)
 {
@@ -164,7 +209,14 @@ static long nfs42_fallocate(struct file *file, int mode, loff_t offset, loff_t l
 	if (err < 0)
 		return err;
 
-	return nfs42_proc_fallocate(server, &args, &res, ctx->cred);
+	init_completion(&res.completion);
+	err = nfs42_proc_fallocate(server, &args, &res, ctx->cred);
+	if (err)
+		return err;
+
+	if (res.wr_async == true)
+		err = nfs_wait_for_offload(&res);
+	return err;
 }
 #endif /* CONFIG_NFS_V4_2 */
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4ffecbe..28e2fad 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6041,7 +6041,7 @@ static int decode_free_stateid(struct xdr_stream *xdr,
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_V4_2
-static int decode_write_response(struct xdr_stream *xdr,
+int decode_write_response(struct xdr_stream *xdr,
 				 struct nfs42_write_res *write_res)
 {
 	__be32 *p;
-- 
1.8.4.1

