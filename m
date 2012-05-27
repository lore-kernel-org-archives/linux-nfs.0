Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60512 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab2E0Fd4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 May 2012 01:33:56 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so3356136pbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 26 May 2012 22:33:55 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@emc.com>
Subject: [PATCH 2/3] pnfsblock: call block plug in bl_dio_begin/end
Date: Sun, 27 May 2012 13:32:59 +0800
Message-Id: <1338096780-2763-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7ae8a60..53cb450 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -996,6 +996,19 @@ bl_clear_layoutdriver(struct nfs_server *server)
 	return 0;
 }
 
+static bool bl_dio_begin(struct inode *inode, const struct iovec *iov,
+			 unsigned long nr_segs, loff_t pos,
+			 struct blk_plug *plug)
+{
+	blk_start_plug(plug);
+	return true;
+}
+
+void bl_dio_end(struct blk_plug *plug)
+{
+	blk_finish_plug(plug);
+}
+
 static const struct nfs_pageio_ops bl_pg_read_ops = {
 	.pg_init = pnfs_generic_pg_init_read,
 	.pg_test = pnfs_generic_pg_test,
@@ -1013,6 +1026,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.name				= "LAYOUT_BLOCK_VOLUME",
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
+	.dio_begin			= bl_dio_begin,
+	.dio_end			= bl_dio_end,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
 	.free_layout_hdr		= bl_free_layout_hdr,
 	.alloc_lseg			= bl_alloc_lseg,
-- 
1.7.1.262.g5ef3d

