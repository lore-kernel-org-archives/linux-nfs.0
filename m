Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60903 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932548Ab3J1O5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 10:57:34 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Date: Mon, 28 Oct 2013 10:57:25 -0400
Message-ID: <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch only implements DATA_CONTENT_HOLE support, but I tried to
write it so other arms of the discriminated union can be added easily
later.

This patch is missing support for decoding multiple requests on the same
file.  The way it's written now only the last range provided by the
client will be written to.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4proc.c   | 45 ++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/vfs.c        | 14 ++++++++++++
 fs/nfsd/vfs.h        |  1 +
 fs/nfsd/xdr4.h       | 24 ++++++++++++++++++++
 fs/open.c            |  1 +
 include/linux/nfs4.h |  8 ++++++-
 7 files changed, 152 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 419572f..3210c6f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1028,6 +1028,42 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+static __be32
+nfsd4_write_plus_hole(struct file *file, struct nfsd4_write_plus *writeplus,
+		      struct net *net)
+{
+	__be32 status;
+
+	status = nfsd4_vfs_fallocate(file, writeplus->wp_allocated,
+				writeplus->wp_offset, writeplus->wp_length);
+	if (status == nfs_ok) {
+		writeplus->wp_res.wr_stid = NULL;
+		writeplus->wp_res.wr_bytes_written = writeplus->wp_length;
+		writeplus->wp_res.wr_stable_how = NFS_FILE_SYNC;
+		gen_boot_verifier(&writeplus->wp_res.wr_verifier, net);
+	}
+
+	return status;
+}
+
+static __be32
+nfsd4_write_plus(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_write_plus *writeplus)
+{
+	struct file *file;
+	__be32 status;
+	struct net *net = SVC_NET(rqstp);
+
+	status = nfs4_preprocess_stateid_op(net, cstate, &writeplus->wp_stateid,
+					    WR_STATE, &file);
+	if (status)
+		return status;
+
+	if (writeplus->wp_data_content == NFS4_CONTENT_HOLE)
+		return nfsd4_write_plus_hole(file, writeplus, net);
+	return nfserr_union_notsupp;
+}
+
 /* This routine never returns NFS_OK!  If there are no other errors, it
  * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
  * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
@@ -1840,6 +1876,15 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
 	},
+
+	/* NFSv4.2 operations */
+	[OP_WRITE_PLUS] = {
+		.op_func = (nfsd4op_func)nfsd4_write_plus,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_WRITE_PLUS",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
+	},
 };
 
 #ifdef NFSD_DEBUG
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 60f5a1f..1e4e9af 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1485,6 +1485,32 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 }
 
 static __be32
+nfsd4_decode_write_plus(struct nfsd4_compoundargs *argp,
+			struct nfsd4_write_plus *writeplus)
+{
+	DECODE_HEAD;
+	unsigned int i;
+
+	status = nfsd4_decode_stateid(argp, &writeplus->wp_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(8);
+	READ32(writeplus->wp_stable_how);
+	READ32(writeplus->wp_data_length);
+
+	for (i = 0; i < writeplus->wp_data_length; i++) {
+		READ_BUF(24);
+		READ32(writeplus->wp_data_content);
+		READ64(writeplus->wp_offset);
+		READ64(writeplus->wp_length);
+		READ32(writeplus->wp_allocated);
+	}
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
 	return nfs_ok;
@@ -1665,7 +1691,7 @@ static nfsd4_dec nfsd42_dec_ops[] = {
 	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_REVOKE]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_write_plus,
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3591,6 +3617,38 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 	return nfserr;
 }
 
+static void
+nfsd42_encode_write_res(struct nfsd4_compoundres *resp, struct nfsd42_write_res *write)
+{
+	__be32 *p;
+
+	RESERVE_SPACE(4);
+
+	if (write->wr_stid == NULL) {
+		WRITE32(0);
+		ADJUST_ARGS();
+	} else {
+		WRITE32(1);
+		ADJUST_ARGS();
+		nfsd4_encode_stateid(resp, &write->wr_stid->sc_stateid);
+	}
+
+	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
+	WRITE64(write->wr_bytes_written);
+	WRITE32(write->wr_stable_how);
+	WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
+	ADJUST_ARGS();
+}
+
+static __be32
+nfsd4_encode_write_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
+		        struct nfsd4_write_plus *writeplus)
+{
+	if (!nfserr)
+		nfsd42_encode_write_res(resp, &writeplus->wp_res);
+	return nfserr;
+}
+
 static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
@@ -3670,7 +3728,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_REVOKE]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_write_plus,
 	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c827acb..7fec087 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -16,6 +16,7 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/splice.h>
+#include <linux/falloc.h>
 #include <linux/fcntl.h>
 #include <linux/namei.h>
 #include <linux/delay.h>
@@ -649,6 +650,19 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+__be32 nfsd4_vfs_fallocate(struct file *file, bool allocated, loff_t offset, loff_t len)
+{
+	int error, mode = 0;
+
+	if (allocated == false)
+		mode = FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE;
+
+	error = do_fallocate(file, mode, offset, len);
+	if (error == 0)
+		error = vfs_fsync_range(file, offset, offset + len, 0);
+	return nfserrno(error);
+}
+
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a4be2e3..187eb95 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -57,6 +57,7 @@ __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
 int             nfsd4_get_nfs4_acl(struct svc_rqst *, struct dentry *, struct nfs4_acl **);
 __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
 		    struct xdr_netobj *);
+__be32		nfsd4_vfs_fallocate(struct file *, bool, loff_t, loff_t);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b3ed644..aaef9ab 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -430,6 +430,27 @@ struct nfsd4_reclaim_complete {
 	u32 rca_one_fs;
 };
 
+struct nfsd42_write_res {
+	struct nfs4_stid	*wr_stid;
+	u64			wr_bytes_written;
+	u32			wr_stable_how;
+	nfs4_verifier		wr_verifier;
+};
+
+struct nfsd4_write_plus {
+	/* request */
+	stateid_t	wp_stateid;
+	u32		wp_stable_how;
+	u32		wp_data_length;
+	u32		wp_data_content;
+	u64		wp_offset;
+	u64		wp_length;
+	u32		wp_allocated;
+
+	/* response */
+	struct nfsd42_write_res	wp_res;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -475,6 +496,9 @@ struct nfsd4_op {
 		struct nfsd4_reclaim_complete	reclaim_complete;
 		struct nfsd4_test_stateid	test_stateid;
 		struct nfsd4_free_stateid	free_stateid;
+
+		/* NFSv4.2 */
+		struct nfsd4_write_plus		write_plus;
 	} u;
 	struct nfs4_replay *			replay;
 };
diff --git a/fs/open.c b/fs/open.c
index d420331..09db2d5 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -278,6 +278,7 @@ int do_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 	sb_end_write(inode->i_sb);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(do_fallocate);
 
 SYSCALL_DEFINE4(fallocate, int, fd, int, mode, loff_t, offset, loff_t, len)
 {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2bc5217..55ed991 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -128,7 +128,7 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
+#define LAST_NFS4_OP 	OP_WRITE_PLUS
 
 enum nfsstat4 {
 	NFS4_OK = 0,
@@ -552,4 +552,10 @@ struct nfs4_deviceid {
 	char data[NFS4_DEVICEID4_SIZE];
 };
 
+enum data_content4 {
+	NFS4_CONTENT_DATA		= 0,
+	NFS4_CONTENT_APP_DATA_HOLE	= 1,
+	NFS4_CONTENT_HOLE		= 2,
+};
+
 #endif
-- 
1.8.4.1

