Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39683 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030319AbbD1Nmi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 09:42:38 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] nfsd: clean up raparams handling
Date: Tue, 28 Apr 2015 15:41:18 +0200
Message-Id: <1430228480-7656-5-git-send-email-hch@lst.de>
In-Reply-To: <1430228480-7656-1-git-send-email-hch@lst.de>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor the raparam hash helpers to just deal with the raparms,
and keep opening/closing files separate from that.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4xdr.c | 24 +++++++++++++-------
 fs/nfsd/vfs.c     | 68 ++++++++++++++++++++-----------------------------------
 fs/nfsd/vfs.h     |  6 ++---
 3 files changed, 43 insertions(+), 55 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 158badf..54aced2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -33,6 +33,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/namei.h>
 #include <linux/statfs.h>
@@ -3424,7 +3425,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct file *file = read->rd_filp;
 	struct svc_fh *fhp = read->rd_fhp;
 	int starting_len = xdr->buf->len;
-	struct raparms *ra;
+	struct raparms *ra = NULL;
 	__be32 *p;
 	__be32 err;
 
@@ -3446,23 +3447,30 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
 
-	if (read->rd_filp)
+	if (read->rd_filp) {
 		err = nfsd_permission(resp->rqstp, fhp->fh_export,
 				fhp->fh_dentry,
 				NFSD_MAY_READ|NFSD_MAY_OWNER_OVERRIDE);
-	else
-		err = nfsd_get_tmp_read_open(resp->rqstp, read->rd_fhp,
-						&file, &ra);
-	if (err)
-		goto err_truncate;
+		if (err)
+			goto err_truncate;
+	} else {
+		err = nfsd_open(resp->rqstp, fhp, S_IFREG, NFSD_MAY_READ,
+				&file);
+		if (err)
+			goto err_truncate;
+
+		ra = nfsd_init_raparms(file);
+	}
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
 		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		err = nfsd4_encode_readv(resp, read, file, maxcount);
 
+	if (ra)
+		nfsd_put_raparams(file, ra);
 	if (!read->rd_filp)
-		nfsd_put_tmp_read_open(file, ra);
+		fput(file);
 
 err_truncate:
 	if (err)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a30e799..9798c2cd 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -761,14 +761,12 @@ out:
 	return err;
 }
 
-/*
- * Obtain the readahead parameters for the file
- * specified by (dev, ino).
- */
-
-static inline struct raparms *
-nfsd_get_raparms(dev_t dev, ino_t ino)
+struct raparms *
+nfsd_init_raparms(struct file *file)
 {
+	struct inode *inode = file_inode(file);
+	dev_t dev = inode->i_sb->s_dev;
+	ino_t ino = inode->i_ino;
 	struct raparms	*ra, **rap, **frap = NULL;
 	int depth = 0;
 	unsigned int hash;
@@ -805,9 +803,23 @@ found:
 	ra->p_count++;
 	nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
 	spin_unlock(&rab->pb_lock);
+
+	if (ra->p_set)
+		file->f_ra = ra->p_ra;
 	return ra;
 }
 
+void nfsd_put_raparams(struct file *file, struct raparms *ra)
+{
+	struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
+
+	spin_lock(&rab->pb_lock);
+	ra->p_ra = file->f_ra;
+	ra->p_set = 1;
+	ra->p_count--;
+	spin_unlock(&rab->pb_lock);
+}
+
 /*
  * Grab and keep cached pages associated with a file in the svc_rqst
  * so that they can be passed to the network sendmsg/sendpage routines
@@ -1000,40 +1012,6 @@ out_nfserr:
 	return err;
 }
 
-__be32 nfsd_get_tmp_read_open(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		struct file **file, struct raparms **ra)
-{
-	struct inode *inode;
-	__be32 err;
-
-	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, file);
-	if (err)
-		return err;
-
-	inode = file_inode(*file);
-
-	/* Get readahead parameters */
-	*ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino);
-
-	if (*ra && (*ra)->p_set)
-		(*file)->f_ra = (*ra)->p_ra;
-	return nfs_ok;
-}
-
-void nfsd_put_tmp_read_open(struct file *file, struct raparms *ra)
-{
-	/* Write back readahead params */
-	if (ra) {
-		struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
-		spin_lock(&rab->pb_lock);
-		ra->p_ra = file->f_ra;
-		ra->p_set = 1;
-		ra->p_count--;
-		spin_unlock(&rab->pb_lock);
-	}
-	fput(file);
-}
-
 /*
  * Read data from a file. count must contain the requested read count
  * on entry. On return, *count contains the number of bytes actually read.
@@ -1046,13 +1024,15 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct raparms	*ra;
 	__be32 err;
 
-	err = nfsd_get_tmp_read_open(rqstp, fhp, &file, &ra);
+	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
 	if (err)
 		return err;
 
+	ra = nfsd_init_raparms(file);
 	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
-
-	nfsd_put_tmp_read_open(file, ra);
+	if (ra)
+		nfsd_put_raparams(file, ra);
+	fput(file);
 
 	return err;
 }
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 17a5e0d..053c4ad 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -72,9 +72,6 @@ __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
 struct raparms;
-__be32		nfsd_get_tmp_read_open(struct svc_rqst *, struct svc_fh *,
-				struct file **, struct raparms **);
-void		nfsd_put_tmp_read_open(struct file *, struct raparms *);
 __be32		nfsd_splice_read(struct svc_rqst *,
 				struct file *, loff_t, unsigned long *);
 __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
@@ -103,6 +100,9 @@ __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
 
+struct raparms *nfsd_init_raparms(struct file *file);
+void		nfsd_put_raparams(struct file *file, struct raparms *ra);
+
 static inline int fh_want_write(struct svc_fh *fh)
 {
 	int ret = mnt_want_write(fh->fh_export->ex_path.mnt);
-- 
1.9.1

