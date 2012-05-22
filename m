Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038Ab2EVOKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 10:10:11 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2] NFS: Fix compiler warnings
Date: Tue, 22 May 2012 10:10:03 -0400
Message-Id: <1337695803-15055-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The "struct inode *inode" was only used in a dprintk, so compiling with
CONFIG_SUNRPC_DEBUG off triggers a warning.  To get around this, I
remove the "struct inode *inode" variable and instead change the
dprintk()s to use hdr->inode instead.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 474c630..718c929 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -85,15 +85,14 @@ filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
 static void filelayout_reset_write(struct nfs_write_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = hdr->inode;
 	struct rpc_task *task = &data->task;
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
 			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
 			data->task.tk_pid,
-			inode->i_sb->s_id,
-			(long long)NFS_FILEID(inode),
+			hdr->inode->i_sb->s_id,
+			(long long)NFS_FILEID(hdr->inode),
 			data->args.count,
 			(unsigned long long)data->args.offset);
 
@@ -109,15 +108,14 @@ static void filelayout_reset_write(struct nfs_write_data *data)
 static void filelayout_reset_read(struct nfs_read_data *data)
 {
 	struct nfs_pgio_header *hdr = data->header;
-	struct inode *inode = hdr->inode;
 	struct rpc_task *task = &data->task;
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
 			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
 			data->task.tk_pid,
-			inode->i_sb->s_id,
-			(long long)NFS_FILEID(inode),
+			hdr->inode->i_sb->s_id,
+			(long long)NFS_FILEID(hdr->inode),
 			data->args.count,
 			(unsigned long long)data->args.offset);
 
-- 
1.7.10.2

