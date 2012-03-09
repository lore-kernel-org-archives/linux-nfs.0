Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756909Ab2CIW3h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 17:29:37 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] locks: break delegations on link
Date: Fri,  9 Mar 2012 17:29:33 -0500
Message-Id: <1331332174-22621-6-git-send-email-bfields@redhat.com>
In-Reply-To: <20120309222114.GA22423@fieldses.org>
References: <20120309222114.GA22423@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 21a1d65..6f1dbfa 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2920,8 +2920,11 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	/* Make sure we don't allow creating hardlink to an unlinked file */
 	if (inode->i_nlink == 0)
 		error =  -ENOENT;
-	else
-		error = dir->i_op->link(old_dentry, dir, new_dentry);
+	else {
+		error = break_deleg(inode, O_WRONLY);
+		if (!error)
+			error = dir->i_op->link(old_dentry, dir, new_dentry);
+	}
 	mutex_unlock(&inode->i_mutex);
 	if (!error)
 		fsnotify_link(dir, inode, new_dentry);
-- 
1.7.5.4

