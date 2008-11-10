From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 54/85] nfs41: Skip past the RPC call direction
Date: Mon, 10 Nov 2008 22:27:43 +0200
Message-ID: <1226348863-9029-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59984 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbYKJU1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:27:50 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

xs_tcp_read_calldir() is now responsible for reading the RPC call
direction and determining whether it is a reply or a callback request.
The call to xdr_skb_read_bits() inside xs_tcp_read_calldir() moves the
xdr_skb_reader offset past the RPC call direction (offset should be
equal to 8).  Therefore xs_tcp_read_common() called from
xs_tcp_ready_reply() should be copying the TCP buffer starting past the
RPC call direction.  It is now necessary to read the RPC call direction
earlier to determine whether to call the reply handler or the callback
handler.

call_verify() should therefore skip past the XID and call/reply flag.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/clnt.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c31ded3..dd0ff2d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1371,13 +1371,14 @@ rpc_verify_header(struct rpc_task *task)
 	}
 	if ((len -= 3) < 0)
 		goto out_overflow;
-	p += 1;	/* skip XID */
 
-	if ((n = ntohl(*p++)) != RPC_REPLY) {
-		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
-				task->tk_pid, __func__, n);
-		goto out_garbage;
-	}
+	/*
+	 * Skip the XID and call direction.
+	 * The underlying transport has read the XID and RPC call direction
+	 * to determine this is an RPC reply.
+	 */
+	p += 2;
+
 	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
 		if (--len < 0)
 			goto out_overflow;
-- 
1.6.0.2

