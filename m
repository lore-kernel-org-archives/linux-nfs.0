Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] NFS: Fix a performance regression in readdir
Date: Fri,  2 Dec 2016 09:21:33 -0500
Message-Id: <20161202142135.11515-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161202142135.11515-1-trond.myklebust@primarydata.com>
References: <20161202142135.11515-1-trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

Ben Coddington reports that commit 311324ad1713, by adding the function
nfs_dir_mapping_need_revalidate() that checks page cache validity on
each call to nfs_readdir() causes a performance regression when
the directory is being modified.

If the directory is changing while we're iterating through the directory,
POSIX does not require us to invalidate the page cache unless the user
calls rewinddir(). However, we still do want to ensure that we use
readdirplus in order to avoid a load of stat() calls when the user
is doing an 'ls -l' workload.

The fix should be to invalidate the page cache immediately when we're
setting the NFS_INO_ADVISE_RDPLUS bit.

Reported-by: Benjamin Coddington <bcodding@redhat.com>
Fixes: 311324ad1713 ("NFS: Be more aggressive in using readdirplus...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f1ecfcc632eb..9220bc7b9cd7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -477,7 +477,7 @@ void nfs_force_use_readdirplus(struct inode *dir)
 {
 	if (!list_empty(&NFS_I(dir)->open_files)) {
 		nfs_advise_use_readdirplus(dir);
-		nfs_zap_mapping(dir, dir->i_mapping);
+		invalidate_mapping_pages(dir->i_mapping, 0, -1);
 	}
 }
 
@@ -886,17 +886,6 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc)
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
@@ -928,7 +917,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
 
-	if (ctx->pos == 0 || nfs_dir_mapping_need_revalidate(inode))
+	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
 		res = nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
 		goto out;
-- 
2.9.3
