Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f174.google.com ([209.85.160.174]:57789 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaGCENA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 00:13:00 -0400
Received: by mail-yk0-f174.google.com with SMTP id 19so6958138ykq.33
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 21:12:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/2] SUNRPC: Handle EPIPE in xprt_connect_status
Date: Thu,  3 Jul 2014 00:12:51 -0400
Message-Id: <1404360771-6782-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1404360771-6782-1-git-send-email-trond.myklebust@primarydata.com>
References: <1404360771-6782-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The callback handler xs_error_report() can end up propagating an EPIPE
error by means of the call to xprt_wake_pending_tasks(). Ensure that
xprt_connect_status() does not automatically convert this into an
EIO error.

Reported-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c | 1 +
 net/sunrpc/xprt.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 575e63f6c13e..488ddeed9363 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1814,6 +1814,7 @@ call_connect_status(struct rpc_task *task)
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
 	case -ENOBUFS:
+	case -EPIPE:
 		if (RPC_IS_SOFTCONN(task))
 			break;
 		/* retry with existing socket, after a delay */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c3b2b3369e52..c5b2916298b0 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -744,6 +744,7 @@ static void xprt_connect_status(struct rpc_task *task)
 	case -ECONNABORTED:
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
+	case -EPIPE:
 	case -EAGAIN:
 		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
 		break;
-- 
1.9.3

