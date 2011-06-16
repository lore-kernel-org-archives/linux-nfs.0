Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53979 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab1FPPft (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 11:35:49 -0400
Message-ID: <4DFA22D2.7070808@panasas.com>
Date: Thu, 16 Jun 2011 11:35:46 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] pnfs: write: Set mds_offset in the generic layer - it
 is needed by all LDs
References: <4DF9278A.5010103@panasas.com>
In-Reply-To: <4DF9278A.5010103@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


In current pnfs tree, all the layouts set mds_offset in their
.write_pagelist member.
mds_offset is only used by generic layer and should be handled by it.

This patch is for upstream. It is needed in this -rc series to fix a
bug in objects layout_commit.

I'll send patches for objects and blocks to be
squashed into current pnfs tree.

TODO: It looks like the read path needs the same patch.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4filelayout.c |    1 -
 fs/nfs/write.c          |    2 ++
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index dcde4e0..472f81f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -396,7 +396,6 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	 * this offset and save the original offset.
 	 */
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
-	data->mds_offset = offset;
 
 	/* Perform an asynchronous write */
 	status = nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 383ee81..1185262 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -868,6 +868,8 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req) + offset;
+	/* pnfs_set_layoutcommit needs this */
+	data->mds_offset = data->args.offset;
 	data->args.pgbase = req->wb_pgbase + offset;
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
-- 
1.7.3.4


