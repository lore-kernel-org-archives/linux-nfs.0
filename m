Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53215 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab0LOQDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:23 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lor001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:22 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] wave 2: remove gratuitous changes to nfs4_layoutget_done
Date: Wed, 15 Dec 2010 11:03:02 -0500
Message-Id: <1292428991-30788-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d8f754e..096c89d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5405,12 +5405,13 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
-	struct inode *ino = lgp->args.inode;
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 
 	dprintk("--> %s\n", __func__);
 
 	if (!nfs4_sequence_done(task, &lgp->res.seq_res))
 		return;
+
 	switch (task->tk_status) {
 	case 0:
 		break;
@@ -5419,8 +5420,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		task->tk_status = -NFS4ERR_DELAY;
 		/* Fall through */
 	default:
-		if (nfs4_async_handle_error(task, NFS_SERVER(ino),
-					    NULL, NULL) == -EAGAIN) {
+		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
 			rpc_restart_call_prepare(task);
 			return;
 		}
-- 
1.7.2.1

