Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664Ab0KVSam (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Nov 2010 13:30:42 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Fix an infinite loop in call_refresh/call_refreshresult
Date: Mon, 22 Nov 2010 13:30:37 -0500
Message-Id: <1290450637-4409-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290201597.3135.57.camel@heimdal.trondhjem.org>
References: <1290201597.3135.57.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If the rpcauth_refreshcred() call returns an error other than
EACCES, ENOMEM or ETIMEDOUT, we currently end up looping forever
between call_refresh and call_refreshresult.

The correct thing to do here is to exit on all errors except
EAGAIN and ETIMEDOUT, for which case we retry 3 times, then
return EACCES.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/clnt.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9dab957..92ce94f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -989,20 +989,26 @@ call_refreshresult(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_status = 0;
-	task->tk_action = call_allocate;
-	if (status >= 0 && rpcauth_uptodatecred(task))
-		return;
+	task->tk_action = call_refresh;
 	switch (status) {
-	case -EACCES:
-		rpc_exit(task, -EACCES);
-		return;
-	case -ENOMEM:
-		rpc_exit(task, -ENOMEM);
+	case 0:
+		if (rpcauth_uptodatecred(task))
+			task->tk_action = call_allocate;
 		return;
 	case -ETIMEDOUT:
 		rpc_delay(task, 3*HZ);
+	case -EAGAIN:
+		status = -EACCES;
+		if (!task->tk_cred_retry)
+			break;
+		task->tk_cred_retry--;
+		dprintk("RPC: %5u %s: retry refresh creds\n",
+				task->tk_pid, __func__);
+		return;
 	}
-	task->tk_action = call_refresh;
+	dprintk("RPC: %5u %s: refresh creds failed with error %d\n",
+				task->tk_pid, __func__, status);
+	rpc_exit(task, status);
 }
 
 /*
-- 
1.7.3.2

