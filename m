Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35671 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbcBMNv6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Feb 2016 08:51:58 -0500
Received: by mail-pa0-f54.google.com with SMTP id ho8so61653610pac.2
        for <linux-nfs@vger.kernel.org>; Sat, 13 Feb 2016 05:51:58 -0800 (PST)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfs/blocklayout: make sure making a aligned read request
Message-ID: <56BF34E3.1020003@gmail.com>
Date: Sat, 13 Feb 2016 21:51:31 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only treat write goes up to the inode size as aligned request,
because it always write PAGE_CACHE_SIZE, but read a dynamic size.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/blocklayout/blocklayout.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ddd0138..8bc870e 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -743,7 +743,7 @@ bl_set_layoutdriver(struct nfs_server *server, const struct nfs_fh *fh)
 
 static bool
 is_aligned_req(struct nfs_pageio_descriptor *pgio,
-		struct nfs_page *req, unsigned int alignment)
+		struct nfs_page *req, unsigned int alignment, bool is_write)
 {
 	/*
 	 * Always accept buffered writes, higher layers take care of the
@@ -758,7 +758,8 @@ is_aligned_req(struct nfs_pageio_descriptor *pgio,
 	if (IS_ALIGNED(req->wb_bytes, alignment))
 		return true;
 
-	if (req_offset(req) + req->wb_bytes == i_size_read(pgio->pg_inode)) {
+	if (is_write &&
+	    (req_offset(req) + req->wb_bytes == i_size_read(pgio->pg_inode))) {
 		/*
 		 * If the write goes up to the inode size, just write
 		 * the full page.  Data past the inode size is
@@ -775,7 +776,7 @@ is_aligned_req(struct nfs_pageio_descriptor *pgio,
 static void
 bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
-	if (!is_aligned_req(pgio, req, SECTOR_SIZE)) {
+	if (!is_aligned_req(pgio, req, SECTOR_SIZE, false)) {
 		nfs_pageio_reset_read_mds(pgio);
 		return;
 	}
@@ -791,7 +792,7 @@ static size_t
 bl_pg_test_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		struct nfs_page *req)
 {
-	if (!is_aligned_req(pgio, req, SECTOR_SIZE))
+	if (!is_aligned_req(pgio, req, SECTOR_SIZE, false))
 		return 0;
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
@@ -824,7 +825,7 @@ bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	u64 wb_size;
 
-	if (!is_aligned_req(pgio, req, PAGE_SIZE)) {
+	if (!is_aligned_req(pgio, req, PAGE_SIZE, true)) {
 		nfs_pageio_reset_write_mds(pgio);
 		return;
 	}
@@ -846,7 +847,7 @@ static size_t
 bl_pg_test_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		 struct nfs_page *req)
 {
-	if (!is_aligned_req(pgio, req, PAGE_SIZE))
+	if (!is_aligned_req(pgio, req, PAGE_SIZE, true))
 		return 0;
 	return pnfs_generic_pg_test(pgio, prev, req);
 }
-- 
2.5.0

