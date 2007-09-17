From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/7] knfsd: only set ATTR_KILL_S*ID if ATTR_MODE isn't being explicitly set
Date: Mon, 17 Sep 2007 07:29:16 -0400
Message-ID: <200709171129.l8HBTGi2024370@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net,
	ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org, unionfs@filesystems.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

It's theoretically possible for a single SETATTR call to come in that
sets the mode and the uid/gid. In that case, don't set the ATTR_KILL_S*ID
bits since that would trip the BUG() in notify_change. Just fix up the
mode to have the same effect.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 70f2c86..3c188fc 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -369,14 +369,23 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (iap->ia_valid & ATTR_MODE) {
 		iap->ia_mode &= S_IALLUGO;
 		imode = iap->ia_mode |= (imode & ~S_IALLUGO);
+		/* if changing uid/gid revoke setuid/setgid in mode */
+		if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) {
+			iap->ia_valid |= ATTR_KILL_PRIV;
+			iap->ia_mode &= ~S_ISUID;
+		}
+		if ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)
+			iap->ia_mode &= ~S_ISGID;
+	} else {
+		/*
+		 * Revoke setuid/setgid bit on chown/chgrp
+		 */
+		if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid)
+			iap->ia_valid |= ATTR_KILL_SUID | ATTR_KILL_PRIV;
+		if ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)
+			iap->ia_valid |= ATTR_KILL_SGID;
 	}
 
-	/* Revoke setuid/setgid bit on chown/chgrp */
-	if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid)
-		iap->ia_valid |= ATTR_KILL_SUID | ATTR_KILL_PRIV;
-	if ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)
-		iap->ia_valid |= ATTR_KILL_SGID;
-
 	/* Change the attributes. */
 
 	iap->ia_valid |= ATTR_CTIME;
-- 
1.5.2.1

