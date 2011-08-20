Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60512 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab1HTKHV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Aug 2011 06:07:21 -0400
Message-ID: <4E4F8853.8080607@cn.fujitsu.com>
Date: Sat, 20 Aug 2011 18:11:31 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [RFC][PATCH v2] nfsd41: try to check reply size before operation
References: <4E0C31B5.9090302@cn.fujitsu.com> <20110706201920.GA32275@fieldses.org>
In-Reply-To: <20110706201920.GA32275@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For checking the size of reply before calling a operation, 
we need try to get maxsize of the operation's reply.

v1->v2:
    move op_enc_size from nfsd4_enc_ops to nfsd4_operation;
    add helper function to get payload len which is need as READ, READDIR ...
    
Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4proc.c |  345 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c  |   31 +++--
 fs/nfsd/xdr4.h     |    1 +
 3 files changed, 361 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e807776..3290bc0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -34,7 +34,9 @@
  */
 #include <linux/file.h>
 #include <linux/slab.h>
+#include <linux/sunrpc/svcauth_gss.h>
 
+#include "idmap.h"
 #include "cache.h"
 #include "xdr4.h"
 #include "vfs.h"
@@ -994,6 +996,8 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
 
 typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
 			      void *);
+typedef u32(*nfsd4op_payload)(struct svc_rqst *);
+
 enum nfsd4_op_flags {
 	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
 	ALLOWED_ON_ABSENT_FS = 1 << 1,	/* ops processed on absent fs */
@@ -1016,6 +1020,10 @@ struct nfsd4_operation {
 	 * the v4.0 case).
 	 */
 	bool op_cacheresult;
+	/* size except dynamic payload */
+	u32 op_enc_size;
+	/* try to get dynamic payload as READ, READDIR, READLINK, GETATTR */
+	nfsd4op_payload op_payload;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
@@ -1188,7 +1196,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			goto encode_op;
 		}
 
-		if (opdesc->op_func)
+		if (op->status == 0 && opdesc->op_func)
 			op->status = opdesc->op_func(rqstp, cstate, &op->u);
 		else
 			BUG_ON(op->status == nfs_ok);
@@ -1238,172 +1246,478 @@ out:
 	return status;
 }
 
