From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/7] nfsd4: don't continue "under" mounts in V4ROOT case
Date: Tue,  1 Dec 2009 19:39:38 -0500
Message-ID: <1259714383-32577-3-git-send-email-bfields@citi.umich.edu>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu>
 <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
Cc: Steve Dickson <steved@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897AbZLBAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2009 19:38:42 -0500
In-Reply-To: <1259714383-32577-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If /A/mount/point/ has filesystem "B" mounted on top of it, and if "A"
is exported, but not "B", then the nfs server has always returned to the
client a filehandle for the mountpoint, instead of for the root of "B",
allowing the client to see the subtree of "A" that would otherwise be
hidden by B.

Disable this behavior in the case of V4ROOT exports; we implement the
path restrictions of V4ROOT exports by treating *every* directory as if
it were a mountpoint, and allowing traversal *only* if the new directory
is exported.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a7038ed..04d61c8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -117,8 +117,16 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 
 	exp2 = rqst_exp_get_by_name(rqstp, &path);
 	if (IS_ERR(exp2)) {
-		if (PTR_ERR(exp2) != -ENOENT)
-			err = PTR_ERR(exp2);
+		err = PTR_ERR(exp2);
+		/*
+		 * We normally allow NFS clients to continue
+		 * "underneath" a mountpoint that is not exported.
+		 * The exception is V4ROOT, where no traversal is ever
+		 * allowed without an explicit export of the new
+		 * directory.
+		 */
+		if (err == -ENOENT && !(exp->ex_flags & NFSEXP_V4ROOT))
+			err = 0;
 		path_put(&path);
 		goto out;
 	}
-- 
1.6.3.3

