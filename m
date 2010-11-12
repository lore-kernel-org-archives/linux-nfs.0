Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab0KLItX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:23 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fB025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:08 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/22] pnfs-submit: remove RPC_ASSASSINATED(task) checks
Date: Fri, 12 Nov 2010 03:48:23 -0500
Message-Id: <1289551724-18575-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
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
index 73bd44e..ce322e5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5483,9 +5483,6 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return;
 
-	if (RPC_ASSASSINATED(task))
-		return;
-
 	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
@@ -5590,9 +5587,6 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
 		return;
 
-	if (RPC_ASSASSINATED(task))
-		return;
-
 	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
-- 
1.7.2.1

