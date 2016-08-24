Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39636 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754589AbcHXR1L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Aug 2016 13:27:11 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Scott Mayhew <smayhew@redhat.com>
Subject: [PATCH] NFS: Don't invalidate directory mapping until attributes expire
Date: Wed, 24 Aug 2016 13:27:09 -0400
Message-Id: <67cfa1f7f028229bfd4b1ac2619bc85b9e34ef7f.1472059583.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 311324ad1713666a6e803aecf0d4e1a136a5b34a ("NFS: Be more aggressive
in using readdirplus for 'ls -l' situations") removed the optimization
added by commit 07b5ce8ef2d87f1914054804720d6facbaa3f4ce ("NFS: Make nfs_readdir
revalidate less often") to bypass the revalidation of the directory mapping
on subsequent calls into nfs_readdir().  Add that optimization back here.

A directory modified once every second and containing 40k entries takes my
system around 80 seconds to list.  With this patch, that time is reduced to
7 seconds.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 19d93d0cd400..9a036dc6caa3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -872,17 +872,6 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc)
 	goto out;
 }
 
-static bool nfs_dir_mapping_need_revalidate(struct inode *dir)
-{
-	struct nfs_inode *nfsi = NFS_I(dir);
-
-	if (nfs_attribute_cache_expired(dir))
-		return true;
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
-		return true;
-	return false;
-}
-
 /* The file offset position represents the dirent entry number.  A
    last cookie cache takes care of the common case of reading the
    whole directory.
@@ -914,7 +903,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
 
-	if (ctx->pos == 0 || nfs_dir_mapping_need_revalidate(inode))
+	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
 		res = nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
 		goto out;
-- 
2.5.5

