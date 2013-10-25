Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753271Ab3JYUaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/8] exportfs: eliminate unused "noprogress" counter
Date: Fri, 25 Oct 2013 16:30:02 -0400
Message-Id: <1382733005-6006-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Note this counter is now being set to 0 on every pass through the loop,
so it no longer serves any useful purpose.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 6b5ddd5..d8ba88a 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -145,18 +145,9 @@ static void clear_disconnected(struct dentry *dentry)
 static int
 reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 {
-	int noprogress = 0;
 	int err = -ESTALE;
 
-	/*
-	 * It is possible that a confused file system might not let us complete
-	 * the path to the root.  For example, if get_parent returns a directory
-	 * in which we cannot find a name for the child.  While this implies a
-	 * very sick filesystem we don't want it to cause knfsd to spin.  Hence
-	 * the noprogress counter.  If we go through the loop 10 times (2 is
-	 * probably enough) without getting anywhere, we just give up
-	 */
-	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
+	while (target_dir->d_flags & DCACHE_DISCONNECTED) {
 		struct dentry *pd = find_disconnected_root(target_dir);
 
 		BUG_ON(pd == mnt->mnt_sb->s_root);
@@ -230,9 +221,7 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			 */
 			dput(npd);
 			dput(ppd);
-			if (npd == pd)
-				noprogress = 0;
-			else
+			if (npd != pd)
 				goto out_reconnected;
 			if (IS_ROOT(pd)) {
 				/* something went wrong, we have to give up */
-- 
1.7.9.5

