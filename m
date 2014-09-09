Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49143 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756569AbaIIOtu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 10:49:50 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] nfsd: Add ALLOCATE support
Date: Tue, 9 Sep 2014 10:49:41 -0400
Message-ID: <1410274182-30740-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The ALLOCATE operation is used to preallocate space in a file.  I use
vfs_fallocate() to do the actual preallocation.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c | 29 +++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  | 19 ++++++++++++++++++-
 fs/nfsd/vfs.c      |  9 +++++++++
 fs/nfsd/vfs.h      |  1 +
 fs/nfsd/xdr4.h     |  8 ++++++++
 5 files changed, 65 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fd2b78..f9d8fac 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1014,6 +1014,28 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_allocate *allocate)
+{
+	__be32 status = nfserr_notsupp;
+	struct file *file;
+
+	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+					    &allocate->alloc_stateid,
+					    WR_STATE, &file);
+	if (status != nfs_ok) {
+		dprintk("NFSD: nfsd4_allocate: couldn't process stateid!\n");
+		return status;
+	}
+
+	status = nfsd4_vfs_fallocate(&cstate->current_fh, file,
+				     allocate->alloc_offset,
+				     allocate->alloc_length);
+	fput(file);
+	return status;
+}
+
+static __be32
 nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_seek *seek)
 {
@@ -1920,6 +1942,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	},
 
 	/* NFSv4.2 operations */
+	[OP_ALLOCATE] = {
+		.op_func = (nfsd4op_func)nfsd4_allocate,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_ALLOCATE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 57b3973..a55aa3b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1521,6 +1521,23 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 }
 
 static __be32
+nfsd4_decode_allocate(struct nfsd4_compoundargs *argp,
+		      struct nfsd4_allocate *allocate)
+{
+	DECODE_HEAD;
+
+	status = nfsd4_decode_stateid(argp, &allocate->alloc_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(16);
+	p = xdr_decode_hyper(p, &allocate->alloc_offset);
+	xdr_decode_hyper(p, &allocate->alloc_length);
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
 {
 	DECODE_HEAD;
@@ -1611,7 +1628,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
 
 	/* new operations for NFSv4.2 */
-	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_allocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f501a9b..4b1dba0 100644
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
@@ -523,6 +524,14 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+__be32 nfsd4_vfs_fallocate(struct svc_fh *fhp, struct file *file,
+			   loff_t offset, loff_t len)
+{
+	int error = vfs_fallocate(file, 0, offset, len);
+	if (error < 0)
+		return nfserrno(error);
+	return nfserrno(commit_metadata(fhp));
+}
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index c2ff3f1..9d88c88 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -54,6 +54,7 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
 #ifdef CONFIG_NFSD_V4
 __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
 		    struct xdr_netobj *);
+__be32		nfsd4_vfs_fallocate(struct svc_fh *, struct file *, loff_t, loff_t);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 5720e94..4a01fa8 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -428,6 +428,13 @@ struct nfsd4_reclaim_complete {
 	u32 rca_one_fs;
 };
 
+struct nfsd4_allocate {
+	/* request */
+	stateid_t	alloc_stateid;
+	loff_t		alloc_offset;
+	u64		alloc_length;
+};
+
 struct nfsd4_seek {
 	/* request */
 	stateid_t	seek_stateid;
@@ -486,6 +493,7 @@ struct nfsd4_op {
 		struct nfsd4_free_stateid	free_stateid;
 
 		/* NFSv4.2 */
+		struct nfsd4_allocate		allocate;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
2.1.0

