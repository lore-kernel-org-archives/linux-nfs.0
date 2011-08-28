Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58827 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751713Ab1H1KPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Aug 2011 06:15:06 -0400
Message-ID: <4E5A1610.3030304@cn.fujitsu.com>
Date: Sun, 28 Aug 2011 18:18:56 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH v3] nfsd41: try to check reply size before operation
References: <4E0C31B5.9090302@cn.fujitsu.com> <20110706201920.GA32275@fieldses.org> <4E4F8853.8080607@cn.fujitsu.com> <20110823213916.GB25350@fieldses.org> <4E54BF6B.4020803@cn.fujitsu.com>
In-Reply-To: <4E54BF6B.4020803@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For checking the size of reply before calling a operation, 
we need try to get maxsize of the operation's reply.

v3: using new method as Bruce said,
 
 "we could handle operations in two different ways:

	- For operations that actually change something (write, rename,
	  open, close, ...), do it the way we're doing it now: be
	  very careful to estimate the size of the response before even
	  processing the operation.
	- For operations that don't change anything (read, getattr, ...)
	  just go ahead and do the operation.  If you realize after the
	  fact that the response is too large, then return the error at
	  that point.

  So we'd add another flag to op_flags: say, OP_MODIFIES_SOMETHING.  And for
  operations with OP_MODIFIES_SOMETHING set, we'd do the first thing.  For
  operations without it set, we'd do the second."
    
Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4proc.c |  250 ++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4xdr.c  |   37 ++++----
 fs/nfsd/xdr4.h     |    1 +
 3 files changed, 251 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e807776..9551e9a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -35,6 +35,7 @@
 #include <linux/file.h>
 #include <linux/slab.h>
 
+#include "idmap.h"
 #include "cache.h"
 #include "xdr4.h"
 #include "vfs.h"
@@ -994,6 +995,8 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
+typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
+
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
 	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
@@ -1001,6 +1004,7 @@ enum nfsd4_op_flags {
 	/* For rfc 5661 section 2.6.3.1.1: */
 	OP_HANDLES_WRONGSEC = 1 << 3,
 	OP_IS_PUTFH_LIKE = 1 << 4,
+	OP_MODIFIES_SOMETHING = 1 << 5, /* ops is non-idempotent */
 };
 
 struct nfsd4_operation {
@@ -1016,6 +1020,8 @@ struct nfsd4_operation {
 	 * the v4.0 case).
 	 */
 	bool op_cacheresult;
+	/* Try to get response size before operation */
+	nfsd4op_rsize op_rsize_bop;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -1110,6 +1116,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	struct nfsd4_operation *opdesc;
 	struct nfsd4_compound_state *cstate = &resp->cstate;
 	int		slack_bytes;
+	u32		plen = 0;
 	__be32		status;
 
 	resp->xbuf = &rqstp->rq_res;
@@ -1188,6 +1195,18 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			goto encode_op;
 		}
 
+		/* If ops is non-idempotent */
+		if (opdesc->op_flags & OP_MODIFIES_SOMETHING) {
+			if (opdesc->op_rsize_bop) {
+				plen = opdesc->op_rsize_bop(rqstp, op);
+				op->status = nfsd4_check_resp_size(resp, plen);
+			} else
+				op->status = nfserr_serverfault;
+		}
+
+		if (op->status)
+			goto encode_op;
+
 		if (opdesc->op_func)
 			op->status = opdesc->op_func(rqstp, cstate, &op->u);
 		else
@@ -1238,6 +1257,144 @@ out:
 	return status;
 }
 