+#define op_encode_hdr_size	(2)
+
+#define encode_stateid_maxsz	(XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define encode_verifier_maxsz	(XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+
+#define nfsd4_enc_access_sz	(op_encode_hdr_size + 2)
+#define nfsd4_enc_close_sz	(op_encode_hdr_size + encode_stateid_maxsz)
+#define nfsd4_enc_commit_sz	(op_encode_hdr_size + encode_verifier_maxsz)
+#define nfsd4_enc_create_sz	(op_encode_hdr_size + encode_stateid_maxsz)
+
+#define nfs4_owner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define nfs4_group_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define nfs4_fattr_bitmap_maxsz	(3)
+#define nfs4_fattr_value_maxsz	(1 + (1 + 2 + 2 + 4 + 2 + 1 + 1 + 2 + 2 + \
+				 3 + 3 + 3 + nfs4_owner_maxsz + \
+				 nfs4_group_maxsz))
+#define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
+				 nfs4_fattr_value_maxsz)
+#define nfsd4_enc_getattr_sz	(op_encode_hdr_size + nfs4_fattr_maxsz)
+#define nfsd4_enc_getfh_sz	(op_encode_hdr_size + 1 + \
+				 ((3+NFS4_FHSIZE) >> 2))
+
+#define encode_change_info_maxsz (5)
+#define nfsd4_enc_link_sz	(op_encode_hdr_size + encode_change_info_maxsz)
+
+#define encode_lockowner_maxsz  (1 + XDR_QUADLEN(IDMAP_NAMESZ))
+#define encode_lock_denied_maxsz \
+				(8 + encode_lockowner_maxsz)
+#define nfsd4_enc_lock_sz	(op_encode_hdr_size + encode_lock_denied_maxsz)
+#define nfsd4_enc_lockt_sz	(op_encode_hdr_size + encode_lock_denied_maxsz)
+#define nfsd4_enc_locku_sz	(op_encode_hdr_size + encode_stateid_maxsz)
+
+#define encode_ace_maxsz	(3 + nfs4_owner_maxsz)
+#define encode_delegation_maxsz	(1 + encode_stateid_maxsz + 1 + \
+				 encode_ace_maxsz)
+#define nfsd4_enc_open_sz	(op_encode_hdr_size + encode_stateid_maxsz + \
+				 encode_change_info_maxsz + 1 + \
+				 nfs4_fattr_bitmap_maxsz + \
+				 encode_delegation_maxsz)
+#define nfsd4_enc_open_confirm_sz \
+				(op_encode_hdr_size + encode_stateid_maxsz)
+#define nfsd4_enc_open_downgrade_sz \
+				(op_encode_hdr_size + encode_stateid_maxsz)
+#define nfsd4_enc_read_sz	(op_encode_hdr_size + 2)
+#define nfsd4_enc_readdir_sz	(op_encode_hdr_size + encode_verifier_maxsz)
+#define nfsd4_enc_readlink_sz	(op_encode_hdr_size + 1)
+#define nfsd4_enc_remove_sz	(op_encode_hdr_size + encode_change_info_maxsz)
+#define nfsd4_enc_rename_sz	(op_encode_hdr_size + \
+				 encode_change_info_maxsz + \
+				 encode_change_info_maxsz)
+
+#define NFS_MAX_SECFLAVORS	(12)
+#define nfsd4_enc_secinfo_sz	(op_encode_hdr_size + 4 + \
+				 (NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)))
+
+#define nfsd4_enc_setattr_sz	(op_encode_hdr_size + nfs4_fattr_bitmap_maxsz)
+#define nfsd4_enc_setclientid_sz \
+				(op_encode_hdr_size + 2 + 1024)
+#define nfsd4_enc_write_sz	(op_encode_hdr_size + 2 + encode_verifier_maxsz)
+
+/* For NFSv4.1*/
+#define nfsd4_enc_bind_conn_to_session_sz \
+				(op_encode_hdr_size + \
+				 XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 2)
+#define nfsd4_enc_exchange_id_sz \
+				(op_encode_hdr_size + 2 + 1 + 1 + 1 + 0 + \
+				 2 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
+				 XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
+				 1 + 0)
+
+#define encode_channel_attrs_maxsz  (6 + 1 + 1)
+#define nfsd4_enc_create_session_sz \
+				(op_encode_hdr_size + \
+				 XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
+				 1 + 1 + encode_channel_attrs_maxsz + \
+				 encode_channel_attrs_maxsz)
+
+#define nfsd4_enc_destroy_session_sz op_encode_hdr_size
+#define nfsd4_enc_secinfo_no_name_sz nfsd4_enc_secinfo_sz
+#define nfsd4_enc_sequence_sz 	(op_encode_hdr_size + \
+				 XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
+#define nfsd4_enc_test_stateid_sz op_encode_hdr_size
+#define nfsd4_enc_free_stateid_sz op_encode_hdr_size
+
+static u32 nfsd4_enc_read_playload(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_op op = args->ops[resp->opcnt];
+	u32 maxcount = 0, rd_length = 0;
+
+	maxcount = svc_max_payload(rqstp);
+	rd_length = op.u.read.rd_length;
+
+	if (maxcount > rd_length)
+		return rd_length;
+	else
+		return maxcount;
+}
+
+static u32 nfsd4_enc_readdir_playload(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_op op = args->ops[resp->opcnt];
+	u32 rd_maxcount = 0;
+
+	rd_maxcount = op.u.readdir.rd_maxcount;
+
+	if (rd_maxcount > PAGE_SIZE)
+		return PAGE_SIZE;
+	else
+		return rd_maxcount;
+}
+
+static u32 nfsd4_enc_readlink_playload(struct svc_rqst *rqstp)
+{
+	return PATH_MAX;
+}
+
+/*
+ * Response len count as nfsd4_encode_fattr
+ */
+static u32 nfsd4_enc_getattr_playload(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_op op = args->ops[resp->opcnt];
+	u32 *bmval = op.u.getattr.ga_bmval;
+	u32 bmval0 = bmval[0];
+	u32 bmval1 = bmval[1];
+	u32 bmval2 = bmval[2];
+	u32 mlen = 0, lc = 0;
+
+	if (bmval2)
+		mlen += 16;
+	else if (bmval1)
+		mlen += 12;
+	else
+		mlen += 8;
+
+	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
+		if (!nfsd_suppattrs2(resp->cstate.minorversion))
+			mlen += 12;
+		else
+			mlen += 16;
+	}
+
+	if (bmval0 & FATTR4_WORD0_TYPE)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_CHANGE)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_SIZE)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_LINK_SUPPORT)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_SYMLINK_SUPPORT)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_NAMED_ATTR)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_FSID)
+		mlen += 16;
+	if (bmval0 & FATTR4_WORD0_UNIQUE_HANDLES)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_LEASE_TIME)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR)
+		mlen += 4;
+
+	/* For simple, Suppose ACL is supported */
+	if (bmval0 & FATTR4_WORD0_ACL)
+		mlen += 4 + 12;
+	if (bmval0 & FATTR4_WORD0_ACLSUPPORT)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_CANSETTIME)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_CASE_INSENSITIVE)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_CASE_PRESERVING)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_CHOWN_RESTRICTED)
+		mlen += 4;
+
+	/* Using NFS4_FHSIZE for fhp->fh_handle.fh_size */
+	if (bmval0 & FATTR4_WORD0_FILEHANDLE)
+		mlen += (XDR_QUADLEN(NFS4_FHSIZE) << 2) + 4;
+	if (bmval0 & FATTR4_WORD0_FILEID)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_FILES_AVAIL)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_FILES_FREE)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_FILES_TOTAL)
+		mlen += 8;
+
+
+	/* fs locations */
+	lc = resp->cstate.current_fh.fh_export->ex_fslocs.locations_count;
+	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS)
+		mlen += 4 + /* count */ \
+			((XDR_QUADLEN(PATH_MAX) << 2) + 4) + /* components */ \
+			4 + /* locations_count */ \
+			lc * 2 * ((XDR_QUADLEN(PATH_MAX) << 2) + 4);
+
+	if (bmval0 & FATTR4_WORD0_HOMOGENEOUS)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_MAXFILESIZE)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_MAXLINK)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_MAXNAME)
+		mlen += 4;
+	if (bmval0 & FATTR4_WORD0_MAXREAD)
+		mlen += 8;
+	if (bmval0 & FATTR4_WORD0_MAXWRITE)
+		mlen += 8;
+	if (bmval1 & FATTR4_WORD1_MODE)
+		mlen += 4;
+	if (bmval1 & FATTR4_WORD1_NO_TRUNC)
+		mlen += 4;
+	if (bmval1 & FATTR4_WORD1_NUMLINKS)
+		mlen += 4;
+
+	/* owner : for simple using IDMAP_NAMESZ */
+	if (bmval1 & FATTR4_WORD1_OWNER)
+		mlen += (XDR_QUADLEN(IDMAP_NAMESZ) << 2) + 4;
+	/* owner group : for simple using IDMAP_NAMESZ */
+	if (bmval1 & FATTR4_WORD1_OWNER_GROUP)
+		mlen += (XDR_QUADLEN(IDMAP_NAMESZ) << 2) + 4;
+
+	if (bmval1 & FATTR4_WORD1_RAWDEV)
+		mlen += 8;
+	if (bmval1 & FATTR4_WORD1_SPACE_AVAIL)
+		mlen += 8;
+	if (bmval1 & FATTR4_WORD1_SPACE_FREE)
+		mlen += 8;
+	if (bmval1 & FATTR4_WORD1_SPACE_TOTAL)
+		mlen += 8;
+	if (bmval1 & FATTR4_WORD1_SPACE_USED)
+		mlen += 8;
+	if (bmval1 & FATTR4_WORD1_TIME_ACCESS)
+		mlen += 12;
+	if (bmval1 & FATTR4_WORD1_TIME_DELTA)
+		mlen += 12;
+	if (bmval1 & FATTR4_WORD1_TIME_METADATA)
+		mlen += 12;
+	if (bmval1 & FATTR4_WORD1_TIME_MODIFY)
+		mlen += 12;
+	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID)
+		mlen += 8;
+	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT)
+		mlen += 16;
+
+	return mlen;
+}
+
+static u32 nfsd4_enc_test_stateid_playload(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_op op = args->ops[resp->opcnt];
+	
+	return op.u.test_stateid.ts_num_ids * sizeof(__be32);
+}
+
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
 		.op_name = "OP_ACCESS",
