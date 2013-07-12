Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f171.google.com ([209.85.213.171]:55799 "EHLO
	mail-ye0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964936Ab3GLQjB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:39:01 -0400
Received: by mail-ye0-f171.google.com with SMTP id q14so3253727yen.30
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:39:00 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id y70sm68995072yhe.15.2013.07.12.09.32.02
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:03 -0700 (PDT)
Subject: [PATCH v1 04/19] NFS: Refactor nfs4_call_data_sequence()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:02 -0400
Message-ID: <20130712163202.1444.45080.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pull main logic out of nfs4_call_data_sequence() so it can
eventually be shared with the NFSv4.0 call_sync path.  The new
helper function is left behind the NFSv4.1 CONFIG switch for now to
keep compiler warning noise at a minimum.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2f6f3b9..e52d2b3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -393,6 +393,23 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 
 #if defined(CONFIG_NFS_V4_1)
 
+static int nfs4_run_rpc_task(struct rpc_clnt *clnt,
+			     struct rpc_message *msg,
+			     struct rpc_task_setup *task_setup)
+{
+	struct rpc_task *task;
+	int ret;
+
+	task = rpc_run_task(task_setup);
+	if (IS_ERR(task))
+		ret = PTR_ERR(task);
+	else {
+		ret = task->tk_status;
+		rpc_put_task(task);
+	}
+	return ret;
+}
+
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
@@ -674,8 +691,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res)
 {
-	int ret;
-	struct rpc_task *task;
 	struct nfs41_call_sync_data data = {
 		.seq_server = server,
 		.seq_args = args,
@@ -688,14 +703,7 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 		.callback_data = &data
 	};
 
-	task = rpc_run_task(&task_setup);
-	if (IS_ERR(task))
-		ret = PTR_ERR(task);
-	else {
-		ret = task->tk_status;
-		rpc_put_task(task);
-	}
-	return ret;
+	return nfs4_run_rpc_task(clnt, msg, &task_setup);
 }
 
 #else

