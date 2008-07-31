From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 1/4] Factor out nfsd_do_readdir() into its own function
Date: Thu, 31 Jul 2008 22:54:49 +0100
Message-ID: <1217541289.1126.17.camel@shinybook.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <18458.28833.539314.455215@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 fs/nfsd/vfs.c |   40 ++++++++++++++++++++++++----------------
 1 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 18060be..3e22634 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1814,6 +1814,29 @@ out:
 	return err;
 }
 
+static int nfsd_do_readdir(struct file *file, filldir_t func,
+			   struct readdir_cd *cdp, loff_t *offsetp)
+{
+	int host_err;
+
+	/*
+	 * Read the directory entries. This silly loop is necessary because
+	 * readdir() is not guaranteed to fill up the entire buffer, but
+	 * may choose to do less.
+	 */
+	do {
+		cdp->err = nfserr_eof; /* will be cleared on successful read */
+		host_err = vfs_readdir(file, func, cdp);
+	} while (host_err >=0 && cdp->err == nfs_ok);
+
+	*offsetp = vfs_llseek(file, 0, 1);
+
+	if (host_err)
+		return nfserrno(host_err);
+	else
+		return cdp->err;
+}
+
 /*
  * Read entries from a directory.
  * The  NFSv3/4 verifier we ignore for now.
@@ -1823,7 +1846,6 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	     struct readdir_cd *cdp, filldir_t func)
 {
 	__be32		err;
-	int 		host_err;
 	struct file	*file;
 	loff_t		offset = *offsetp;
 
@@ -1837,21 +1859,7 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 		goto out_close;
 	}
 
-	/*
-	 * Read the directory entries. This silly loop is necessary because
-	 * readdir() is not guaranteed to fill up the entire buffer, but
-	 * may choose to do less.
-	 */
-
-	do {
-		cdp->err = nfserr_eof; /* will be cleared on successful read */
-		host_err = vfs_readdir(file, func, cdp);
-	} while (host_err >=0 && cdp->err == nfs_ok);
-	if (host_err)
-		err = nfserrno(host_err);
-	else
-		err = cdp->err;
-	*offsetp = vfs_llseek(file, 0, 1);
+	err = nfsd_do_readdir(file, func, cdp, offsetp);
 
 	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

