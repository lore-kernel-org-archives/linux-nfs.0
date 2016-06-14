Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32794 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbcFNTEj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 15:04:39 -0400
Received: by mail-it0-f66.google.com with SMTP id i6so429818ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 12:04:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] SUNRPC: Fix suspicious enobufs issues.
Date: Tue, 14 Jun 2016 15:04:06 -0400
Message-Id: <1465931046-30696-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1465931046-30696-4-git-send-email-trond.myklebust@primarydata.com>
References: <1465931046-30696-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931046-30696-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931046-30696-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931046-30696-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current test is racy when dealing with fast NICs.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 646170d0cb86..6b3efeb3edc5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -642,6 +642,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *xdr = &req->rq_snd_buf;
 	bool zerocopy = true;
+	bool vm_wait = false;
 	int status;
 	int sent;
 
@@ -677,15 +678,33 @@ static int xs_tcp_send_request(struct rpc_task *task)
 			return 0;
 		}
 
+		WARN_ON_ONCE(sent == 0 && status == 0);
+
+		if (status == -EAGAIN ) {
+			/*
+			 * Return EAGAIN if we're sure we're hitting the
+			 * socket send buffer limits.
+			 */
+			if (test_bit(SOCK_NOSPACE, &transport->sock->flags))
+				break;
+			/*
+			 * Did we hit a memory allocation failure?
+			 */
+			if (sent == 0) {
+				status = -ENOBUFS;
+				if (vm_wait)
+					break;
+				/* Retry, knowing now that we're below the
+				 * socket send buffer limit
+				 */
+				vm_wait = true;
+			}
+			continue;
+		}
 		if (status < 0)
 			break;
-		if (sent == 0) {
-			status = -EAGAIN;
-			break;
-		}
+		vm_wait = false;
 	}
-	if (status == -EAGAIN && sk_stream_is_writeable(transport->inet))
-		status = -ENOBUFS;
 
 	switch (status) {
 	case -ENOTSOCK:
-- 
2.5.5

