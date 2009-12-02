From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/7] nfsd: filter lookup results in V4ROOT case
Date: Tue,  1 Dec 2009 19:39:39 -0500
Message-ID: <1259714383-32577-4-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46254 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754748AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We treat every object as a mountpoint and pretend it doesn't exist if
it isn't exported.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 04d61c8..5136e61 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -184,6 +184,19 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, st
 	return 0;
 }
 
+/*
+ * For nfsd purposes, we treat V4ROOT exports as though there was an
+ * export at *every* directory.
+ */
+static int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
+{
+	if (d_mountpoint(dentry))
+		return 1;
+	if (!(exp->ex_flags & NFSEXP_V4ROOT))
+		return 0;
+	return dentry->d_inode != NULL;
+}
+
 __be32
 nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		   const char *name, unsigned int len,
@@ -229,7 +242,7 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		/*
 		 * check if we have crossed a mount point ...
 		 */
-		if (d_mountpoint(dentry)) {
+		if (nfsd_mountpoint(dentry, exp)) {
 			if ((host_err = nfsd_cross_mnt(rqstp, &dentry, &exp))) {
 				dput(dentry);
 				goto out_nfserr;
-- 
1.6.3.3

