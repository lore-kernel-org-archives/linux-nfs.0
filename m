Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:25686 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198Ab1GOHrL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 03:47:11 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Date: Fri, 15 Jul 2011 03:33:42 -0400
Subject: [PATCH] NFS: fix return value of nfs_pagein_one/nfs_flush_one
Message-ID: <F19688880B763E40B28B2B462677FBF805BEFF0EF1@MX09A.corp.emc.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
This applies to Trond's nfs-for-next branch. Should some minor typos.
 fs/nfs/read.c  |    3 ++-
 fs/nfs/write.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 1472933..7cba228 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -342,12 +342,13 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *
 	struct page		**pages;
 	struct nfs_read_data	*data;
 	struct list_head *head = &desc->pg_list;
-	int ret = -ENOMEM;
+	int ret = 0;
 
 	data = nfs_readdata_alloc(nfs_page_array_len(desc->pg_base,
 						     desc->pg_count));
 	if (!data) {
 		nfs_async_read_error(head);
+		ret = -ENOMEM;
 		goto out;
 	}
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 525fb02..9fba527 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -992,7 +992,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 	struct page		**pages;
 	struct nfs_write_data	*data;
 	struct list_head *head = &desc->pg_list;
-	int ret;
+	int ret = 0;
 
 	data = nfs_writedata_alloc(nfs_page_array_len(desc->pg_base,
 						      desc->pg_count));
-- 
1.7.4.2

