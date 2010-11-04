Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33429 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415Ab0KDPWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:54 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMY029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:45 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/18] pnfs-submit: remove RPC_ASSASSINATED(task) checks
Date: Thu,  4 Nov 2010 11:22:25 -0400
Message-Id: <1288884151-11128-13-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

See Trond's commit a6f03393ec8 "NFSv4: Get rid of the bogus
RPC_ASSASSINATED(task) checks"

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7b42a33..be19e225 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5482,9 +5482,6 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return;
 
-	if (RPC_ASSASSINATED(task))
-		return;
-
 	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
@@ -5588,9 +5585,6 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
 		return;
 
-	if (RPC_ASSASSINATED(task))
-		return;
-
 	if (lrp->args.return_type == RETURN_FILE)
 		server = NFS_SERVER(lrp->args.inode);
 	else
-- 
1.7.2.1

