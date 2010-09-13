Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6748 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755169Ab0IMUJI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 16:09:08 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: bharrosh@panasas.com, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-post-submit: mark commit data as PNFS_NO_RPC in pnfs_try_to_commit
Date: Mon, 13 Sep 2010 22:09:07 +0200
Message-Id: <1284408547-21936-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index eb4e092..61dbc0a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1693,6 +1693,8 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 
 	dprintk("%s: Begin\n", __func__);
 
+	if (!pnfs_use_rpc(nfss))
+		data->pdata.pnfsflags |= PNFS_NO_RPC;
 	/* We need to account for possibility that
 	 * each nfs_page can point to a different lseg (or be NULL).
 	 * For the immediate case of whole-file-only layouts, we at
-- 
1.7.2.2