+#define op_encode_hdr_size		(2)
+#define op_encode_stateid_maxsz		(XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define op_encode_verifier_maxsz	(XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#define op_encode_change_info_maxsz	(5)
+#define nfs4_fattr_bitmap_maxsz		(4)
+
+#define op_encode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define op_encode_lock_denied_maxsz	(8 + op_encode_lockowner_maxsz)
+
+#define nfs4_owner_maxsz		(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+
+#define op_encode_ace_maxsz		(3 + nfs4_owner_maxsz)
+#define op_encode_delegation_maxsz	(1 + op_encode_stateid_maxsz + 1 + \
+					 op_encode_ace_maxsz)
+
+#define op_encode_channel_attrs_maxsz	(6 + 1 + 1)
+
+static inline u32 nfsd4_only_status_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_status_stateid_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_stateid_maxsz)* sizeof(__be32);
+}
+
+static inline u32 nfsd4_commit_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_verifier_maxsz) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_create_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_change_info_maxsz
+		+ nfs4_fattr_bitmap_maxsz) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_link_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_change_info_maxsz)
+		* sizeof(__be32);
+}
+
+static inline u32 nfsd4_lock_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_lock_denied_maxsz)
+		* sizeof(__be32);
+}
+
+static inline u32 nfsd4_open_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_stateid_maxsz
+		+ op_encode_change_info_maxsz + 1 
+		+ nfs4_fattr_bitmap_maxsz
+		+ op_encode_delegation_maxsz) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_read_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	u32 maxcount = 0, rlen = 0;
+
+	maxcount = svc_max_payload(rqstp);
+	rlen = op->u.read.rd_length;
+
+	if (rlen > maxcount)
+		rlen = maxcount;
+
+	return (op_encode_hdr_size + 2) * sizeof(__be32) + rlen;
+}
+
+static inline u32 nfsd4_readdir_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	u32 rlen = op->u.readdir.rd_maxcount;
+
+	if (rlen > PAGE_SIZE)
+		rlen = PAGE_SIZE;
+
+	return (op_encode_hdr_size + op_encode_verifier_maxsz)
+		 * sizeof(__be32) + rlen;
+}
+
+static inline u32 nfsd4_remove_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_change_info_maxsz)
+		* sizeof(__be32);
+}
+
+static inline u32 nfsd4_rename_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_change_info_maxsz
+		+ op_encode_change_info_maxsz) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_setattr_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + nfs4_fattr_bitmap_maxsz) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_setclientid_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + 2 + 1024) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_write_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_verifier_maxsz) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_exchange_id_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + 2 + 1 + /* eir_clientid, eir_sequenceid */\
+		1 + 1 + 0 + /* eir_flags, spr_how, SP4_NONE (for now) */\
+		2 + /*eir_server_owner.so_minor_id */\
+		/* eir_server_owner.so_major_id<> */\
+		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 +\
+		/* eir_server_scope<> */\
+		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 +\
+		1 + /* eir_server_impl_id array length */\
+		0 /* ignored eir_server_impl_id contents */) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_bind_conn_to_session_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + \
+		XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + /* bctsr_sessid */\
+		2 /* bctsr_dir, use_conn_in_rdma_mode */) * sizeof(__be32);
+}
+
+static inline u32 nfsd4_create_session_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + \
+		XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + /* sessionid */\
+		2 + /* csr_sequence, csr_flags */\
+		op_encode_channel_attrs_maxsz + \
+		op_encode_channel_attrs_maxsz) * sizeof(__be32);
+}
+
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
@@ -1245,20 +1402,28 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_CLOSE] = {
 		.op_func = (nfsd4op_func)nfsd4_close,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLOSE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 	},
 	[OP_COMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_COMMIT",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_commit_rsize,
 	},
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CREATE",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_rsize,
 	},
 	[OP_DELEGRETURN] = {
 		.op_func = (nfsd4op_func)nfsd4_delegreturn,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DELEGRETURN",
+		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_GETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_getattr,
@@ -1271,12 +1436,16 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LINK] = {
 		.op_func = (nfsd4op_func)nfsd4_link,
+		.op_flags = ALLOWED_ON_ABSENT_FS | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LINK",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_link_rsize,
 	},
 	[OP_LOCK] = {
 		.op_func = (nfsd4op_func)nfsd4_lock,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCK",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
 	},
 	[OP_LOCKT] = {
 		.op_func = (nfsd4op_func)nfsd4_lockt,
@@ -1284,7 +1453,9 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCKU] = {
 		.op_func = (nfsd4op_func)nfsd4_locku,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_LOCKU",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
@@ -1302,42 +1473,54 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_OPEN] = {
 		.op_func = (nfsd4op_func)nfsd4_open,
-		.op_flags = OP_HANDLES_WRONGSEC,
+		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_CONFIRM",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 	},
 	[OP_OPEN_DOWNGRADE] = {
 		.op_func = (nfsd4op_func)nfsd4_open_downgrade,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN_DOWNGRADE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
 	},
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_PUTFH",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_PUTPUBFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_PUTPUBFH",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_PUTROOTFH",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_READ] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_READ",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_read_rsize,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_READDIR",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_readdir_rsize,
 	},
 	[OP_READLINK] = {
 		.op_func = (nfsd4op_func)nfsd4_readlink,
@@ -1345,29 +1528,38 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_REMOVE] = {
 		.op_func = (nfsd4op_func)nfsd4_remove,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_REMOVE",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_remove_rsize,
 	},
 	[OP_RENAME] = {
-		.op_name = "OP_RENAME",
 		.op_func = (nfsd4op_func)nfsd4_rename,
+		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_name = "OP_RENAME",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_rename_rsize,
 	},
 	[OP_RENEW] = {
 		.op_func = (nfsd4op_func)nfsd4_renew,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RENEW",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+
 	},
 	[OP_RESTOREFH] = {
 		.op_func = (nfsd4op_func)nfsd4_restorefh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
-				| OP_IS_PUTFH_LIKE,
+				| OP_IS_PUTFH_LIKE | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RESTOREFH",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_SAVEFH] = {
 		.op_func = (nfsd4op_func)nfsd4_savefh,
-		.op_flags = OP_HANDLES_WRONGSEC,
+		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_SAVEFH",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_SECINFO] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo,
@@ -1377,19 +1569,25 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_SETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_setattr,
 		.op_name = "OP_SETATTR",
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setattr_rsize,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_SETCLIENTID",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_setclientid_rsize,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_SETCLIENTID_CONFIRM",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_VERIFY] = {
 		.op_func = (nfsd4op_func)nfsd4_verify,
@@ -1397,35 +1595,47 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_WRITE] = {
 		.op_func = (nfsd4op_func)nfsd4_write,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_WRITE",
 		.op_cacheresult = true,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RELEASE_LOCKOWNER",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 
 	/* NFSv4.1 operations */
 	[OP_EXCHANGE_ID] = {
 		.op_func = (nfsd4op_func)nfsd4_exchange_id,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_EXCHANGE_ID",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_exchange_id_rsize,
 	},
 	[OP_BIND_CONN_TO_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_bind_conn_to_session,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_BIND_CONN_TO_SESSION",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_bind_conn_to_session_rsize,
 	},
 	[OP_CREATE_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_create_session,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CREATE_SESSION",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_create_session_rsize,
 	},
 	[OP_DESTROY_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_session,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DESTROY_SESSION",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_SEQUENCE] = {
 		.op_func = (nfsd4op_func)nfsd4_sequence,
@@ -1434,13 +1644,16 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_DESTROY_CLIENTID] = {
 		.op_func = NULL,
-		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
+				| OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DESTROY_CLIENTID",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_RECLAIM_COMPLETE] = {
 		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
-		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_RECLAIM_COMPLETE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
@@ -1454,8 +1667,9 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_FREE_STATEID] = {
 		.op_func = (nfsd4op_func)nfsd4_free_stateid,
-		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_FREE_STATEID",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
 };
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c8bf405..b7a3c69 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3334,34 +3334,29 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 
 /*
  * Calculate the total amount of memory that the compound response has taken
- * after encoding the current operation.
+ * after encoding the current operation with pad.
  *
- * pad: add on 8 bytes for the next operation's op_code and status so that
- * there is room to cache a failure on the next operation.
+ * pad: if operation is non-idempotent, pad was calculate by op_rsize_bop()
+ *      which was specified at nfsd4_operation, else pad is zero. 
  *
- * Compare this length to the session se_fmaxresp_cached.
+ * Compare this length to the session se_fmaxresp_sz and se_fmaxresp_cached.
  *
  * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
  * will be at least a page and will therefore hold the xdr_buf head.
  */
-static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
+int nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 {
-	int status = 0;
 	struct xdr_buf *xb = &resp->rqstp->rq_res;
-	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
 	struct nfsd4_session *session = NULL;
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	u32 length, tlen = 0, pad = 8;
+	u32 length, tlen = 0;
 
 	if (!nfsd4_has_session(&resp->cstate))
-		return status;
+		return 0;
 
 	session = resp->cstate.session;
-	if (session == NULL || slot->sl_cachethis == 0)
-		return status;
-
-	if (resp->opcnt >= args->opcnt)
-		pad = 0; /* this is the last operation */
+	if (session == NULL)
+		return 0;
 
 	if (xb->page_len == 0) {
 		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
@@ -3374,10 +3369,14 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
 		length, xb->page_len, tlen, pad);
 
-	if (length <= session->se_fchannel.maxresp_cached)
-		return status;
-	else
+	if (length > session->se_fchannel.maxresp_sz)
+		return nfserr_rep_too_big;
+
+	if (slot->sl_cachethis == 1 &&
+	    length > session->se_fchannel.maxresp_cached)
 		return nfserr_rep_too_big_to_cache;
+
+	return 0;
 }
 
 void
@@ -3397,8 +3396,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	       !nfsd4_enc_ops[op->opnum]);
 	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
 	/* nfsd4_check_drc_limit guarantees enough room for error status */
-	if (!op->status && nfsd4_check_drc_limit(resp))
-		op->status = nfserr_rep_too_big_to_cache;
+	if (!op->status)
+		op->status = nfsd4_check_resp_size(resp, 0);
 status:
 	/*
 	 * Note: We write the status directly, instead of using WRITE32(),
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index d2a8d044..6b5496b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -532,6 +532,7 @@ int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundargs *);
 int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundres *);
+int nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-- 
1.7.6



