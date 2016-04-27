Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:34604 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542AbcD0Pgh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:36:37 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 2/9] NFS default callback ops
Date: Wed, 27 Apr 2016 11:36:03 -0400
Message-ID: <1461771370-16375-3-git-send-email-andros@netapp.com>
In-Reply-To: <1461771370-16375-1-git-send-email-andros@netapp.com>
References: <1461771370-16375-1-git-send-email-andros@netapp.com>
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
index 327b8c3..da2aa2e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6784,12 +6784,12 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
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
@@ -6820,7 +6820,7 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
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

