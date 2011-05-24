Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46858 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695Ab1EXPJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:09:21 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/12] SQUASHME: pnfs: Fall out from: non-rpc layout drivers
Date: Tue, 24 May 2011 18:08:49 +0300
Message-Id: <1306249729-23485-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

the de-ref in pnfs_ld_read/write_done in the error case is not
needed. I only tested the write path but I suspect it is all
symetric

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0f59802..1716621 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1069,8 +1069,6 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 		return 0;
 	}
 
-	put_lseg(data->lseg);
-	data->lseg = NULL;
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
 	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
@@ -1118,8 +1116,6 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 		return 0;
 	}
 
-	put_lseg(data->lseg);
-	data->lseg = NULL;
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
 	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
-- 
1.7.2.3

