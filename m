From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: [PATCH 3/3] integrity: nfsd imbalance bug fix
Date: Tue, 19 May 2009 13:25:59 -0400
Message-ID: <ac3acdbcb8a63d70635e9c7b8fb5192b01756548.1242753149.git.zohar@linux.vnet.ibm.com>
References: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Eric Paris <eparis@redhat.com>,
	Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>,
	James Morris <jmorris@namei.org>,
	David Safford <safford-aZOuKsOsJu3MbYB6QlFGEg@public.gmane.org>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Mimi Zohar <zohar@us.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:33251 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752827AbZESR0C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 13:26:02 -0400
In-Reply-To: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
In-Reply-To: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
References: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An nfsd exported file is opened/closed by the kernel causing the
integrity imbalance message.

Before a file is opened, there normally is permission checking, which
is done in inode_permission().  However, as integrity checking requires
a dentry and mount point, which is not available in inode_permission(),
the integrity (permission) checking must be called separately.

In order to detect any missing integrity checking calls, we keep track
of file open/closes.  ima_path_check() increments these counts and
does the integrity (permission) checking. As a result, the number of
calls to ima_path_check()/ima_file_free() should be balanced.  An extra
call to fput(), indicates the file could have been accessed without first
calling ima_path_check().

In nfsv3 permission checking is done once, followed by multiple reads,
which do an open/close for each read.  The integrity (permission) checking
call should be in nfsd_permission() after the inode_permission() call, but
as there is no correlation between the number of permission checking and
open calls, the integrity checking call should not increment the counters,
but defer it to when the file is actually opened.

This patch adds:
- integrity (permission) checking for nfsd exported files in nfsd_permission().
- a call to increment counts for files opened by nfsd.

Signed-off-by: Mimi Zohar <zohar@us.ibm.com>
---
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6c68ffd..54a8660 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -55,6 +55,7 @@
 #include <linux/security.h>
 #endif /* CONFIG_NFSD_V4 */
 #include <linux/jhash.h>
+#include <linux/ima.h>
 
 #include <asm/uaccess.h>
 
@@ -735,6 +736,8 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 			    flags, cred);
 	if (IS_ERR(*filp))
 		host_err = PTR_ERR(*filp);
+	else
+		ima_counts_get(*filp);
 out_nfserr:
 	err = nfserrno(host_err);
 out:
@@ -2024,6 +2027,7 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 					struct dentry *dentry, int acc)
 {
 	struct inode	*inode = dentry->d_inode;
+	struct path	path;
 	int		err;
 
 	if (acc == NFSD_MAY_NOP)
@@ -2096,7 +2100,18 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 	if (err == -EACCES && S_ISREG(inode->i_mode) &&
 	    acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE))
 		err = inode_permission(inode, MAY_EXEC);
+	if (err)
+		goto nfsd_out;
 
+	/* Do integrity (permission) checking now, but defer incrementing
+	 * IMA counts to the actual file open.
+	 */
+	path.mnt = exp->ex_path.mnt;
+	path.dentry = dentry;
+	err = ima_path_check(&path, acc & (MAY_READ | MAY_WRITE | MAY_EXEC),
+			     IMA_COUNT_LEAVE);
+	return err;
+nfsd_out:
 	return err? nfserrno(err) : 0;
 }
 
-- 
1.6.0.6

