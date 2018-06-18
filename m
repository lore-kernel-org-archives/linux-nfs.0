Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34227 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936381AbeFRTzp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jun 2018 15:55:45 -0400
Received: by mail-it0-f65.google.com with SMTP id y127-v6so12624262itd.1
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jun 2018 12:55:45 -0700 (PDT)
Subject: [PATCH v1] sunrpc: Prevent duplicate XID allocation
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: geert@linux-m68k.org, krzk@kernel.org
Date: Mon, 18 Jun 2018 15:55:43 -0400
Message-ID: <20180618195510.26098.42839.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Krzysztof Kozlowski <krzk@kernel.org> reports that a heavy NFSv4
WRITE workload against a slow NFS server causes his Raspberry Pi
clients to stall. Krzysztof bisected it to commit 37ac86c3a76c
("SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock") .

I was able to reproduce similar behavior and it appears that rarely
the RPC client layer is re-allocating an XID for an RPC that it has
already partially sent. This results in the client ignoring the
subsequent reply, which carries the original XID.

For various reasons, checking !req->rq_xmit_bytes_sent in
xprt_prepare_transmit is not a 100% reliable mechanism for
determining when a fresh XID is needed.

Trond's preference is to allocate the XID at the time each rpc_rqst
slot is initialized.

This patch should also address a gcc 4.1.2 complaint reported by
Geert Uytterhoeven <geert@linux-m68k.org>.

Reported-by: Krzysztof Kozlowski <krzk@kernel.org>
Fixes: 37ac86c3a76c ("SUNRPC: Initialize rpc_rqst outside of ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Hi-

Interested in review, testing, other comments, etc. Thanks!


diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3c85af0..3fabf9f6 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -987,8 +987,6 @@ bool xprt_prepare_transmit(struct rpc_task *task)
 		task->tk_status = -EAGAIN;
 		goto out_unlock;
 	}
-	if (!bc_prealloc(req) && !req->rq_xmit_bytes_sent)
-		req->rq_xid = xprt_alloc_xid(xprt);
 	ret = true;
 out_unlock:
 	spin_unlock_bh(&xprt->transport_lock);
@@ -1298,7 +1296,12 @@ void xprt_retry_reserve(struct rpc_task *task)
 
 static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
 {
-	return (__force __be32)xprt->xid++;
+	__be32 xid;
+
+	spin_lock(&xprt->reserve_lock);
+	xid = (__force __be32)xprt->xid++;
+	spin_unlock(&xprt->reserve_lock);
+	return xid;
 }
 
 static inline void xprt_init_xid(struct rpc_xprt *xprt)
@@ -1316,6 +1319,7 @@ void xprt_request_init(struct rpc_task *task)
 	req->rq_task	= task;
 	req->rq_xprt    = xprt;
 	req->rq_buffer  = NULL;
+	req->rq_xid	= xprt_alloc_xid(xprt);
 	req->rq_connect_cookie = xprt->connect_cookie - 1;
 	req->rq_bytes_sent = 0;
 	req->rq_snd_buf.len = 0;

