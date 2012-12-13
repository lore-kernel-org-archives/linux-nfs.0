Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:57038 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab2LMGrs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 01:47:48 -0500
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfs: Remove duplicate function declaration in internal.h
Date: Thu, 13 Dec 2012 14:37:34 +0800
Message-Id: <1355380654-10949-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

Remove duplicate function declaration in internal.h

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/internal.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 59b133c..440674f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -409,9 +409,6 @@ extern struct nfs_write_header *nfs_writehdr_alloc(void);
 extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 			     struct nfs_pgio_header *hdr);
-extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
-			struct inode *inode, int ioflags,
-			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_writedata_release(struct nfs_write_data *wdata);
 extern void nfs_commit_free(struct nfs_commit_data *p);
-- 
1.7.4.4

