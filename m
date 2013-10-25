Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50198 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753474Ab3JYUaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/8] exportfs: clear DISCONNECTED on all parents sooner
Date: Fri, 25 Oct 2013 16:30:00 -0400
Message-Id: <1382733005-6006-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we've found any connected parent, we know all our parents are
connected--that's true even if there's a concurrent rename.  May as well
clear them all at once and be done with it.

Reviewed-by: Cristoph Hellwig <hch@lst.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 87e6dca..c65b748 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -90,6 +90,24 @@ find_disconnected_root(struct dentry *dentry)
 	return dentry;
 }
 
+static void clear_disconnected(struct dentry *dentry)
+{
+	dget(dentry);
+	while (dentry->d_flags & DCACHE_DISCONNECTED) {
+		struct dentry *parent = dget_parent(dentry);
+
+		WARN_ON_ONCE(IS_ROOT(dentry));
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
@@ -128,10 +146,9 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 
 		if (!IS_ROOT(pd)) {
 			/* must have found a connected parent - great */
-			spin_lock(&pd->d_lock);
-			pd->d_flags &= ~DCACHE_DISCONNECTED;
-			spin_unlock(&pd->d_lock);
-			noprogress = 0;
+			clear_disconnected(target_dir);
+			dput(pd);
+			break;
 		} else {
 			/*
 			 * We have hit the top of a disconnected path, try to
-- 
1.7.9.5

