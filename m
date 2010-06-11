From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 25/26] pnfs-submit: Revert "pnfs: pnfs_redirty_request"
Date: Fri, 11 Jun 2010 03:31:52 -0400
Message-ID: <1276241513-17942-26-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
 <1276241513-17942-11-git-send-email-iisaman@netapp.com>
 <1276241513-17942-12-git-send-email-iisaman@netapp.com>
 <1276241513-17942-13-git-send-email-iisaman@netapp.com>
 <1276241513-17942-14-git-send-email-iisaman@netapp.com>
 <1276241513-17942-15-git-send-email-iisaman@netapp.com>
 <1276241513-17942-16-git-send-email-iisaman@netapp.com>
 <1276241513-17942-17-git-send-email-iisaman@netapp.com>
 <1276241513-17942-18-git-send-email-iisaman@netapp.com>
 <1276241513-17942-19-git-send-email-iisaman@netapp.com>
 <1276241513-17942-20-git-send-email-iisaman@netapp.com>
 <1276241513-17942-21-git-send-email-iisaman@netapp.com>
 <1276241513-17942-22-git-send-email-iisaman@netapp.com>
 <1276241513-17942-23-git-send-email-iisaman@netapp.com>
 <1276241513-17942-24-git-send-email-iisaman@netapp.com>
 <1276241513-17942-25-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755069Ab0FKHcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:41 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3uI024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:40 -0700 (PDT)
In-Reply-To: <1276241513-17942-25-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The existance of req->wb_lseg can take the place of PG_USE_PNFS

This reverts commit 447b65adcc53ab21e76ce8795827df7d4c165af1.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.h            |    9 ---------
 fs/nfs/write.c           |    2 +-
 include/linux/nfs_page.h |    1 -
 3 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 09de7a3..541e3fd 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -154,11 +154,6 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return ret;
 }
 
-static inline void pnfs_redirty_request(struct nfs_page *req)
-{
-	clear_bit(PG_USE_PNFS, &req->wb_flags);
-}
-
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct nfs4_pnfs_layout_segment *lseg,
 				     const nfs4_stateid *stateid, /* optional */
@@ -248,10 +243,6 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-static inline void pnfs_redirty_request(struct nfs_page *req)
-{
-}
-
 static inline int pnfs_get_write_status(struct nfs_write_data *data)
 {
 	return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f1e4120..65e2c62 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -903,7 +903,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
 
-	pnfs_redirty_request(req);
+	nfs_mark_request_nopnfs(req);
 	nfs_mark_request_dirty(req);
 	nfs_clear_page_tag_locked(req);
 	nfs_end_page_writeback(page);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 06e5157..7709d3e 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -32,7 +32,6 @@ enum {
 	PG_CLEAN,
 	PG_NEED_COMMIT,
 	PG_NEED_RESCHED,
-	PG_USE_PNFS,
 };
 
 struct nfs_inode;
-- 
1.6.6.1

