Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34647 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbdHCNqC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:02 -0400
Received: by mail-it0-f68.google.com with SMTP id t78so1321164ita.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 22/28] NFS: Use an atomic_long_t to count the number of requests
Date: Thu,  3 Aug 2017 09:45:17 -0400
Message-Id: <20170803134523.4922-23-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-22-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rather than forcing us to take the inode->i_lock just in order to bump
the number.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c |  2 +-
 fs/nfs/delegation.c    |  2 +-
 fs/nfs/inode.c         |  7 +++----
 fs/nfs/pagelist.c      |  4 +---
 fs/nfs/write.c         | 18 +++++-------------
 include/linux/nfs_fs.h |  4 ++--
 6 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 5427cdf04c5a..14358de173fb 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -51,7 +51,7 @@ __be32 nfs4_callback_getattr(void *argp, void *resp,
 		goto out_iput;
 	res->size = i_size_read(inode);
 	res->change_attr = delegation->change_attr;
-	if (nfsi->nrequests != 0)
+	if (nfs_have_writebacks(inode))
 		res->change_attr++;
 	res->ctime = inode->i_ctime;
 	res->mtime = inode->i_mtime;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index d7df5e67b0c1..606dd3871f66 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -1089,7 +1089,7 @@ bool nfs4_delegation_flush_on_close(const struct inode *inode)
 	delegation = rcu_dereference(nfsi->delegation);
 	if (delegation == NULL || !(delegation->type & FMODE_WRITE))
 		goto out;
-	if (nfsi->nrequests < delegation->pagemod_limit)
+	if (atomic_long_read(&nfsi->nrequests) < delegation->pagemod_limit)
 		ret = false;
 out:
 	rcu_read_unlock();
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 34d9ebbc0dfd..0480eb02299a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1285,7 +1285,6 @@ static bool nfs_file_has_buffered_writers(struct nfs_inode *nfsi)
 
 static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
 	unsigned long ret = 0;
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECHANGE)
@@ -1315,7 +1314,7 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
 			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			&& i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size)
-			&& nfsi->nrequests == 0) {
+			&& !nfs_have_writebacks(inode)) {
 		i_size_write(inode, nfs_size_to_loff_t(fattr->size));
 		ret |= NFS_INO_INVALID_ATTR;
 	}
@@ -1823,7 +1822,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (new_isize != cur_isize) {
 			/* Do we perhaps have any outstanding writes, or has
 			 * the file grown beyond our last write? */
-			if (nfsi->nrequests == 0 || new_isize > cur_isize) {
+			if (!nfs_have_writebacks(inode) || new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				if (!have_writers)
 					invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
@@ -2012,7 +2011,7 @@ static void init_once(void *foo)
 	INIT_LIST_HEAD(&nfsi->access_cache_entry_lru);
 	INIT_LIST_HEAD(&nfsi->access_cache_inode_lru);
 	INIT_LIST_HEAD(&nfsi->commit_info.list);
-	nfsi->nrequests = 0;
+	atomic_long_set(&nfsi->nrequests, 0);
 	nfsi->commit_info.ncommit = 0;
 	atomic_set(&nfsi->commit_info.rpcs_out, 0);
 	init_rwsem(&nfsi->rmdir_sem);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index af6731dd4324..ec97c301899b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -258,9 +258,7 @@ nfs_page_group_init(struct nfs_page *req, struct nfs_page *prev)
 			inode = page_file_mapping(req->wb_page)->host;
 			set_bit(PG_INODE_REF, &req->wb_flags);
 			kref_get(&req->wb_kref);
-			spin_lock(&inode->i_lock);
-			NFS_I(inode)->nrequests++;
-			spin_unlock(&inode->i_lock);
+			atomic_long_inc(&NFS_I(inode)->nrequests);
 		}
 	}
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5ab5ca24b48a..08093552f115 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -434,9 +434,7 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 
 		if (test_and_clear_bit(PG_INODE_REF, &subreq->wb_flags)) {
 			nfs_release_request(subreq);
-			spin_lock(&inode->i_lock);
-			NFS_I(inode)->nrequests--;
-			spin_unlock(&inode->i_lock);
+			atomic_long_dec(&NFS_I(inode)->nrequests);
 		}
 
 		/* subreq is now totally disconnected from page group or any
@@ -567,9 +565,7 @@ nfs_lock_and_join_requests(struct page *page)
 	if (test_and_clear_bit(PG_REMOVE, &head->wb_flags)) {
 		set_bit(PG_INODE_REF, &head->wb_flags);
 		kref_get(&head->wb_kref);
-		spin_lock(&inode->i_lock);
-		NFS_I(inode)->nrequests++;
-		spin_unlock(&inode->i_lock);
+		atomic_long_inc(&NFS_I(inode)->nrequests);
 	}
 
 	nfs_page_group_unlock(head);
@@ -755,7 +751,7 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	nfs_lock_request(req);
 
 	spin_lock(&inode->i_lock);
-	if (!nfsi->nrequests &&
+	if (!nfs_have_writebacks(inode) &&
 	    NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
 		inode->i_version++;
 	/*
@@ -767,7 +763,7 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 		SetPagePrivate(req->wb_page);
 		set_page_private(req->wb_page, (unsigned long)req);
 	}
-	nfsi->nrequests++;
+	atomic_long_inc(&nfsi->nrequests);
 	/* this a head request for a page group - mark it as having an
 	 * extra reference so sub groups can follow suit.
 	 * This flag also informs pgio layer when to bump nrequests when
@@ -786,6 +782,7 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page *head;
 
+	atomic_long_dec(&nfsi->nrequests);
 	if (nfs_page_group_sync_on_bit(req, PG_REMOVE)) {
 		head = req->wb_head;
 
@@ -795,11 +792,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 			ClearPagePrivate(head->wb_page);
 			clear_bit(PG_MAPPED, &head->wb_flags);
 		}
-		nfsi->nrequests--;
-		spin_unlock(&inode->i_lock);
-	} else {
-		spin_lock(&inode->i_lock);
-		nfsi->nrequests--;
 		spin_unlock(&inode->i_lock);
 	}
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 121a702888b4..238fdc4c46df 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -154,7 +154,7 @@ struct nfs_inode {
 	 */
 	__be32			cookieverf[2];
 
-	unsigned long		nrequests;
+	atomic_long_t		nrequests;
 	struct nfs_mds_commit_info commit_info;
 
 	/* Open contexts for shared mmap writes */
@@ -511,7 +511,7 @@ extern void nfs_commit_free(struct nfs_commit_data *data);
 static inline int
 nfs_have_writebacks(struct inode *inode)
 {
-	return NFS_I(inode)->nrequests != 0;
+	return atomic_long_read(&NFS_I(inode)->nrequests) != 0;
 }
 
 /*
-- 
2.13.3

