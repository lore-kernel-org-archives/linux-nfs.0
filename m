From: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 1/5] Safer nfsd_cross_mnt()
Date: Tue, 21 Apr 2009 21:43:41 +0000
Message-ID: <E1LwNkj-0004WN-AZ@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60956 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbZDUVnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 17:43:42 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1LwNkj-0004WN-AZ
	for linux-nfs@vger.kernel.org; Tue, 21 Apr 2009 21:43:41 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


AFAICS, we have a subtle bug there: if we have crossed mountpoint
*and* it got mount --move'd away, we'll be holding only one
reference to fs containing dentry - exp->ex_path.mnt.  IOW, we
ought to dput() before exp_put().

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfsd/vfs.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ab93fcf..46e6bd2 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -116,10 +116,15 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 	}
 	if ((exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
 		/* successfully crossed mount point */
-		exp_put(exp);
-		*expp = exp2;
+		/*
+		 * This is subtle: dentry is *not* under mnt at this point.
+		 * The only reason we are safe is that original mnt is pinned
+		 * down by exp, so we should dput before putting exp.
+		 */
 		dput(dentry);
 		*dpp = mounts;
+		exp_put(exp);
+		*expp = exp2;
 	} else {
 		exp_put(exp2);
 		dput(mounts);
-- 
1.5.6.5