+		.op_enc_size = nfsd4_enc_access_sz,
 	},
 	[OP_CLOSE] = {
 		.op_func = (nfsd4op_func)nfsd4_close,
 		.op_name = "OP_CLOSE",
+		.op_enc_size = nfsd4_enc_close_sz,
 	},
 	[OP_COMMIT] = {
 		.op_func = (nfsd4op_func)nfsd4_commit,
 		.op_name = "OP_COMMIT",
+		.op_enc_size = nfsd4_enc_commit_sz,
 	},
 	[OP_CREATE] = {
 		.op_func = (nfsd4op_func)nfsd4_create,
 		.op_name = "OP_CREATE",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_create_sz,
 	},
 	[OP_DELEGRETURN] = {
 		.op_func = (nfsd4op_func)nfsd4_delegreturn,
 		.op_name = "OP_DELEGRETURN",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_GETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_getattr,
 		.op_flags = ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_GETATTR",
+		.op_enc_size = nfsd4_enc_getattr_sz,
+		.op_payload = nfsd4_enc_getattr_playload,
 	},
 	[OP_GETFH] = {
 		.op_func = (nfsd4op_func)nfsd4_getfh,
 		.op_name = "OP_GETFH",
+		.op_enc_size = nfsd4_enc_getfh_sz,
 	},
 	[OP_LINK] = {
 		.op_func = (nfsd4op_func)nfsd4_link,
 		.op_name = "OP_LINK",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_link_sz,
 	},
 	[OP_LOCK] = {
 		.op_func = (nfsd4op_func)nfsd4_lock,
 		.op_name = "OP_LOCK",
+		.op_enc_size = nfsd4_enc_lock_sz,
 	},
 	[OP_LOCKT] = {
 		.op_func = (nfsd4op_func)nfsd4_lockt,
 		.op_name = "OP_LOCKT",
+		.op_enc_size = nfsd4_enc_lockt_sz,
 	},
 	[OP_LOCKU] = {
 		.op_func = (nfsd4op_func)nfsd4_locku,
 		.op_name = "OP_LOCKU",
+		.op_enc_size = nfsd4_enc_locku_sz,
 	},
 	[OP_LOOKUP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookup,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_LOOKUP",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_LOOKUPP] = {
 		.op_func = (nfsd4op_func)nfsd4_lookupp,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_LOOKUPP",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_NVERIFY] = {
 		.op_func = (nfsd4op_func)nfsd4_nverify,
 		.op_name = "OP_NVERIFY",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_OPEN] = {
 		.op_func = (nfsd4op_func)nfsd4_open,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_OPEN",
+		.op_enc_size = nfsd4_enc_open_sz,
 	},
 	[OP_OPEN_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_open_confirm,
 		.op_name = "OP_OPEN_CONFIRM",
+		.op_enc_size = nfsd4_enc_open_confirm_sz,
 	},
 	[OP_OPEN_DOWNGRADE] = {
 		.op_func = (nfsd4op_func)nfsd4_open_downgrade,
 		.op_name = "OP_OPEN_DOWNGRADE",
+		.op_enc_size = nfsd4_enc_open_downgrade_sz,
 	},
 	[OP_PUTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_PUTFH",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_PUTPUBFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_PUTPUBFH",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_PUTROOTFH] = {
 		.op_func = (nfsd4op_func)nfsd4_putrootfh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_PUTROOTFH",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_READ] = {
 		.op_func = (nfsd4op_func)nfsd4_read,
 		.op_name = "OP_READ",
+		.op_enc_size = nfsd4_enc_read_sz,
+		.op_payload = nfsd4_enc_read_playload,
 	},
 	[OP_READDIR] = {
 		.op_func = (nfsd4op_func)nfsd4_readdir,
 		.op_name = "OP_READDIR",
+		.op_enc_size = nfsd4_enc_readdir_sz,
+		.op_payload = nfsd4_enc_readdir_playload,
 	},
 	[OP_READLINK] = {
 		.op_func = (nfsd4op_func)nfsd4_readlink,
 		.op_name = "OP_READLINK",
+		.op_enc_size = nfsd4_enc_readlink_sz,
+		.op_payload = nfsd4_enc_readlink_playload,
 	},
 	[OP_REMOVE] = {
 		.op_func = (nfsd4op_func)nfsd4_remove,
 		.op_name = "OP_REMOVE",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_remove_sz,
 	},
 	[OP_RENAME] = {
-		.op_name = "OP_RENAME",
 		.op_func = (nfsd4op_func)nfsd4_rename,
+		.op_name = "OP_RENAME",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_rename_sz,
 	},
 	[OP_RENEW] = {
 		.op_func = (nfsd4op_func)nfsd4_renew,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_RENEW",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_RESTOREFH] = {
 		.op_func = (nfsd4op_func)nfsd4_restorefh,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS
 				| OP_IS_PUTFH_LIKE,
 		.op_name = "OP_RESTOREFH",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_SAVEFH] = {
 		.op_func = (nfsd4op_func)nfsd4_savefh,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SAVEFH",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_SECINFO] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO",
+		.op_enc_size = nfsd4_enc_secinfo_sz,
 	},
 	[OP_SETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_setattr,
 		.op_name = "OP_SETATTR",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_setattr_sz,
 	},
 	[OP_SETCLIENTID] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_SETCLIENTID",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_setclientid_sz,
 	},
 	[OP_SETCLIENTID_CONFIRM] = {
 		.op_func = (nfsd4op_func)nfsd4_setclientid_confirm,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_SETCLIENTID_CONFIRM",
 		.op_cacheresult = true,
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_VERIFY] = {
 		.op_func = (nfsd4op_func)nfsd4_verify,
 		.op_name = "OP_VERIFY",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_WRITE] = {
 		.op_func = (nfsd4op_func)nfsd4_write,
 		.op_name = "OP_WRITE",
 		.op_cacheresult = true,
+		.op_enc_size = nfsd4_enc_write_sz,
 	},
 	[OP_RELEASE_LOCKOWNER] = {
 		.op_func = (nfsd4op_func)nfsd4_release_lockowner,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_ON_ABSENT_FS,
 		.op_name = "OP_RELEASE_LOCKOWNER",
+		.op_enc_size = op_encode_hdr_size,
 	},
 
 	/* NFSv4.1 operations */
