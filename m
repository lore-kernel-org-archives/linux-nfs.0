Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:42157 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab1HQJ5f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 05:57:35 -0400
Subject: [PATCH 4 3/4] nfsd_open(): rename 'int access' to 'int may_flags' in
	nfsd_open()
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com
Date: Wed, 17 Aug 2011 11:57:33 +0200
Message-ID: <20110817095733.1879649.94549.stgit@fsdevel3>
In-Reply-To: <20110817095717.1879649.41075.stgit@fsdevel3>
References: <20110817095717.1879649.41075.stgit@fsdevel3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just rename this variable, as the next patch will add a flag and
'access' as variable name would not be correct any more.


Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 0 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fd0acca..ca692b4 100644
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
@@ -767,7 +768,8 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (IS_ERR(*filp))
 		host_err = PTR_ERR(*filp);
 	else
-		host_err = ima_file_check(*filp, access);
+		host_err = ima_file_check(*filp, may_flags);
+
 out_nfserr:
 	err = nfserrno(host_err);
 out:

