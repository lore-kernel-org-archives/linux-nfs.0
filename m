From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 8] knfsd: exportfs: untangle ISDIR logic in find_exported_dentry
Date: Tue, 15 May 2007 17:16:36 +1000
Message-ID: <1070515071636.16315@suse.de>
References: <20070515170405.15621.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762056AbXEOHR7@vger.kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Neil Brown <neilb@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


From: Christoph Hellwig <hch@infradead.org>

Rework some logic in find_exported_dentry so that we only have a single
S_ISDIR check and logic that makes clear to the reader what we're really
doing here.


Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/exportfs/expfs.c |   26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff .prev/fs/exportfs/expfs.c ./fs/exportfs/expfs.c
--- .prev/fs/exportfs/expfs.c	2007-05-14 11:15:34.000000000 +1000
+++ ./fs/exportfs/expfs.c	2007-05-14 11:15:37.000000000 +1000
@@ -116,30 +116,23 @@ find_exported_dentry(struct super_block 
 	if (IS_ERR(result))
 		return result;
 
-	if (S_ISDIR(result->d_inode->i_mode) &&
-	    (result->d_flags & DCACHE_DISCONNECTED)) {
-		/* it is an unconnected directory, we must connect it */
-		;
-	} else {
-		if (acceptable(context, result))
-			return result;
-		if (S_ISDIR(result->d_inode->i_mode)) {
+	if (S_ISDIR(result->d_inode->i_mode)) {
+		if (!(result->d_flags & DCACHE_DISCONNECTED)) {
+			if (acceptable(context, result))
+				return result;
 			err = -EACCES;
 			goto err_result;
 		}
 
+		target_dir = dget(result);
+	} else {
+		if (acceptable(context, result))
+			return result;
+
 		alias = find_acceptable_alias(result, acceptable, context);
 		if (alias)
 			return alias;
-	}			
 
-	/* It's a directory, or we are required to confirm the file's
-	 * location in the tree based on the parent information
- 	 */
-	dprintk("find_exported_dentry: need to look harder for %s/%d\n",sb->s_id,*(int*)obj);
-	if (S_ISDIR(result->d_inode->i_mode))
-		target_dir = dget(result);
-	else {
 		if (parent == NULL)
 			goto err_result;
 
@@ -149,6 +142,7 @@ find_exported_dentry(struct super_block 
 			goto err_result;
 		}
 	}
+
 	/*
 	 * Now we need to make sure that target_dir is properly connected.
 	 * It may already be, as the flag isn't always updated when connection