@@ -1411,51 +1725,62 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_exchange_id,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_EXCHANGE_ID",
+		.op_enc_size = nfsd4_enc_exchange_id_sz,
 	},
 	[OP_BIND_CONN_TO_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_bind_conn_to_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_BIND_CONN_TO_SESSION",
+		.op_enc_size = nfsd4_enc_bind_conn_to_session_sz,
 	},
 	[OP_CREATE_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_create_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_CREATE_SESSION",
+		.op_enc_size = nfsd4_enc_create_session_sz,
 	},
 	[OP_DESTROY_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_destroy_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_DESTROY_SESSION",
+		.op_enc_size = nfsd4_enc_destroy_session_sz,
 	},
 	[OP_SEQUENCE] = {
 		.op_func = (nfsd4op_func)nfsd4_sequence,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
+		.op_enc_size = nfsd4_enc_sequence_sz,
 	},
 	[OP_DESTROY_CLIENTID] = {
 		.op_func = NULL,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_DESTROY_CLIENTID",
+		.op_enc_size = nfsd4_enc_destroy_session_sz,
 	},
 	[OP_RECLAIM_COMPLETE] = {
 		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_RECLAIM_COMPLETE",
+		.op_enc_size = op_encode_hdr_size,
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
+		.op_enc_size = nfsd4_enc_secinfo_no_name_sz,
 	},
 	[OP_TEST_STATEID] = {
 		.op_func = (nfsd4op_func)nfsd4_test_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_TEST_STATEID",
+		.op_enc_size = nfsd4_enc_test_stateid_sz,
+		.op_payload = nfsd4_enc_test_stateid_playload,
 	},
 	[OP_FREE_STATEID] = {
 		.op_func = (nfsd4op_func)nfsd4_free_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH,
 		.op_name = "OP_FREE_STATEID",
+		.op_enc_size = nfsd4_enc_free_stateid_sz,
 	},
 };
 
