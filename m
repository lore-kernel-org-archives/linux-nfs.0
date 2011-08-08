Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:38032 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab1HHPiP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 11:38:15 -0400
Subject: [PATCH 4/4] nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Date: Mon, 08 Aug 2011 17:38:13 +0200
Message-ID: <20110808153813.1872437.44997.stgit@fsdevel3>
In-Reply-To: <20110808153432.1872437.85783.stgit@fsdevel3>
References: <20110808153432.1872437.85783.stgit@fsdevel3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
the NFS version. NFSv2 gets 32-bit hashes only.

NOTE: This patch got rather complex as Christoph asked to set the
filp->f_mode flag in the open call or immediatly after dentry_open()
in nfsd_open() to avoid races.
Personally I still do not see a reason for that and in my opinion
FMODE_32BITHASH/FMODE_64BITHASH flags could be set nfsd_readdir(), as it
follows directly after nfsd_open() without a chance of races.


Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 fs/nfsd/vfs.c |   33 +++++++++++++++++++++++----------
 fs/nfsd/vfs.h |    2 ++
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fd0acca..4bb517f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -708,12 +708,13 @@ static int nfsd_open_break_lease(struct inode *inode, int access)
 
 /*
  * Open an existing file or directory.
- * The access argument indicates the type of open (read/write/lock)
+ * The may_flags argument indicates the type of open (read/write/lock)
+ * and additional flags.
  * N.B. After this call fhp needs an fh_put
  */
 __be32
 nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
-			int access, struct file **filp)
+			int may_flags, struct file **filp)
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
@@ -728,7 +729,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	 * and (hopefully) checked permission - so allow OWNER_OVERRIDE
 	 * in case a chmod has now revoked permission.
 	 */
-	err = fh_verify(rqstp, fhp, type, access | NFSD_MAY_OWNER_OVERRIDE);
+	err = fh_verify(rqstp, fhp, type, may_flags | NFSD_MAY_OWNER_OVERRIDE);
 	if (err)
 		goto out;
 
@@ -739,7 +740,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	 * or any access when mandatory locking enabled
 	 */
 	err = nfserr_perm;
-	if (IS_APPEND(inode) && (access & NFSD_MAY_WRITE))
+	if (IS_APPEND(inode) && (may_flags & NFSD_MAY_WRITE))
 		goto out;
 	/*
 	 * We must ignore files (but only files) which might have mandatory
@@ -752,12 +753,12 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (!inode->i_fop)
 		goto out;
 
-	host_err = nfsd_open_break_lease(inode, access);
+	host_err = nfsd_open_break_lease(inode, may_flags);
 	if (host_err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
 
-	if (access & NFSD_MAY_WRITE) {
-		if (access & NFSD_MAY_READ)
+	if (may_flags & NFSD_MAY_WRITE) {
+		if (may_flags & NFSD_MAY_READ)
 			flags = O_RDWR|O_LARGEFILE;
 		else
 			flags = O_WRONLY|O_LARGEFILE;
@@ -766,8 +767,15 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 			    flags, current_cred());
 	if (IS_ERR(*filp))
 		host_err = PTR_ERR(*filp);
-	else
-		host_err = ima_file_check(*filp, access);
+	else {
+		host_err = ima_file_check(*filp, may_flags);
+
+		if (may_flags & NFSD_MAY_64BIT_COOKIE)
+			(*filp)->f_mode |= FMODE_64BITHASH;
+		else
+			(*filp)->f_mode |= FMODE_32BITHASH;
+	}
+
 out_nfserr:
 	err = nfserrno(host_err);
 out:
@@ -1989,8 +1997,13 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	__be32		err;
 	struct file	*file;
 	loff_t		offset = *offsetp;
+	int		flags = NFSD_MAY_READ;
+
+	/* NFSv2 only supports 32 bit cookies */
+	if (rqstp->rq_vers > 2)
+		flags |= NFSD_MAY_64BIT_COOKIE;
 
-	err = nfsd_open(rqstp, fhp, S_IFDIR, NFSD_MAY_READ, &file);
+	err = nfsd_open(rqstp, fhp, S_IFDIR, flags, &file);
 	if (err)
 		goto out;
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index e0bbac0..ecd00e1 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -26,6 +26,8 @@
 #define NFSD_MAY_NOT_BREAK_LEASE 512
 #define NFSD_MAY_BYPASS_GSS	1024
 
+#define NFSD_MAY_64BIT_COOKIE	2048 /* 64 bit readdir cookies for >= NFSv3 */
+
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
 

