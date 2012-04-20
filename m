Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34178 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757365Ab2DTSgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:46 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 04/28] NFS: grab open context in direct read
Date: Fri, 20 Apr 2012 14:35:46 -0400
Message-Id: <1334946970-27470-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
References: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 481be7f..8a89423 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -260,7 +260,7 @@ static void nfs_direct_read_release(void *calldata)
 
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
-	nfs_readdata_free(data);
+	nfs_readdata_release(data);
 }
 
 static const struct rpc_call_ops nfs_read_direct_ops = {
@@ -337,7 +337,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->inode = inode;
 		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
-		data->args.context = ctx;
+		data->args.context = get_nfs_open_context(ctx);
 		data->args.lock_context = dreq->l_ctx;
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
-- 
1.7.2.1

