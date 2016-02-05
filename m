Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:19893 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbcBEVIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2016 16:08:52 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC Version 1 5/6] NFS add callback_ops to nfs4_proc_bind_conn_to_session_callback
Date: Fri, 5 Feb 2016 16:08:37 -0500
Message-ID: <1454706518-4641-6-git-send-email-andros@netapp.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Fix oops when NULL callback_ops pointer accessed in rpc_init_task

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a2da473..ea07707 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6782,6 +6782,15 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 	return false;
 }
 
+static void
+nfs4_bind_one_conn_to_session_done(struct rpc_task *task, void *calldata)
+{
+}
+
+static const struct rpc_call_ops nfs4_bind_one_conn_to_session_ops = {
+	.rpc_call_done =  &nfs4_bind_one_conn_to_session_done,
+};
+
 /*
  * nfs4_proc_bind_one_conn_to_session()
  *
@@ -6810,6 +6819,7 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clnt,
 		.rpc_xprt = xprt,
+		.callback_ops = &nfs4_bind_one_conn_to_session_ops,
 		.rpc_message = &msg,
 		.flags = RPC_TASK_TIMEOUT,
 	};
-- 
1.8.3.1

