Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16200 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758196Ab2EUUft (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 16:35:49 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Fix compiler warnings
Date: Mon, 21 May 2012 16:35:44 -0400
Message-Id: <1337632544-2982-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The "struct inode *inode" was only used in a dprintk, so it can be
removed if CONFIG_SUNRPC_DEBUG isn't enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 474c630..54c8c5a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -85,8 +85,8 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 static void filelayout_reset_write(struct nfs_write_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = hdr->inode;
 	struct rpc_task *task = &data->task;
+	RPC_IFDEBUG(struct inode *inode = hdr->inode);
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
@@ -109,8 +109,8 @@ static void filelayout_reset_write(struct nfs_write_data *data)
 static void filelayout_reset_read(struct nfs_read_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = hdr->inode;
 	struct rpc_task *task = &data->task;
+	RPC_IFDEBUG(struct inode *inode = hdr->inode);
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
-- 
1.7.10.2

