From: Jan Kara <jack@suse.cz>
Subject: [PATCH] nfsd: Use lowercase names of quota functions
Date: Mon,  9 Feb 2009 22:30:51 +0100
Message-ID: <1234215051-10809-1-git-send-email-jack@suse.cz>
Cc: Jan Kara <jack@suse.cz>, bfields@fieldses.org, neilb@suse.de
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42651 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754205AbZBIVax (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2009 16:30:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use lowercase names of quota functions instead of old uppercase ones.

CC: bfields@fieldses.org
CC: neilb@suse.de
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfsd/vfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6e50aaa..ad38fc9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -356,7 +356,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 			put_write_access(inode);
 			goto out_nfserr;
 		}
-		DQUOT_INIT(inode);
+		vfs_dq_init(inode);
 	}
 
 	/* sanitize the mode change */
@@ -723,7 +723,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 		else
 			flags = O_WRONLY|O_LARGEFILE;
 
-		DQUOT_INIT(inode);
+		vfs_dq_init(inode);
 	}
 	*filp = dentry_open(dget(dentry), mntget(fhp->fh_export->ex_path.mnt),
 			    flags, cred);
-- 
1.6.0.2

