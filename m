From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 6/7] nfsd: restrict filehandles accepted in V4ROOT case
Date: Tue,  1 Dec 2009 19:39:42 -0500
Message-ID: <1259714383-32577-7-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-4-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-5-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-6-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	Steve Dickson <SteveD@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46267 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754899AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <SteveD@redhat.com>

On V4ROOT exports, only accept filehandles that are the *root* of some
export.  This allows mountd to allow or deny access to individual paths
and symlinks on the pseudofilesystem.

Note that the checks in readdir and lookup are not enough, since a
malicious host with access to the network could guess filehandles that
they weren't able to obtain through lookup or readdir.

Signed-Off-By: Steve Dickson <steved@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsd.h  |    4 ++++
 fs/nfsd/nfsfh.c |   35 +++++++++++++++++++++++++++++++++++
 fs/nfsd/vfs.c   |    7 +------
 3 files changed, 40 insertions(+), 6 deletions(-)
 create mode 100644 fs/nfsd/nfsd.h

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
new file mode 100644
index 0000000..7a1ad80
--- /dev/null
+++ b/fs/nfsd/nfsd.h
@@ -0,0 +1,4 @@
+static inline int nfsd_v4client(struct svc_rqst *rq)
+{
+	return rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
+}
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index a77efb8..9b902c0 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -22,6 +22,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/nfsd/nfsd.h>
+#include "nfsd.h"
 #include "vfs.h"
 #include "auth.h"
 
@@ -110,6 +111,36 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 	return nfserrno(nfsd_setuser(rqstp, exp));
 }
 
+static inline __be32 check_pseudo_root(struct svc_rqst *rqstp,
+	struct dentry *dentry, struct svc_export *exp)
+{
+	if (!(exp->ex_flags & NFSEXP_V4ROOT))
+		return nfs_ok;
+	/*
+	 * v2/v3 clients have no need for the V4ROOT export--they use
+	 * the mount protocl instead; also, further V4ROOT checks may be
+	 * in v4-specific code, in which case v2/v3 clients could bypass
+	 * them.
+	 */
+	if (!nfsd_v4client(rqstp))
+		return nfserr_stale;
+	/*
+	 * We're exposing only the directories and symlinks that have to be
+	 * traversed on the way to real exports:
+	 */
+	if (unlikely(!S_ISDIR(dentry->d_inode->i_mode) &&
+		     !S_ISLNK(dentry->d_inode->i_mode)))
+		return nfserr_stale;
+	/*
+	 * A pseudoroot export gives permission to access only one
+	 * single directory; the kernel has to make another upcall
+	 * before granting access to anything else under it:
+	 */
+	if (unlikely(dentry->d_parent != exp->ex_path.dentry))
+		return nfserr_stale;
+	return nfs_ok;
+}
+
 /*
  * Use the given filehandle to look up the corresponding export and
  * dentry.  On success, the results are used to set fh_export and
@@ -306,6 +337,10 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
 	 *	  (for example, if different id-squashing options are in
 	 *	  effect on the new filesystem).
 	 */
+	error = check_pseudo_root(rqstp, dentry, exp);
+	if (error)
+		goto out;
+
 	error = nfsd_setuser_and_check_port(rqstp, exp);
 	if (error)
 		goto out;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index caf4794..f20d7b4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -56,6 +56,7 @@
 #endif /* CONFIG_NFSD_V4 */
 #include <linux/jhash.h>
 #include <linux/ima.h>
+#include "nfsd.h"
 #include "vfs.h"
 
 #include <asm/uaccess.h>
@@ -90,12 +91,6 @@ struct raparm_hbucket {
 #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
 static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
 
-static inline int
-nfsd_v4client(struct svc_rqst *rq)
-{
-    return rq->rq_prog == NFS_PROGRAM && rq->rq_vers == 4;
-}
-
 /* 
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
  * a mount point.
-- 
1.6.3.3

