Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51025 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755228Ab2D3RG4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 13:06:56 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, iisaman@netapp.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: pnfs_pageio_init_read() and init_write() need an extra argument
Date: Mon, 30 Apr 2012 13:06:53 -0400
Message-Id: <1335805613-23138-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This is only when CONFIG_NFS_V4_1 isn't enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/pnfs.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8efbee7..f20054b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -424,12 +424,14 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
-static inline bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+static inline bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
+					 const struct nfs_pgio_completion_ops *compl_ops)
 {
 	return false;
 }
 
-static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
+static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags,
+					  const struct nfs_pgio_completion_ops *compl_ops)
 {
 	return false;
 }
-- 
1.7.10

