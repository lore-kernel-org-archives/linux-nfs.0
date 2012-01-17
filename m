Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50562 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754977Ab2AQQAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:00:33 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [RFC PATCH 6/6] locks: break delegations on link
Date: Tue, 17 Jan 2012 11:00:29 -0500
Message-Id: <1326816029-13913-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1326816029-13913-1-git-send-email-bfields@redhat.com>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index facf295..1607e5e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2919,8 +2919,11 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	/* Make sure we don't allow creating hardlink to an unlinked file */
 	if (inode->i_nlink == 0)
 		error =  -ENOENT;
-	else
-		error = dir->i_op->link(old_dentry, dir, new_dentry);
+	else {
+		error = break_lease(inode, BREAK_ONLY_DELEGS|BREAK_ALL_LEASES);
+		if (!error)
+			error = dir->i_op->link(old_dentry, dir, new_dentry);
+	}
 	mutex_unlock(&inode->i_mutex);
 	if (!error)
 		fsnotify_link(dir, inode, new_dentry);
-- 
1.7.5.4

