Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bluewatersys.com ([202.124.120.130]:16141 "EHLO
	hayes.bluewaternz.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753282Ab1C1Bzq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 21:55:46 -0400
From: Ryan Mallon <ryan@bluewatersys.com>
To: viro@zeniv.linux.org.uk, dchinner@redhat.com, Trond.Myklebust@netapp.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Ryan Mallon <ryan@bluewatersys.com>
Subject: [RFC PATCH 1/2] Add unlocked version of igrab.
Date: Mon, 28 Mar 2011 14:56:00 +1300
Message-Id: <1301277361-9453-2-git-send-email-ryan@bluewatersys.com>
In-Reply-To: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com>
References: <1301277361-9453-1-git-send-email-ryan@bluewatersys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commit 250df6ed274d767da844a5d9f05720b804240197 "fs: protect
inode->i_state with inode->i_lock" changes igrab to acquire inode->i_lock,
however some callees, notably nfs_inode_add_request, already hold the lock
when calling igrab.

Introduce an unlocked version of igrab called __igrab which can be
called when inode->i_lock is already held.

Signed-off-by: Ryan Mallon <ryan@bluewatersys.com>
---
 fs/inode.c         |   16 ++++++++++++----
 include/linux/fs.h |    1 +
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 05a1f75..bdcfbba 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1134,14 +1134,11 @@ ino_t iunique(struct super_block *sb, ino_t max_reserved)
 }
 EXPORT_SYMBOL(iunique);
 
-struct inode *igrab(struct inode *inode)
+struct inode *__igrab(struct inode *inode)
 {
-	spin_lock(&inode->i_lock);
 	if (!(inode->i_state & (I_FREEING|I_WILL_FREE))) {
 		__iget(inode);
-		spin_unlock(&inode->i_lock);
 	} else {
-		spin_unlock(&inode->i_lock);
 		/*
 		 * Handle the case where s_op->clear_inode is not been
 		 * called yet, and somebody is calling igrab
@@ -1149,6 +1146,17 @@ struct inode *igrab(struct inode *inode)
 		 */
 		inode = NULL;
 	}
+
+	return inode;
+}
+EXPORT_SYMBOL(__igrab);
+
+struct inode *igrab(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	inode = __igrab(inode);
+	spin_unlock(&inode->i_lock);
+
 	return inode;
 }
 EXPORT_SYMBOL(igrab);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b677bd7..32c4bc5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2240,6 +2240,7 @@ extern void inode_init_once(struct inode *);
 extern void address_space_init_once(struct address_space *mapping);
 extern void ihold(struct inode * inode);
 extern void iput(struct inode *);
+extern struct inode *__igrab(struct inode *inode);
 extern struct inode * igrab(struct inode *);
 extern ino_t iunique(struct super_block *, ino_t);
 extern int inode_needs_sync(struct inode *inode);
-- 
1.7.0.4

