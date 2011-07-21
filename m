Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:40489 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab1GUTex (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 15:34:53 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v2 25/25] NFS41: Drop lseg ref before fallthru to MDS
Date: Thu, 21 Jul 2011 15:34:25 -0400
Message-Id: <1311276865-29484-26-git-send-email-rees@umich.edu>
In-Reply-To: <1311276865-29484-1-git-send-email-rees@umich.edu>
References: <1311276865-29484-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

There is no need to keep lseg reference when read/write through MDS.
This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
is not NULL.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3b20753..fda3019 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1182,6 +1182,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
 	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
 				    data->mds_ops, NFS_FILE_SYNC);
 	return status ? : -EAGAIN;
@@ -1282,6 +1285,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
+
+	put_lseg(data->lseg);
+	data->lseg = NULL;
 	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
 				   data->mds_ops);
 	return status ? : -EAGAIN;
-- 
1.7.4.1

