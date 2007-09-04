From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/7] ecryptfs: allow lower fs to interpret ATTR_KILL_S*ID
Date: Tue, 4 Sep 2007 10:37:24 -0400
Message-ID: <200709041437.l84EbOwL010017@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net,
	ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org, unionfs@filesystems.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Make sure ecryptfs doesn't trip the BUG() in notify_change. This also
allows the lower filesystem to interpret these bits in their own way.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ecryptfs/inode.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index 131954b..dac4199 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -959,6 +959,14 @@ static int ecryptfs_setattr(struct dentry *dentry, struct iattr *ia)
 		if (rc < 0)
 			goto out;
 	}
+
+	/*
+	 * mode change is for clearing setuid/setgid bits. Allow lower fs
+	 * to interpret this in its own way.
+	 */
+	if (ia->ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
+		ia->ia_valid &= ~ATTR_MODE;
+
 	rc = notify_change(lower_dentry, ia);
 out:
 	fsstack_copy_attr_all(inode, lower_inode, NULL);
-- 
1.5.2.1

