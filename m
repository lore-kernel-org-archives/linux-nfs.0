From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/15] NFS: Remove BKL requirement from attribute updates
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.98285.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33108 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021AbYFLTtV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:21 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnK1i008536
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:21 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The main problem is dealing with inode->i_size: we need to set the
inode->i_lock on all attribute updates, and so vmtruncate won't cut it.
Make an NFS-private version of vmtruncate that has the necessary locking
semantics.

The result should be that the following inode attribute updates are
protected by inode->i_lock
	nfsi->cache_validity
	nfsi->read_cache_jiffies
	nfsi->attrtimeo
	nfsi->attrtimeo_timestamp
	nfsi->change_attr
	nfsi->last_updated
	nfsi->cache_change_attribute
	nfsi->access_cache
	nfsi->access_cache_entry_lru
	nfsi->access_cache_inode_lru
	nfsi->acl_access
	nfsi->acl_default
	nfsi->nfs_page_tree
	nfsi->ncommit
	nfsi->npages
	nfsi->open_files
	nfsi->silly_list
	nfsi->acl
	nfsi->open_states
	inode->i_size
	inode->i_atime
	inode->i_mtime
	inode->i_ctime
	inode->i_nlink
	inode->i_uid
	inode->i_gid

The following is protected by dir->i_mutex
	nfsi->cookieverf


Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfs/write.c |    2 ++
 2 files changed, 63 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2c23d06..3adabd1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -389,6 +389,62 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 }
 
 /**
+ * nfs_vmtruncate - unmap mappings "freed" by truncate() syscall
+ * @inode: inode of the file used
+ * @offset: file offset to start truncating
+ *
+ * This is a copy of the common vmtruncate, but with the locking
+ * corrected to take into account the fact that NFS requires
+ * inode->i_size to be updated under the inode->i_lock.
+ */
+static int nfs_vmtruncate(struct inode * inode, loff_t offset)
+{
+	if (i_size_read(inode) < offset) {
+		unsigned long limit;
+
+		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
+		if (limit != RLIM_INFINITY && offset > limit)
+			goto out_sig;
+		if (offset > inode->i_sb->s_maxbytes)
+			goto out_big;
+		spin_lock(&inode->i_lock);
+		i_size_write(inode, offset);
+		spin_unlock(&inode->i_lock);
+	} else {
+		struct address_space *mapping = inode->i_mapping;
+
+		/*
+		 * truncation of in-use swapfiles is disallowed - it would
+		 * cause subsequent swapout to scribble on the now-freed
+		 * blocks.
+		 */
+		if (IS_SWAPFILE(inode))
+			return -ETXTBSY;
+		spin_lock(&inode->i_lock);
+		i_size_write(inode, offset);
+		spin_unlock(&inode->i_lock);
+
+		/*
+		 * unmap_mapping_range is called twice, first simply for
+		 * efficiency so that truncate_inode_pages does fewer
+		 * single-page unmaps.  However after this first call, and
+		 * before truncate_inode_pages finishes, it is possible for
+		 * private pages to be COWed, which remain after
+		 * truncate_inode_pages finishes, hence the second
+		 * unmap_mapping_range call must be made for correctness.
+		 */
+		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
+		truncate_inode_pages(mapping, offset);
+		unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
+	}
+	return 0;
+out_sig:
+	send_sig(SIGXFSZ, current, 0);
+out_big:
+	return -EFBIG;
+}
+
+/**
  * nfs_setattr_update_inode - Update inode metadata after a setattr call.
  * @inode: pointer to struct inode
  * @attr: pointer to struct iattr
@@ -414,8 +470,7 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 	}
 	if ((attr->ia_valid & ATTR_SIZE) != 0) {
 		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
-		inode->i_size = attr->ia_size;
-		vmtruncate(inode, attr->ia_size);
+		nfs_vmtruncate(inode, attr->ia_size);
 	}
 }
 
@@ -829,9 +884,9 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			if (S_ISDIR(inode->i_mode))
 				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 		}
-		if (inode->i_size == nfs_size_to_loff_t(fattr->pre_size) &&
+		if (i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size) &&
 		    nfsi->npages == 0)
-			inode->i_size = nfs_size_to_loff_t(fattr->size);
+			i_size_write(inode, nfs_size_to_loff_t(fattr->size));
 	}
 }
 
@@ -972,7 +1027,7 @@ int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fa
 			(fattr->valid & NFS_ATTR_WCC) == 0) {
 		memcpy(&fattr->pre_ctime, &inode->i_ctime, sizeof(fattr->pre_ctime));
 		memcpy(&fattr->pre_mtime, &inode->i_mtime, sizeof(fattr->pre_mtime));
-		fattr->pre_size = inode->i_size;
+		fattr->pre_size = i_size_read(inode);
 		fattr->valid |= NFS_ATTR_WCC;
 	}
 	return nfs_post_op_update_inode(inode, fattr);
@@ -1057,7 +1112,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		/* Do we perhaps have any outstanding writes, or has
 		 * the file grown beyond our last write? */
 		if (nfsi->npages == 0 || new_isize > cur_isize) {
-			inode->i_size = new_isize;
+			i_size_write(inode, new_isize);
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 		}
 		dprintk("NFS: isize change on server for file %s/%ld\n",
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 21d8a48..8f12157 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -145,7 +145,9 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 	if (i_size >= end)
 		return;
 	nfs_inc_stats(inode, NFSIOS_EXTENDWRITE);
+	spin_lock(&inode->i_lock);
 	i_size_write(inode, end);
+	spin_unlock(&inode->i_lock);
 }
 
 /* A writeback failed: mark the page as bad, and invalidate the page cache */

