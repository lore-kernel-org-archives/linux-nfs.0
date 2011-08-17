Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:42174 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab1HQJ5k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 05:57:40 -0400
Subject: [PATCH 4 4/4] nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com
Date: Wed, 17 Aug 2011 11:57:38 +0200
Message-ID: <20110817095738.1879649.89784.stgit@fsdevel3>
In-Reply-To: <20110817095717.1879649.41075.stgit@fsdevel3>
References: <20110817095717.1879649.41075.stgit@fsdevel3>
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
 0 files changed, 0 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ca692b4..97a99f1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -767,9 +767,15 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 			    flags, current_cred());
 	if (IS_ERR(*filp))
 		host_err = PTR_ERR(*filp);
-	else
+	else {
 		host_err = ima_file_check(*filp, may_flags);
 
+		if (may_flags & NFSD_MAY_64BIT_COOKIE)
+			(*filp)->f_mode |= FMODE_64BITHASH;
+		else
+			(*filp)->f_mode |= FMODE_32BITHASH;
+	}
+
 out_nfserr:
 	err = nfserrno(host_err);
 out:
@@ -1991,8 +1997,13 @@ nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp,
 	__be32		err;
 	struct file	*file;
 	loff_t		offset = *offsetp;
+	int             may_flags = NFSD_MAY_READ;
+
+	/* NFSv2 only supports 32 bit cookies */
+	if (rqstp->rq_vers > 2)
+		may_flags |= NFSD_MAY_64BIT_COOKIE;
 
-	err = nfsd_open(rqstp, fhp, S_IFDIR, NFSD_MAY_READ, &file);
+	err = nfsd_open(rqstp, fhp, S_IFDIR, may_flags, &file);
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
 

