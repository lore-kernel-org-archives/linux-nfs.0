From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/33] SUNRPC: remove XS_SENDMSG_RETRY
Date: Sat, 19 Apr 2008 16:40:53 -0400
Message-ID: <20080419204053.14124.2952.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756234AbYDSUu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:28 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoR5g026068
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:27 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The condition for exiting from the loop in xs_tcp_send_request() should be
that we find we're not making progress (i.e. number of bytes sent is 0).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4c2462e..4a567a9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -136,12 +136,6 @@ static ctl_table sunrpc_table[] = {
 #endif
 
 /*
- * How many times to try sending a request on a socket before waiting
- * for the socket buffer to clear.
- */
-#define XS_SENDMSG_RETRY	(10U)
-
-/*
  * Time out for an RPC UDP socket connect.  UDP socket connects are
  * synchronous, but we set a timeout anyway in case of resource
  * exhaustion on the local host.
@@ -666,7 +660,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *xdr = &req->rq_snd_buf;
 	int status;
-	unsigned int retry = 0;
 
 	xs_encode_tcp_record_marker(&req->rq_snd_buf);
 
@@ -697,9 +690,10 @@ static int xs_tcp_send_request(struct rpc_task *task)
 			return 0;
 		}
 
+		if (status != 0)
+			continue;
 		status = -EAGAIN;
-		if (retry++ > XS_SENDMSG_RETRY)
-			break;
+		break;
 	}
 
 	switch (status) {

