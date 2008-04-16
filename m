From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] knfsd: get rid of imode variable in nfsd_setattr
Date: Wed, 16 Apr 2008 16:28:46 -0400
Message-ID: <1208377727-22834-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbYDPU2v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 16:28:51 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...it's not really needed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 17ac51b..dd4dcb4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -264,7 +264,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	struct inode	*inode;
 	int		accmode = MAY_SATTR;
 	int		ftype = 0;
-	int		imode;
 	__be32		err;
 	int		host_err;
 	int		size_change = 0;
@@ -360,10 +359,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 		DQUOT_INIT(inode);
 	}
 
-	imode = inode->i_mode;
 	if (iap->ia_valid & ATTR_MODE) {
 		iap->ia_mode &= S_IALLUGO;
-		imode = iap->ia_mode |= (imode & ~S_IALLUGO);
+		iap->ia_mode |= (inode->i_mode & ~S_IALLUGO);
 		/* if changing uid/gid revoke setuid/setgid in mode */
 		if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) {
 			iap->ia_valid |= ATTR_KILL_PRIV;
-- 
1.5.3.6

