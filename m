Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39781 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030319AbbD1Nmm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 09:42:42 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] nfsd: take struct file setup fully into nfs4_preprocess_stateid_op
Date: Tue, 28 Apr 2015 15:41:19 +0200
Message-Id: <1430228480-7656-6-git-send-email-hch@lst.de>
In-Reply-To: <1430228480-7656-1-git-send-email-hch@lst.de>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch changes nfs4_preprocess_stateid_op so it always returns
a valid struct file if it has been asked for that.  For that we
now allocate a temporary struct file for special stateids, and check
permissions if we got the file structure from the stateid.  This
ensures that all callers will get their handling of special stateids
right, and avoids code duplication.

There is a little wart in here because the read code needs to know
if we allocated a file structure so that it can copy around the
read-ahead parameters.  In the long run we should probably aim to
cache full file structures used with special stateids instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c  | 39 +++++++++++++++------------------------
 fs/nfsd/nfs4state.c | 35 ++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c   | 19 +------------------
 fs/nfsd/state.h     |  6 +++---
 fs/nfsd/vfs.c       |  7 +------
 fs/nfsd/vfs.h       |  4 ++++
 fs/nfsd/xdr4.h      |  1 +
 7 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 864e200..5aa7c4e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -760,8 +760,6 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 
-	/* no need to check permission - this will be done in nfsd_read() */
-
 	read->rd_filp = NULL;
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
@@ -778,9 +776,9 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 
 	/* check stateid */
-	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
-						 cstate, &read->rd_stateid,
-						 RD_STATE, &read->rd_filp))) {
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &read->rd_stateid,
+			RD_STATE, &read->rd_filp, &read->rd_tmp_file);
+	if (status) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -924,8 +922,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	int err;
 
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
-		status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
-			&setattr->sa_stateid, WR_STATE, NULL);
+		status = nfs4_preprocess_stateid_op(rqstp, cstate,
+			&setattr->sa_stateid, WR_STATE, NULL, NULL);
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -986,13 +984,11 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	unsigned long cnt;
 	int nvecs;
 
-	/* no need to check permission - this will be done in nfsd_write() */
-
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
-					cstate, stateid, WR_STATE, &filp);
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, stateid, WR_STATE,
+			&filp, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
@@ -1005,11 +1001,10 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
 	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
 
-	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
-			     write->wr_offset, rqstp->rq_vec, nvecs,
-			     &cnt, &write->wr_how_written);
-	if (filp)
-		fput(filp);
+	status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
+				write->wr_offset, rqstp->rq_vec, nvecs, &cnt,
+				&write->wr_how_written);
+	fput(filp);
 
 	write->wr_bytes_written = cnt;
 
@@ -1023,15 +1018,13 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = nfserr_notsupp;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
 					    &fallocate->falloc_stateid,
-					    WR_STATE, &file);
+					    WR_STATE, &file, NULL);
 	if (status != nfs_ok) {
 		dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
 		return status;
 	}
-	if (!file)
-		return nfserr_bad_stateid;
 
 	status = nfsd4_vfs_fallocate(rqstp, &cstate->current_fh, file,
 				     fallocate->falloc_offset,
@@ -1064,15 +1057,13 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct file *file;
 
-	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
 					    &seek->seek_stateid,
-					    RD_STATE, &file);
+					    RD_STATE, &file, NULL);
 	if (status) {
 		dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
 		return status;
 	}
