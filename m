From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 26/26] pnfs-submit: Reorder arguments to pnfs_update_layout
Date: Fri, 11 Jun 2010 03:31:53 -0400
Message-ID: <1276241513-17942-27-git-send-email-iisaman@netapp.com>
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
 <1276241513-17942-26-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758023Ab0FKHcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:42 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3uJ024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:41 -0700 (PDT)
In-Reply-To: <1276241513-17942-26-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

offset and count were switched for some reason.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c |    2 +-
 fs/nfs/pnfs.c |    4 ++--
 fs/nfs/pnfs.h |    8 ++++----
 fs/nfs/read.c |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 409892f..3066141 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -399,7 +399,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 
 	pnfs_update_layout(mapping->host,
 			   nfs_file_open_context(file),
-			   NFS4_MAX_UINT64, 0, IOMODE_RW,
+			   0, NFS4_MAX_UINT64, IOMODE_RW,
 			   &lseg);
 start:
 	/*
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ae76e88..7d322c9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1053,8 +1053,8 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 void
 _pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
-		   u64 count,
 		   loff_t pos,
+		   u64 count,
 		   enum pnfs_iomode iomode,
 		   struct pnfs_layout_segment **lsegpp)
 {
@@ -1371,7 +1371,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	readahead_range(inode, pages, &loff, &count);
 
 	if (count > 0) {
-		_pnfs_update_layout(inode, ctx, count, loff, IOMODE_READ,
+		_pnfs_update_layout(inode, ctx, loff, count, IOMODE_READ,
 				    &pgio->pg_lseg);
 		if (!pgio->pg_lseg)
 			return;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 541e3fd..75f6cf1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -33,7 +33,7 @@ extern const nfs4_stateid zero_stateid;
 
 void put_lseg(struct pnfs_layout_segment *lseg);
 void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-	u64 count, loff_t pos, enum pnfs_iomode access_type,
+	loff_t pos, u64 count, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
@@ -172,13 +172,13 @@ static inline int pnfs_return_layout(struct inode *ino,
 
 static inline void pnfs_update_layout(struct inode *ino,
 	struct nfs_open_context *ctx,
-	u64 count, loff_t pos, enum pnfs_iomode access_type,
+	loff_t pos, u64 count, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
 {
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss))
-		_pnfs_update_layout(ino, ctx, count, pos, access_type, lsegpp);
+		_pnfs_update_layout(ino, ctx, pos, count, access_type, lsegpp);
 	else {
 		if (lsegpp)
 			*lsegpp = NULL;
@@ -215,7 +215,7 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 
 static inline void
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-	u64 count, loff_t pos, enum pnfs_iomode access_type,
+	loff_t pos, u64 count, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp)
 {
 	if (lsegpp)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 68b4ca8..9cabf88 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -126,7 +126,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	pnfs_update_layout(inode, ctx, NFS4_MAX_UINT64, 0, IOMODE_READ, &lseg);
+	pnfs_update_layout(inode, ctx, 0, NFS4_MAX_UINT64, IOMODE_READ, &lseg);
 	new = nfs_create_request(ctx, inode, page, 0, len, lseg);
 	put_lseg(lseg);
 	if (IS_ERR(new)) {
-- 
1.6.6.1

