Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18653 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117AbaIIOtu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 10:49:50 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] nfsd: Add DEALLOCATE support
Date: Tue, 9 Sep 2014 10:49:42 -0400
Message-ID: <1410274182-30740-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The DEALLOCATE operation is used to punch holes in a file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4proc.c | 31 ++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c  | 19 ++++++++++++++++++-
 fs/nfsd/vfs.c      |  8 ++++++--
 fs/nfsd/vfs.h      |  2 +-
 fs/nfsd/xdr4.h     |  8 ++++++++
 5 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f9d8fac..ac18be6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1028,7 +1028,7 @@ nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 	}
 
-	status = nfsd4_vfs_fallocate(&cstate->current_fh, file,
+	status = nfsd4_vfs_fallocate(&cstate->current_fh, file, false,
 				     allocate->alloc_offset,
 				     allocate->alloc_length);
 	fput(file);
@@ -1036,6 +1036,28 @@ nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 }
 
 static __be32
+nfsd4_deallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		struct nfsd4_deallocate *deallocate)
+{
+	__be32 status = nfserr_notsupp;
+	struct file *file;
+
+	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+					    &deallocate->dealloc_stateid,
+					    WR_STATE, &file);
+	if (status != nfs_ok) {
+		dprintk("NFSD: nfsd4_deallocate: couldn't process stateid!\n");
+		return status;
+	}
+
+	status = nfsd4_vfs_fallocate(&cstate->current_fh, file, true,
+				     deallocate->dealloc_offset,
+				     deallocate->dealloc_length);
+	fput(file);
+	return status;
+}
+
+static __be32
 nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_seek *seek)
 {
@@ -1949,6 +1971,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
 		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
 	},
+	[OP_DEALLOCATE] = {
+		.op_func = (nfsd4op_func)nfsd4_deallocate,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_DEALLOCATE",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_get_currentstateid = (stateid_getter)nfsd4_get_writestateid,
+	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a55aa3b..e1059ce 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1538,6 +1538,23 @@ nfsd4_decode_allocate(struct nfsd4_compoundargs *argp,
 }
 
 static __be32
+nfsd4_decode_deallocate(struct nfsd4_compoundargs *argp,
+		      struct nfsd4_deallocate *deallocate)
+{
+	DECODE_HEAD;
+
+	status = nfsd4_decode_stateid(argp, &deallocate->dealloc_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(16);
+	p = xdr_decode_hyper(p, &deallocate->dealloc_offset);
+	xdr_decode_hyper(p, &deallocate->dealloc_length);
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
 {
 	DECODE_HEAD;
@@ -1631,7 +1648,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_allocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_deallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4b1dba0..2bf5263 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -525,9 +525,13 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 #endif
 
 __be32 nfsd4_vfs_fallocate(struct svc_fh *fhp, struct file *file,
-			   loff_t offset, loff_t len)
+			   bool punch, loff_t offset, loff_t len)
 {
-	int error = vfs_fallocate(file, 0, offset, len);
+	int error, mode = 0;
+	if (punch)
+		mode = FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE;
+
+	error = vfs_fallocate(file, mode, offset, len);
 	if (error < 0)
 		return nfserrno(error);
 	return nfserrno(commit_metadata(fhp));
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 9d88c88..9301e8e 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -54,7 +54,7 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
 #ifdef CONFIG_NFSD_V4
 __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
 		    struct xdr_netobj *);
-__be32		nfsd4_vfs_fallocate(struct svc_fh *, struct file *, loff_t, loff_t);
+__be32		nfsd4_vfs_fallocate(struct svc_fh *, struct file *, bool, loff_t, loff_t);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 4a01fa8..2866921 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -435,6 +435,13 @@ struct nfsd4_allocate {
 	u64		alloc_length;
 };
 
+struct nfsd4_deallocate {
+	/* request */
+	stateid_t	dealloc_stateid;
+	loff_t		dealloc_offset;
+	u64		dealloc_length;
+};
+
 struct nfsd4_seek {
 	/* request */
 	stateid_t	seek_stateid;
@@ -494,6 +501,7 @@ struct nfsd4_op {
 
 		/* NFSv4.2 */
 		struct nfsd4_allocate		allocate;
+		struct nfsd4_deallocate		deallocate;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
2.1.0

