Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59102 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818Ab1IUO62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 10:58:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/6] leases: break read leases on link
Date: Wed, 21 Sep 2011 10:58:17 -0400
Message-Id: <1316617097-21384-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1316617097-21384-1-git-send-email-bfields@redhat.com>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index c0220f7..f6de42d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2904,8 +2904,11 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	/* Make sure we don't allow creating hardlink to an unlinked file */
 	if (inode->i_nlink == 0)
 		error =  -ENOENT;
-	else
-		error = dir->i_op->link(old_dentry, dir, new_dentry);
+	else {
+		error = break_lease(inode, O_WRONLY);
+		if (!error)
+			error = dir->i_op->link(old_dentry, dir, new_dentry);
+	}
 	mutex_unlock(&inode->i_mutex);
 	if (!error)
 		fsnotify_link(dir, inode, new_dentry);
-- 
1.7.4.1

