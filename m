Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50067 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754633Ab2EaBuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 21:50:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/6] vfs: fix outdated i_mutex_lock_class documentation
Date: Wed, 30 May 2012 21:50:12 -0400
Message-Id: <1338429016-20119-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1338429016-20119-1-git-send-email-bfields@redhat.com>
References: <1338429016-20119-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/fs.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 038076b..5584a29 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -861,7 +861,8 @@ static inline int inode_unhashed(struct inode *inode)
  * 0: the object of the current VFS operation
  * 1: parent
  * 2: child/target
- * 3: quota file
+ * 3: xattr
+ * 4: quota file
  *
  * The locking order between these classes is
  * parent -> child -> normal -> xattr -> quota
-- 
1.7.9.5

