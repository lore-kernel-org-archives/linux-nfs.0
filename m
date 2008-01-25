From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 011/112] SUNRPC: Make call_status()/call_decode() call
	xprt_force_disconnect()
Date: Fri, 25 Jan 2008 11:37:26 -0500
Message-ID: <20080125163726.31887.3622.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066AbYAYRAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:00 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseg010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:59 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the calls to xprt_disconnect() over to xprt_force_disconnect() in
order to enable the transport layer to manage the state of the
XPRT_CONNECTED flag.
Ditto in xs_tcp_read_fraghdr().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c     |    4 ++--
 net/sunrpc/xprtsock.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76be83e..046d8f6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1137,7 +1137,7 @@ call_status(struct rpc_task *task)
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
 		if (task->tk_client->cl_discrtry)
-			xprt_disconnect(task->tk_xprt);
+			xprt_force_disconnect(task->tk_xprt);
 		break;
 	case -ECONNREFUSED:
 	case -ENOTCONN:
@@ -1260,7 +1260,7 @@ out_retry:
 	req->rq_received = req->rq_private_buf.len = 0;
 	task->tk_status = 0;
 	if (task->tk_client->cl_discrtry)
-		xprt_disconnect(task->tk_xprt);
+		xprt_force_disconnect(task->tk_xprt);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5d0444d..9b85bf4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -899,7 +899,7 @@ static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_rea
 	/* Sanity check of the record length */
 	if (unlikely(transport->tcp_reclen < 4)) {
 		dprintk("RPC:       invalid TCP record fragment length\n");
-		xprt_disconnect(xprt);
+		xprt_force_disconnect(xprt);
 		return;
 	}
 	dprintk("RPC:       reading TCP record fragment of length %d\n",
