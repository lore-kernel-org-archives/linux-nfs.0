From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 19/30] SUNRPC: Avoid an unnecessary task reschedule on
 ENOTCONN
Date: Wed, 11 Mar 2009 14:41:09 -0400
Message-ID: <20090311184109.5578.52498.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13301 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754498AbZCKSoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:16 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3rK021754
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:14 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the socket is unconnected, and xprt_transmit() returns ENOTCONN, we
currently give up the lock on the transport channel. Doing so means that
the lock automatically gets assigned to the next task in the xprt->sending
queue, and so that task needs to be woken up to do the actual connect.

The following patch aims to avoid that unnecessary task switch.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |   26 ++++++++++++++++++--------
 1 files changed, 18 insertions(+), 8 deletions(-)


diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 836f15c..07e9b05 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1105,14 +1105,24 @@ static void
 call_transmit_status(struct rpc_task *task)
 {
 	task->tk_action = call_status;
-	/*
-	 * Special case: if we've been waiting on the socket's write_space()
-	 * callback, then don't call xprt_end_transmit().
-	 */
-	if (task->tk_status == -EAGAIN)
-		return;
-	xprt_end_transmit(task);
-	rpc_task_force_reencode(task);
+	switch (task->tk_status) {
+	case -EAGAIN:
+		break;
+	default:
+		xprt_end_transmit(task);
+		/*
+		 * Special cases: if we've been waiting on the
+		 * socket's write_space() callback, or if the
+		 * socket just returned a connection error,
+		 * then hold onto the transport lock.
+		 */
+	case -ECONNREFUSED:
+	case -ENOTCONN:
+	case -EHOSTDOWN:
+	case -EHOSTUNREACH:
+	case -ENETUNREACH:
+		rpc_task_force_reencode(task);
+	}
 }
 
 /*

