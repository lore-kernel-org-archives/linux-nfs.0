From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/7] knfsd: only set ATTR_KILL_S*ID if
	ATTR_MODE isn't being explicitly set
Date: Tue, 4 Sep 2007 10:37:34 -0400
Message-ID: <200709041437.l84EbYPb010022@dantu.rdu.redhat.com>
Cc: nfs@lists.sourceforge.net, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org, ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
Errors-To: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
List-ID: <nfs.lists.sourceforge.net>

It's theoretically possible for a single SETATTR call to come in that
sets the mode and the uid/gid. In that case, assume the mode is
correct and don't set the ATTR_KILL_S*ID bits. Doing so would trip the
BUG() in notify_change.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 70f2c86..3b5b8cf 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -369,14 +369,19 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (iap->ia_valid & ATTR_MODE) {
 		iap->ia_mode &= S_IALLUGO;
 		imode = iap->ia_mode |= (imode & ~S_IALLUGO);
+		if ((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid)
+			iap->ia_valid |= ATTR_KILL_PRIV;
+	} else {
+		/*
+		 * Revoke setuid/setgid bit on chown/chgrp, unless the mode
+		 * is being explicitly set
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
