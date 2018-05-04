Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35339 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbeEDUXo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 16:23:44 -0400
Received: by mail-qt0-f194.google.com with SMTP id f5-v6so15698862qth.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 13:23:44 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: Combine nfs4_call_sync() with nfs4_call_sync_sequence()
Date: Fri,  4 May 2018 16:22:52 -0400
Message-Id: <20180504202252.5862-6-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
References: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The nfs4_call_sync_sequence() version only hase a single user,
nfs4_call_sync(), so let's just add in a call to nfs4_init_sequence()
instead of needing to have another function just to do this.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 505f605dcac2..99d77f6e7e40 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -993,11 +993,13 @@ static const struct rpc_call_ops nfs40_call_sync_ops = {
 	.rpc_call_done = nfs40_call_sync_done,
 };
 
-static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
-				   struct nfs_server *server,
-				   struct rpc_message *msg,
-				   struct nfs4_sequence_args *args,
-				   struct nfs4_sequence_res *res)
+int nfs4_call_sync(struct rpc_clnt *clnt,
+		   struct nfs_server *server,
+		   struct rpc_message *msg,
+		   struct nfs4_sequence_args *args,
+		   struct nfs4_sequence_res *res,
+		   int cache_reply,
+		   int privileged)
 {
 	int ret;
 	struct rpc_task *task;
@@ -1014,6 +1016,7 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 		.callback_data = &data
 	};
 
+	nfs4_init_sequence(args, res, cache_reply, privileged);
 	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
@@ -1024,18 +1027,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 	return ret;
 }
 
-int nfs4_call_sync(struct rpc_clnt *clnt,
-		   struct nfs_server *server,
-		   struct rpc_message *msg,
-		   struct nfs4_sequence_args *args,
-		   struct nfs4_sequence_res *res,
-		   int cache_reply,
-		   int privileged)
-{
-	nfs4_init_sequence(args, res, cache_reply, privileged);
-	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
-}
-
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo,
 		unsigned long timestamp)
 {
-- 
2.17.0

