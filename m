Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51023 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757766Ab2BCVKC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 16:10:02 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/6] locks: break delegations on link
Date: Fri,  3 Feb 2012 16:09:57 -0500
Message-Id: <1328303397-3872-7-git-send-email-bfields@redhat.com>
In-Reply-To: <20120203205818.GE2999@fieldses.org>
References: <20120203205818.GE2999@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 1e0c383..b8f3cbd 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2920,8 +2920,11 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	/* Make sure we don't allow creating hardlink to an unlinked file */
 	if (inode->i_nlink == 0)
 		error =  -ENOENT;
-	else
-		error = dir->i_op->link(old_dentry, dir, new_dentry);
+	else {
+		error = break_lease(inode, BREAK_ONLY_DELEGS|BREAK_R_AND_W_LEASES);
+		if (!error)
+			error = dir->i_op->link(old_dentry, dir, new_dentry);
+	}
 	mutex_unlock(&inode->i_mutex);
 	if (!error)
 		fsnotify_link(dir, inode, new_dentry);
-- 
1.7.5.4