@@ -1466,6 +1791,22 @@ static const char *nfsd4_op_name(unsigned opnum)
 	return "unknown_operation";
 }
 
+u32 get_ops_max_respz(struct svc_rqst * rqstp)
+{
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	__be32 opnum = args->ops[resp->opcnt].opnum;
+	__be32 length = 0;
+
+	length = nfsd4_ops[opnum].op_enc_size * 4;
+	if (nfsd4_ops[opnum].op_payload)
+		length += nfsd4_ops[opnum].op_payload(rqstp);
+
+	dprintk("%s opnum %u max reply %u\n", __func__, opnum, length);
+
+	return length;
+}
+
 #define nfsd4_voidres			nfsd4_voidargs
 struct nfsd4_voidargs { int dummy; };
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c8bf405..5aa825f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3336,32 +3336,31 @@ static nfsd4_enc nfsd4_enc_ops[] = {
  * Calculate the total amount of memory that the compound response has taken
  * after encoding the current operation.
  *
- * pad: add on 8 bytes for the next operation's op_code and status so that
- * there is room to cache a failure on the next operation.
- *
- * Compare this length to the session se_fmaxresp_cached.
+ * Compare this length to the session se_fmaxresp_sz and se_fmaxresp_cached.
  *
  * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
  * will be at least a page and will therefore hold the xdr_buf head.
  */
-static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
+static int nfsd4_check_resp_limit(struct nfsd4_compoundres *resp)
 {
 	int status = 0;
 	struct xdr_buf *xb = &resp->rqstp->rq_res;
 	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
 	struct nfsd4_session *session = NULL;
 	struct nfsd4_slot *slot = resp->cstate.slot;
-	u32 length, tlen = 0, pad = 8;
+	u32 length, tlen = 0, pad = 0;
 
 	if (!nfsd4_has_session(&resp->cstate))
 		return status;
 
 	session = resp->cstate.session;
-	if (session == NULL || slot->sl_cachethis == 0)
+	if (session == NULL)
 		return status;
 
 	if (resp->opcnt >= args->opcnt)
-		pad = 0; /* this is the last operation */
+		return status;
+
+	pad = get_ops_max_respz(resp->rqstp);
 
 	if (xb->page_len == 0) {
 		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
@@ -3374,10 +3373,14 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
 		length, xb->page_len, tlen, pad);
 
-	if (length <= session->se_fchannel.maxresp_cached)
-		return status;
-	else
-		return nfserr_rep_too_big_to_cache;
+	if (length > session->se_fchannel.maxresp_sz)
+		args->ops[resp->opcnt].status = nfserr_rep_too_big;
+
+	if (slot->sl_cachethis == 1 &&
+	    length > session->se_fchannel.maxresp_cached)
+		args->ops[resp->opcnt].status = nfserr_rep_too_big_to_cache;
+
+	return 0;
 }
 
 void
@@ -3397,8 +3400,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	       !nfsd4_enc_ops[op->opnum]);
 	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
 	/* nfsd4_check_drc_limit guarantees enough room for error status */
-	if (!op->status && nfsd4_check_drc_limit(resp))
-		op->status = nfserr_rep_too_big_to_cache;
+	if (!op->status)
+		nfsd4_check_resp_limit(resp);
 status:
 	/*
 	 * Note: We write the status directly, instead of using WRITE32(),
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index d2a8d044..85596a2 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -588,6 +588,7 @@ extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
 extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
 			  struct nfsd4_compound_state *, clientid_t *clid);
+extern __be32 get_ops_max_respz(struct svc_rqst *);
 extern __be32 nfsd4_test_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_test_stateid *test_stateid);
 extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
-- 
1.7.6


