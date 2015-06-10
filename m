Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:27540 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932939AbbFJUyb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jun 2015 16:54:31 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH] NFS: Remove unused nfs_rw_ops->rw_release() function
Date: Wed, 10 Jun 2015 16:54:28 -0400
Message-ID: <1433969668-1685-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was only ever set to nfs_writeback_release_common(), a function
which is completely empty.  Let's just drop this function pointer and
simplify the code a bit.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pagelist.c        | 2 --
 fs/nfs/write.c           | 6 ------
 include/linux/nfs_page.h | 1 -
 3 files changed, 9 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 282b393..e9953ab 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -690,8 +690,6 @@ static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 static void nfs_pgio_release(void *calldata)
 {
 	struct nfs_pgio_header *hdr = calldata;
-	if (hdr->rw_ops->rw_release)
-		hdr->rw_ops->rw_release(hdr);
 	nfs_pgio_data_destroy(hdr);
 	hdr->completion_ops->completion(hdr);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index dfc19f1..d0f1f21 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1347,11 +1347,6 @@ void nfs_commit_prepare(struct rpc_task *task, void *calldata)
 	NFS_PROTO(data->inode)->commit_rpc_prepare(task, data);
 }
 
-static void nfs_writeback_release_common(struct nfs_pgio_header *hdr)
-{
-	/* do nothing! */
-}
-
 /*
  * Special version of should_remove_suid() that ignores capabilities.
  */
@@ -2012,7 +2007,6 @@ static const struct nfs_rw_ops nfs_rw_write_ops = {
 	.rw_mode		= FMODE_WRITE,
 	.rw_alloc_header	= nfs_writehdr_alloc,
 	.rw_free_header		= nfs_writehdr_free,
-	.rw_release		= nfs_writeback_release_common,
 	.rw_done		= nfs_writeback_done,
 	.rw_result		= nfs_writeback_result,
 	.rw_initiate		= nfs_initiate_write,
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 3eb072d..f2f650f 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -67,7 +67,6 @@ struct nfs_rw_ops {
 	const fmode_t rw_mode;
 	struct nfs_pgio_header *(*rw_alloc_header)(void);
 	void (*rw_free_header)(struct nfs_pgio_header *);
-	void (*rw_release)(struct nfs_pgio_header *);
 	int  (*rw_done)(struct rpc_task *, struct nfs_pgio_header *,
 			struct inode *);
 	void (*rw_result)(struct rpc_task *, struct nfs_pgio_header *);
-- 
2.4.2

