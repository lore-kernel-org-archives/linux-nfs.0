Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50194 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab3JYUai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/8] exportfs: better variable name
Date: Fri, 25 Oct 2013 16:30:04 -0400
Message-Id: <1382733005-6006-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Replace another unhelpful acronym.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index d32ead9..b33b9c4 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -228,14 +228,14 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 	int err = -ESTALE;
 
 	while (target_dir->d_flags & DCACHE_DISCONNECTED) {
-		struct dentry *pd = find_disconnected_root(target_dir);
+		struct dentry *dentry = find_disconnected_root(target_dir);
 
-		BUG_ON(pd == mnt->mnt_sb->s_root);
+		BUG_ON(dentry == mnt->mnt_sb->s_root);
 
-		if (!IS_ROOT(pd)) {
+		if (!IS_ROOT(dentry)) {
 			/* must have found a connected parent - great */
 			clear_disconnected(target_dir);
-			dput(pd);
+			dput(dentry);
 			break;
 		} else {
 			struct dentry *parent;
@@ -243,7 +243,7 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			 * We have hit the top of a disconnected path, try to
 			 * find parent and connect.
 			 */
-			 parent = reconnect_one(mnt, pd, nbuf);
+			 parent = reconnect_one(mnt, dentry, nbuf);
 			 if (!parent)
 				goto out_reconnected;
 			if (IS_ERR(parent)) {
@@ -252,7 +252,7 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			}
 			dput(parent);
 		}
-		dput(pd);
+		dput(dentry);
 	}
 
 	if (target_dir->d_flags & DCACHE_DISCONNECTED) {
-- 
1.7.9.5

