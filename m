Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:45703 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708Ab1FLXpC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:45:02 -0400
Message-Id: <eef50878b5052d94da20ea69b4f5c935122f8611.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:45:00 -0400
Subject: [PATCH 29/34] pnfsblock: bl_write_pagelist support functions
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

[pnfsblock: SQUASHME: adjust to API change]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fixup blksize alignment in bl_setup_layoutcommit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index a40616b..9361e5b 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -70,6 +70,19 @@ static int is_hole(struct pnfs_block_extent *be, sector_t isect)
 		return !is_sector_initialized(be->be_inval, isect);
 }
 
+/* Given the be associated with isect, determine if page data can be
+ * written to disk.
+ */
+static int is_writable(struct pnfs_block_extent *be, sector_t isect)
+{
+	if (be->be_state == PNFS_BLOCK_READWRITE_DATA)
+		return 1;
+	else if (be->be_state != PNFS_BLOCK_INVALID_DATA)
+		return 0;
+	else
+		return is_sector_initialized(be->be_inval, isect);
+}
+
 static int
 dont_like_caller(struct nfs_page *req)
 {
-- 
1.7.4.1

