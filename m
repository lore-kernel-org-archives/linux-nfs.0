Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38258 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756854AbeAIQX6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jan 2018 11:23:58 -0500
Received: by mail-it0-f68.google.com with SMTP id r6so12546263itr.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jan 2018 08:23:57 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] Support statx() mask and query flags parameters
Date: Tue,  9 Jan 2018 11:23:53 -0500
Message-Id: <20180109162353.10698-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support the query flags AT_STATX_FORCE_SYNC by forcing an attribute
revalidation, and AT_STATX_DONT_SYNC by returning cached attributes
only.

Use the mask to optimise away server revalidation for attributes
that are not being requested by the user.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
v2:
 - Respect the attribute cache timeout.
 - Unless AT_STATX_DONT_SYNC is set, we must only return attributes
   that have been duly revalidated.

 fs/nfs/inode.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b112002dbdb2..c2c8bb7755ad 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -735,12 +735,20 @@ int nfs_getattr(const struct path *path, struct kstat *stat,
 		u32 request_mask, unsigned int query_flags)
 {
 	struct inode *inode = d_inode(path->dentry);
-	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
+	struct nfs_server *server = NFS_SERVER(inode);
+	unsigned long cache_validity;
 	int err = 0;
+	bool force_sync = query_flags & AT_STATX_FORCE_SYNC;
+	bool do_update = false;
 
 	trace_nfs_getattr_enter(inode);
+
+	if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync)
+		goto out_no_update;
+
 	/* Flush out writes to the server in order to update c/mtime.  */
-	if (S_ISREG(inode->i_mode)) {
+	if ((request_mask & (STATX_CTIME|STATX_MTIME)) &&
+			S_ISREG(inode->i_mode)) {
 		err = filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
@@ -757,24 +765,41 @@ int nfs_getattr(const struct path *path, struct kstat *stat,
 	 */
 	if ((path->mnt->mnt_flags & MNT_NOATIME) ||
 	    ((path->mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
-		need_atime = 0;
-
-	if (need_atime || nfs_need_revalidate_inode(inode)) {
-		struct nfs_server *server = NFS_SERVER(inode);
-
+		request_mask &= ~STATX_ATIME;
+
+	/* Is the user requesting attributes that might need revalidation? */
+	if (!(request_mask & (STATX_MODE|STATX_NLINK|STATX_ATIME|STATX_CTIME|
+					STATX_MTIME|STATX_UID|STATX_GID|
+					STATX_SIZE|STATX_BLOCKS)))
+		goto out_no_revalidate;
+
+	/* Check whether the cached attributes are stale */
+	do_update |= force_sync || nfs_attribute_cache_expired(inode);
+	cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
+	do_update |= cache_validity & NFS_INO_INVALID_ATTR;
+	if (request_mask & STATX_ATIME)
+		do_update |= cache_validity & NFS_INO_INVALID_ATIME;
+	if (request_mask & (STATX_CTIME|STATX_MTIME))
+		do_update |= cache_validity & NFS_INO_REVAL_PAGECACHE;
+	if (do_update) {
+		/* Update the attribute cache */
 		if (!(server->flags & NFS_MOUNT_NOAC))
 			nfs_readdirplus_parent_cache_miss(path->dentry);
 		else
 			nfs_readdirplus_parent_cache_hit(path->dentry);
 		err = __nfs_revalidate_inode(server, inode);
+		if (err)
+			goto out;
 	} else
 		nfs_readdirplus_parent_cache_hit(path->dentry);
-	if (!err) {
-		generic_fillattr(inode, stat);
-		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
-		if (S_ISDIR(inode->i_mode))
-			stat->blksize = NFS_SERVER(inode)->dtsize;
-	}
+out_no_revalidate:
+	/* Only return attributes that were revalidated. */
+	stat->result_mask &= request_mask;
+out_no_update:
+	generic_fillattr(inode, stat);
+	stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
+	if (S_ISDIR(inode->i_mode))
+		stat->blksize = NFS_SERVER(inode)->dtsize;
 out:
 	trace_nfs_getattr_exit(inode, err);
 	return err;
-- 
2.14.3

