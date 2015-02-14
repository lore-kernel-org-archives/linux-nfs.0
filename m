Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38085 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496AbbBNCyT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 21:54:19 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so14332396igb.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Feb 2015 18:54:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org, dros@primarydata.com
Subject: [PATCH] NFS: struct nfs_commit_info.lock must always point to inode->i_lock
Date: Fri, 13 Feb 2015 21:54:16 -0500
Message-Id: <1423882456-37662-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 411a99adffb4f (nfs: clear_request_commit while holding i_lock)
assumes that the nfs_commit_info always points to the inode->i_lock.
For historical reasons, that is not the case for O_DIRECT writes.

Cc: Weston Andros Adamson <dros@primarydata.com>
Fixes: 411a99adffb4f ("nfs: clear_request_commit while holding i_lock")
Cc: stable@vger.kernel.org # 3.17.x
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c         | 2 +-
 include/linux/nfs_xdr.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7077521acdf4..e907c8cf732e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -283,7 +283,7 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq)
 {
-	cinfo->lock = &dreq->lock;
+	cinfo->lock = &dreq->inode->i_lock;
 	cinfo->mds = &dreq->mds_cinfo;
 	cinfo->ds = &dreq->ds_cinfo;
 	cinfo->dreq = dreq;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 38d96ba935c2..9a39132fda49 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1351,7 +1351,7 @@ struct nfs_commit_completion_ops {
 };
 
 struct nfs_commit_info {
-	spinlock_t			*lock;
+	spinlock_t			*lock;	/* inode->i_lock */
 	struct nfs_mds_commit_info	*mds;
 	struct pnfs_ds_commit_info	*ds;
 	struct nfs_direct_req		*dreq;	/* O_DIRECT request */
-- 
2.1.0

