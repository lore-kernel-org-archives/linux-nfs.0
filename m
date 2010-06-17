From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 02/19] SQUASHME: pnfs4_read_done status variable is unused
Date: Thu, 17 Jun 2010 10:48:30 -0400
Message-ID: <1276786110-11457-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24509 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755386Ab0FQOsY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:48:24 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 17a2597..8ab30d5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3166,15 +3166,12 @@ static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
 	struct nfs_client *client = mds_svr->nfs_client;
 	struct nfs4_session *ds_session = NULL;
-	int status;
 
 	dprintk("--> %s\n", __func__);
 
 	if (data->pdata.pnfsflags & PNFS_NO_RPC)
 		return 0;
 
-	status = task->tk_status >= 0 ? 0 : task->tk_status;
-
 	/* Is this a DS session */
 	if (data->fldata.ds_nfs_client) {
 		dprintk("%s DS read\n", __func__);
-- 
1.6.4.4

