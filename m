Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50814 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479Ab3IGSqL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 14:46:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] dcache: make __d_shrink callers check d_unhashed()
Date: Sat,  7 Sep 2013 14:45:59 -0400
Message-Id: <1378579561-26868-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1378579561-26868-1-git-send-email-bfields@redhat.com>
References: <1378579561-26868-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

__d_shrink only has two callers, one of whom already does the check, so
may as well make this the caller's responsibility.

Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/dcache.c |   33 ++++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 7208b38..d9e4fba 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -391,23 +391,21 @@ static struct dentry *d_kill(struct dentry *dentry, struct dentry *parent)
  */
 static void __d_shrink(struct dentry *dentry)
 {
-	if (!d_unhashed(dentry)) {
-		struct hlist_bl_head *b;
-		/*
-		 * Hashed dentries are normally on the dentry hashtable,
-		 * with the exception of those newly allocated by
-		 * d_obtain_alias, which are always IS_ROOT:
-		 */
-		if (unlikely(IS_ROOT(dentry)))
-			b = &dentry->d_sb->s_anon;
-		else
-			b = d_hash(dentry->d_parent, dentry->d_name.hash);
+	struct hlist_bl_head *b;
+	/*
+	 * Hashed dentries are normally on the dentry hashtable,
+	 * with the exception of those newly allocated by
+	 * d_obtain_alias, which are always IS_ROOT:
+	 */
+	if (unlikely(IS_ROOT(dentry)))
+		b = &dentry->d_sb->s_anon;
+	else
+		b = d_hash(dentry->d_parent, dentry->d_name.hash);
 
-		hlist_bl_lock(b);
-		__hlist_bl_del(&dentry->d_hash);
-		dentry->d_hash.pprev = NULL;
-		hlist_bl_unlock(b);
-	}
+	hlist_bl_lock(b);
+	__hlist_bl_del(&dentry->d_hash);
+	dentry->d_hash.pprev = NULL;
+	hlist_bl_unlock(b);
 }
 
 /**
@@ -905,7 +903,8 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 				dentry->d_op->d_prune(dentry);
 
 			dentry_lru_del(dentry);
-			__d_shrink(dentry);
+			if (!d_unhashed(dentry))
+				__d_shrink(dentry);
 
 			if (dentry->d_lockref.count != 0) {
 				printk(KERN_ERR
-- 
1.7.9.5

