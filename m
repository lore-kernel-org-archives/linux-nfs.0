From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/12] NFS: Remove requirement for inode->i_mutex from
 nfs_invalidate_mapping
Date: Mon, 25 Jan 2010 17:15:46 -0500
Message-ID: <20100125221546.16750.3970.stgit@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223Ab0AYWjL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:11 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c           |    2 +-
 fs/nfs/inode.c         |   41 +----------------------------------------
 fs/nfs/symlink.c       |    2 +-
 include/linux/nfs_fs.h |    1 -
 4 files changed, 3 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3c7f03b..a1f6b44 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -560,7 +560,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->entry = &my_entry;
 
 	nfs_block_sillyrename(dentry);
-	res = nfs_revalidate_mapping_nolock(inode, filp->f_mapping);
+	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (res < 0)
 		goto out;
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a867c4c..30988bc 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -759,7 +759,7 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	return __nfs_revalidate_inode(server, inode);
 }
 
-static int nfs_invalidate_mapping_nolock(struct inode *inode, struct address_space *mapping)
+static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	
@@ -780,49 +780,10 @@ static int nfs_invalidate_mapping_nolock(struct inode *inode, struct address_spa
 	return 0;
 }
 
-static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
-{
-	int ret = 0;
-
-	mutex_lock(&inode->i_mutex);
-	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_DATA) {
-		ret = nfs_sync_mapping(mapping);
-		if (ret == 0)
-			ret = nfs_invalidate_mapping_nolock(inode, mapping);
-	}
-	mutex_unlock(&inode->i_mutex);
-	return ret;
-}
-
-/**
- * nfs_revalidate_mapping_nolock - Revalidate the pagecache
- * @inode - pointer to host inode
- * @mapping - pointer to mapping
- */
-int nfs_revalidate_mapping_nolock(struct inode *inode, struct address_space *mapping)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	int ret = 0;
-
-	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
-			|| nfs_attribute_timeout(inode) || NFS_STALE(inode)) {
-		ret = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
-		if (ret < 0)
-			goto out;
-	}
-	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
-		ret = nfs_invalidate_mapping_nolock(inode, mapping);
-out:
-	return ret;
-}
-
 /**
  * nfs_revalidate_mapping - Revalidate the pagecache
  * @inode - pointer to host inode
  * @mapping - pointer to mapping
- *
- * This version of the function will take the inode->i_mutex and attempt to
- * flush out all dirty data if it needs to invalidate the page cache.
  */
 int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 412738d..2ea9e5c 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -50,7 +50,7 @@ static void *nfs_follow_link(struct dentry *dentry, struct nameidata *nd)
 	struct page *page;
 	void *err;
 
-	err = ERR_PTR(nfs_revalidate_mapping_nolock(inode, inode->i_mapping));
+	err = ERR_PTR(nfs_revalidate_mapping(inode, inode->i_mapping));
 	if (err)
 		goto read_failed;
 	page = read_cache_page(&inode->i_data, 0,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6ee74c5..896a5f3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -346,7 +346,6 @@ extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
-extern int nfs_revalidate_mapping_nolock(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);
 extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);

