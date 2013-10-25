Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786Ab3JYUan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/8] exportfs: BUG_ON in crazy corner case
Date: Fri, 25 Oct 2013 16:29:58 -0400
Message-Id: <1382733005-6006-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

This would indicate a nasty bug in the dcache and has never triggered in
the past 10 years as far as I know.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index c43fe9b..6d0a7fa 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -112,18 +112,14 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
 		struct dentry *pd = find_disconnected_root(target_dir);
 
+		BUG_ON(pd == mnt->mnt_sb->s_root);
+
 		if (!IS_ROOT(pd)) {
 			/* must have found a connected parent - great */
 			spin_lock(&pd->d_lock);
 			pd->d_flags &= ~DCACHE_DISCONNECTED;
 			spin_unlock(&pd->d_lock);
 			noprogress = 0;
-		} else if (pd == mnt->mnt_sb->s_root) {
-			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
-			spin_lock(&pd->d_lock);
-			pd->d_flags &= ~DCACHE_DISCONNECTED;
-			spin_unlock(&pd->d_lock);
-			noprogress = 0;
 		} else {
 			/*
 			 * We have hit the top of a disconnected path, try to
-- 
1.7.9.5

