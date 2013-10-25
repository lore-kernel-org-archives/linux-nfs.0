Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50184 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab3JYUah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:37 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/8] exportfs: more detailed comment for path_reconnect
Date: Fri, 25 Oct 2013 16:29:59 -0400
Message-Id: <1382733005-6006-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 6d0a7fa..87e6dca 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -93,7 +93,19 @@ find_disconnected_root(struct dentry *dentry)
 /*
  * Make sure target_dir is fully connected to the dentry tree.
  *
- * It may already be, as the flag isn't always updated when connection happens.
+ * On successful return, DCACHE_DISCONNECTED will be cleared on
+ * target_dir, and target_dir->d_parent->...->d_parent will reach the
+ * root of the filesystem.
+ *
+ * Whenever DCACHE_DISCONNECTED is unset, target_dir is fully connected.
+ * But the converse is not true: target_dir may have DCACHE_DISCONNECTED
+ * set but already be connected.  In that case we'll verify the
+ * connection to root and then clear the flag.
+ *
+ * Note that target_dir could be removed by a concurrent operation.  In
+ * that case reconnect_path may still succeed with target_dir fully
+ * connected, but further operations using the filehandle will fail when
+ * necessary (due to S_DEAD being set on the directory).
  */
 static int
 reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
-- 
1.7.9.5

