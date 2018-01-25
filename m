Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751045AbeAYOg1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Jan 2018 09:36:27 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trondmy@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pnfs/blocklayout: pnfs_block_dev_map uses bytes, not sectors
Date: Thu, 25 Jan 2018 09:36:25 -0500
Message-Id: <03d5c8ee208f21b89a8d8ae9c7b8d15d9f7cd277.1516887234.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixup the field types to match their use.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/blocklayout/blocklayout.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index efc007f00742..716bc75e9ed2 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -92,10 +92,9 @@ struct pnfs_block_volume {
 };
 
 struct pnfs_block_dev_map {
-	sector_t			start;
-	sector_t			len;
-
-	sector_t			disk_offset;
+	u64			start;
+	u64			len;
+	u64			disk_offset;
 	struct block_device		*bdev;
 };
 
-- 
2.9.3

