From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/33] SUNRPC: Fix a bug in call_decode()
Date: Sat, 19 Apr 2008 16:40:47 -0400
Message-ID: <20080419204047.14124.76946.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757542AbYDSUug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:36 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoXD5026109
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:35 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

call_verify() can, under certain circumstances, free the RPC slot. In that
case, our cached pointer 'req = task->tk_rqstp' is invalid. Bug was
introduced in commit 220bcc2afd7011b3e0569fc178331fa983c92c1b (SUNRPC:
Don't call xprt_release in call refresh).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d6701f7..0c29792 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1236,10 +1236,13 @@ call_decode(struct rpc_task *task)
 			task->tk_status);
 	return;
 out_retry:
-	req->rq_received = req->rq_private_buf.len = 0;
 	task->tk_status = 0;
-	if (task->tk_client->cl_discrtry)
-		xprt_force_disconnect(task->tk_xprt);
+	/* Note: call_verify() may have freed the RPC slot */
+	if (task->tk_rqstp == req) {
+		req->rq_received = req->rq_private_buf.len = 0;
+		if (task->tk_client->cl_discrtry)
+			xprt_force_disconnect(task->tk_xprt);
+	}
 }
 
 /*

