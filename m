Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49687 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755648Ab0KSVUy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 16:20:54 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAJLKbXj029594
	for <linux-nfs@vger.kernel.org>; Fri, 19 Nov 2010 13:20:38 -0800 (PST)
Subject: SUNRPC: Fix an infinite loop in call_refresh/call_refreshresult
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 16:19:57 -0500
Message-ID: <1290201597.3135.57.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If the rpcauth_refreshcred() call returns an error other than
EACCES, ENOMEM or ETIMEDOUT, we currently end up looping forever
between call_refresh and call_refreshresult.

The correct thing to do here is to exit on all errors except
EAGAIN and ETIMEDOUT.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9dab957..7b7dc4e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -989,20 +989,18 @@ call_refreshresult(struct rpc_task *task)
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
+		return;
 	}
-	task->tk_action = call_refresh;
+	rpc_exit(task, status);
 }
 
 /*

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

