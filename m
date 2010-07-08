From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/4] pnfs-submit: Remove offset and count arguments from pnfs_update_layout
Date: Thu,  8 Jul 2010 15:25:21 -0400
Message-ID: <1278617122-24164-4-git-send-email-iisaman@netapp.com>
References: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
 <1278617122-24164-2-git-send-email-iisaman@netapp.com>
 <1278617122-24164-3-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22871 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758517Ab0GHTZ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 15:25:27 -0400
Received: from localhost.localdomain (khang-lxp.hq.netapp.com [10.58.60.105] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o68JPOdN010802
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jul 2010 12:25:27 -0700 (PDT)
In-Reply-To: <1278617122-24164-3-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They are not needed since we only use whole file layouts.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c |    2 +-
 fs/nfs/pnfs.c |    5 +----
 fs/nfs/pnfs.h |    8 ++++----
 fs/nfs/read.c |    2 +-
 4 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3066141..d86d74f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -399,7 +399,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 
 	pnfs_update_layout(mapping->host,
 			   nfs_file_open_context(file),
-			   0, NFS4_MAX_UINT64, IOMODE_RW,
+			   IOMODE_RW,
 			   &lseg);
 start:
 	/*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a3b934d..9f37cb9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -976,8 +976,6 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 void
 _pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
-		   loff_t pos,
-		   u64 count,
 		   enum pnfs_iomode iomode,
 		   struct pnfs_layout_segment **lsegpp)
 {
@@ -1263,8 +1261,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	if (!pnfs_enabled_sb(nfss))
 		return;
 
-	_pnfs_update_layout(inode, ctx, 0, NFS4_MAX_UINT64, IOMODE_READ,
-			    &pgio->pg_lseg);
+	_pnfs_update_layout(inode, ctx, IOMODE_READ, &pgio->pg_lseg);
 	if (!pgio->pg_lseg)
 		return;
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c60eff6..507b9ee 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -34,7 +34,7 @@ extern const nfs4_stateid zero_stateid;
 
 void put_lseg(struct pnfs_layout_segment *lseg);
 void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-	loff_t pos, u64 count, enum pnfs_iomode access_type,
+	enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
@@ -175,13 +175,13 @@ static inline int pnfs_return_layout(struct inode *ino,
 
 static inline void pnfs_update_layout(struct inode *ino,
 	struct nfs_open_context *ctx,
-	loff_t pos, u64 count, enum pnfs_iomode access_type,
+	enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
 {
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss))
-		_pnfs_update_layout(ino, ctx, pos, count, access_type, lsegpp);
+		_pnfs_update_layout(ino, ctx, access_type, lsegpp);
 	else {
 		if (lsegpp)
 			*lsegpp = NULL;
@@ -200,7 +200,7 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 
 static inline void
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-	loff_t pos, u64 count, enum pnfs_iomode access_type,
+	enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
 {
 	if (lsegpp)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 5a6258e..3fb3663 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -126,7 +126,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	pnfs_update_layout(inode, ctx, 0, NFS4_MAX_UINT64, IOMODE_READ, &lseg);
+	pnfs_update_layout(inode, ctx, IOMODE_READ, &lseg);
 	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
 	put_lseg(lseg);
 	if (IS_ERR(new)) {
-- 
1.6.6.1

