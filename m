Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39438 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965547AbbD1Nma (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2015 09:42:30 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] nfsd: remove nfsd_close
Date: Tue, 28 Apr 2015 15:41:16 +0200
Message-Id: <1430228480-7656-3-git-send-email-hch@lst.de>
In-Reply-To: <1430228480-7656-1-git-send-email-hch@lst.de>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/vfs.c       | 19 +++++--------------
 fs/nfsd/vfs.h       |  1 -
 3 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 66067a2..39475c9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5506,7 +5506,7 @@ static __be32 nfsd_test_lock(struct svc_rqst *rqstp, struct svc_fh *fhp, struct
 	__be32 err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
 	if (!err) {
 		err = nfserrno(vfs_test_lock(file, lock));
-		nfsd_close(file);
+		fput(file);
 	}
 	return err;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84d770b..a30e799 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -744,7 +744,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 
 	host_err = ima_file_check(file, may_flags, 0);
 	if (host_err) {
-		nfsd_close(file);
+		fput(file);
 		goto out_nfserr;
 	}
 
@@ -762,15 +762,6 @@ out:
 }
 
 /*
- * Close a file.
- */
-void
-nfsd_close(struct file *filp)
-{
-	fput(filp);
-}
-
-/*
  * Obtain the readahead parameters for the file
  * specified by (dev, ino).
  */
@@ -1040,7 +1031,7 @@ void nfsd_put_tmp_read_open(struct file *file, struct raparms *ra)
 		ra->p_count--;
 		spin_unlock(&rab->pb_lock);
 	}
-	nfsd_close(file);
+	fput(file);
 }
 
 /*
@@ -1093,7 +1084,7 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		if (cnt)
 			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
 					     cnt, stablep);
-		nfsd_close(file);
+		fput(file);
 	}
 out:
 	return err;
@@ -1138,7 +1129,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			err = nfserr_notsupp;
 	}
 
-	nfsd_close(file);
+	fput(file);
 out:
 	return err;
 }
@@ -1977,7 +1968,7 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
 out_close:
-	nfsd_close(file);
+	fput(file);
 out:
 	return err;
 }
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 2050cb0..17a5e0d 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -71,7 +71,6 @@ __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 #endif /* CONFIG_NFSD_V3 */
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
-void		nfsd_close(struct file *);
 struct raparms;
 __be32		nfsd_get_tmp_read_open(struct svc_rqst *, struct svc_fh *,
 				struct file **, struct raparms **);
-- 
1.9.1

