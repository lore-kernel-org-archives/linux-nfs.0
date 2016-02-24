Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:61755 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757026AbcBXR4y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:54 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/8] NFS default callback ops
Date: Wed, 24 Feb 2016 12:56:21 -0500
Message-ID: <1456336587-17374-3-git-send-email-andros@netapp.com>
In-Reply-To: <1456336587-17374-1-git-send-email-andros@netapp.com>
References: <1456336587-17374-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Also use with refactored exchange_id for session trunking

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c70de30..a298a51 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6783,12 +6783,12 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 }
 
 static void
-nfs4_bind_one_conn_to_session_done(struct rpc_task *task, void *calldata)
+nfs4_proc_default_done(struct rpc_task *task, void *calldata)
 {
 }
 
-static const struct rpc_call_ops nfs4_bind_one_conn_to_session_ops = {
-	.rpc_call_done =  &nfs4_bind_one_conn_to_session_done,
+static const struct rpc_call_ops nfs4_proc_default_ops = {
+	.rpc_call_done =  &nfs4_proc_default_done,
 };
 
 /*
@@ -6819,7 +6819,7 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
 		.rpc_xprt = xprt,
-		.callback_ops = &nfs4_bind_one_conn_to_session_ops,
+		.callback_ops = &nfs4_proc_default_ops,
 		.rpc_message = &msg,
 		.flags = RPC_TASK_TIMEOUT,
 	};
-- 
1.8.3.1

