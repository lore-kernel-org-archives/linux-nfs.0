Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51260 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933998Ab3JOUkB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 16:40:01 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] exportfs: clear DISCONNECTED on all parents sooner
Date: Tue, 15 Oct 2013 16:39:29 -0400
Message-Id: <1381869574-10662-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1381869574-10662-1-git-send-email-bfields@redhat.com>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we've found any connected parent, we know all our parents are
connected--that's true even if there's a concurrent rename.  May as well
clear them all at once.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index c43fe9b..455b0bb 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -90,6 +90,22 @@ find_disconnected_root(struct dentry *dentry)
 	return dentry;
 }
 
+static void clear_disconnected(struct dentry *dentry)
+{
+	dget(dentry);
+	while (dentry->d_flags & DCACHE_DISCONNECTED) {
+		struct dentry *parent = dget_parent(dentry);
+
+		spin_lock(&dentry->d_lock);
+		dentry->d_flags &= ~DCACHE_DISCONNECTED;
+		spin_unlock(&dentry->d_lock);
+
+		dput(dentry);
+		dentry = parent;
+	}
+	dput(dentry);
+}
+
 /*
  * Make sure target_dir is fully connected to the dentry tree.
  *
@@ -114,15 +130,11 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 
 		if (!IS_ROOT(pd)) {
 			/* must have found a connected parent - great */
-			spin_lock(&pd->d_lock);
-			pd->d_flags &= ~DCACHE_DISCONNECTED;
-			spin_unlock(&pd->d_lock);
+			clear_disconnected(target_dir);
 			noprogress = 0;
 		} else if (pd == mnt->mnt_sb->s_root) {
 			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
-			spin_lock(&pd->d_lock);
-			pd->d_flags &= ~DCACHE_DISCONNECTED;
-			spin_unlock(&pd->d_lock);
+			clear_disconnected(target_dir);
 			noprogress = 0;
 		} else {
 			/*
-- 
1.7.9.5

