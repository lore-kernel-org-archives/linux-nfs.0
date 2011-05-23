Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17509 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756703Ab1EWTna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 15:43:30 -0400
Message-ID: <4DDAB8CC.5020004@panasas.com>
Date: Mon, 23 May 2011 22:43:08 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: into pnfs: pnfs: support for non-rpc layout drivers:
 de-ref not needed
References: <4DDA8C3D.5080706@panasas.com> <1306168687-11649-1-git-send-email-bhalevy@panasas.com> <4DDAA30A.8090806@panasas.com> <4DDAB40E.3040205@panasas.com>
In-Reply-To: <4DDAB40E.3040205@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


the de-ref in pnfs_ld_read/write_done in the error case is not
needed. I only tested the write path but I suspect it is all
symetric

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a5a0e73..e844cf0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1130,8 +1130,6 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 		return 0;
 	}
 
-	put_lseg(data->lseg);
-	data->lseg = NULL;
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
 	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
@@ -1179,8 +1177,6 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 		return 0;
 	}
 
-	put_lseg(data->lseg);
-	data->lseg = NULL;
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
 	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
-- 
1.7.2.3


