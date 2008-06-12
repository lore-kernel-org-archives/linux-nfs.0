From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/37] SUNRPC: Ensure we exit early in case of an encode
	error
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.39765.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14765 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758712AbYFLTes (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:48 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJYlrV001754
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:34:47 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All errors from call_encode(), with exception of EAGAIN are fatal, so we
should immediately return instead of proceeding to xprt_transmit().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8945307..9503b4c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -890,7 +890,6 @@ call_encode(struct rpc_task *task)
 			task->tk_msg.rpc_argp);
 	if (task->tk_status == -ENOMEM) {
 		/* XXX: Is this sane? */
-		rpc_delay(task, 3*HZ);
 		task->tk_status = -EAGAIN;
 	}
 }
@@ -1048,8 +1047,14 @@ call_transmit(struct rpc_task *task)
 		BUG_ON(task->tk_rqstp->rq_bytes_sent != 0);
 		call_encode(task);
 		/* Did the encode result in an error condition? */
-		if (task->tk_status != 0)
+		if (task->tk_status != 0) {
+			/* Was the error nonfatal? */
+			if (task->tk_status == -EAGAIN)
+				rpc_delay(task, HZ >> 4);
+			else
+				rpc_exit(task, task->tk_status);
 			return;
+		}
 	}
 	xprt_transmit(task);
 	if (task->tk_status < 0)

