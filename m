Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45571 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab1GGOOP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 10:14:15 -0400
Received: by iwn6 with SMTP id 6so871054iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2011 07:14:15 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Subject: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
Date: Sun,  3 Jul 2011 18:30:02 -0700
Message-Id: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There is no need to keep lseg reference when read/write through MDS.
This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
is not NULL.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 30a0394..55fdf02 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1193,6 +1193,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
 	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
 				    data->mds_ops, NFS_FILE_SYNC);
 	return status ? : -EAGAIN;
@@ -1240,6 +1243,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
 	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
 				   data->mds_ops);
 	return status ? : -EAGAIN;
-- 
1.7.4.2