-	if (!file)
-		return nfserr_bad_stateid;
 
 	switch (seek->seek_whence) {
 	case NFS4_CONTENT_DATA:
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5070688..e8d3f1b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4613,23 +4613,40 @@ nfs4_check_olstateid(struct svc_fh *fhp, struct nfs4_ol_stateid *ols, int flags)
  * Checks for stateid operations
  */
 __be32
-nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
-			   stateid_t *stateid, int flags, struct file **filpp)
+nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate, stateid_t *stateid,
+		int flags, struct file **filpp, bool *tmp_file)
 {
 	struct svc_fh *fhp = &cstate->current_fh;
 	struct inode *ino = d_inode(fhp->fh_dentry);
+	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	int acc = (flags & RD_STATE) ? NFSD_MAY_READ : NFSD_MAY_WRITE;
 	struct nfs4_stid *s;
 	__be32 status;
 
 	if (filpp)
 		*filpp = NULL;
+	if (tmp_file)
+		*tmp_file = false;
 
 	if (grace_disallows_io(net, ino))
 		return nfserr_grace;
 
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		return check_special_stateids(net, fhp, stateid, flags);
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
+		status = check_special_stateids(net, fhp, stateid, flags);
+		if (status)
+			return status;
+
+		if (filpp) {
+			status = nfsd_open(rqstp, fhp, S_IFREG, acc, filpp);
+			if (status)
+				return status;
+			*tmp_file = true;
+		}
+
+		return nfs_ok;
+	}
 
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
@@ -4656,9 +4673,17 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 
 	if (!status && filpp) {
 		*filpp = nfs4_find_file(s, flags);
-		if (!*filpp)
+		if (!*filpp) {
 			status = nfserr_serverfault;
+			goto out;
+		}
+
+		status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
+				acc | NFSD_MAY_OWNER_OVERRIDE);
+		if (status)
+			fput(*filpp);
 	}
+
 out:
 	nfs4_put_stid(s);
 	return status;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 54aced2..692f539 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -33,7 +33,6 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/namei.h>
 #include <linux/statfs.h>
@@ -3423,7 +3422,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	unsigned long maxcount;
 	struct xdr_stream *xdr = &resp->xdr;
 	struct file *file = read->rd_filp;
-	struct svc_fh *fhp = read->rd_fhp;
 	int starting_len = xdr->buf->len;
 	struct raparms *ra = NULL;
 	__be32 *p;
@@ -3447,20 +3445,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
 
-	if (read->rd_filp) {
-		err = nfsd_permission(resp->rqstp, fhp->fh_export,
-				fhp->fh_dentry,
-				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
-		if (err)
-			goto err_truncate;
-	} else {
-		err = nfsd_open(resp->rqstp, fhp, S_IFREG, NFSD_MAY_READ,
-				&file);
-		if (err)
-			goto err_truncate;
-
+	if (read->rd_tmp_file)
 		ra = nfsd_init_raparms(file);
-	}
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
 		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
@@ -3469,10 +3455,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 
 	if (ra)
 		nfsd_put_raparams(file, ra);
-	if (!read->rd_filp)
-		fput(file);
 
-err_truncate:
 	if (err)
 		xdr_truncate_encode(xdr, starting_len);
 	return err;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index bde45d9..06755c0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -583,9 +583,9 @@ enum nfsd4_cb_op {
 struct nfsd4_compound_state;
 struct nfsd_net;
 
-extern __be32 nfs4_preprocess_stateid_op(struct net *net,
-		struct nfsd4_compound_state *cstate,
-		stateid_t *stateid, int flags, struct file **filp);
+extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *cstate, stateid_t *stateid,
+		int flags, struct file **filp, bool *tmp_file);
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9798c2cd..2418419 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -538,16 +538,11 @@ __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			   struct file *file, loff_t offset, loff_t len,
 			   int flags)
 {
-	__be32 err;
 	int error;
 
 	if (!S_ISREG(file_inode(file)->i_mode))
 		return nfserr_inval;
 
-	err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry, NFSD_MAY_WRITE);
-	if (err)
-		return err;
-
 	error = vfs_fallocate(file, flags, offset, len);
 	if (!error)
 		error = commit_metadata(fhp);
@@ -948,7 +943,7 @@ static int wait_for_concurrent_writes(struct file *file)
 	return err;
 }
 
-static __be32
+__be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
 				unsigned long *cnt, int *stablep)
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 053c4ad..5be875e 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -80,6 +80,10 @@ __be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
 				loff_t, struct kvec *, int, unsigned long *);
 __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
 				loff_t, struct kvec *,int, unsigned long *, int *);
+__be32		nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				struct file *file, loff_t offset,
+				struct kvec *vec, int vlen, unsigned long *cnt,
+				int *stablep);
 __be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2f8c092..9f99100 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -273,6 +273,7 @@ struct nfsd4_read {
 	u32		rd_length;          /* request */
 	int		rd_vlen;
 	struct file     *rd_filp;
+	bool		rd_tmp_file;
 	
 	struct svc_rqst *rd_rqstp;          /* response */
 	struct svc_fh * rd_fhp;             /* response */
-- 
1.9.1

