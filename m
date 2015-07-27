Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34236 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbbG0Pfe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 11:35:34 -0400
Received: by igk11 with SMTP id 11so66871185igk.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 08:35:33 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Report TCP errors to the caller
Date: Mon, 27 Jul 2015 11:35:30 -0400
Message-Id: <1438011330-15715-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4f48b1a19e9f..6a21368bdd8e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -677,9 +677,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
 				xdr->len - req->rq_bytes_sent, status);
 
-		if (unlikely(sent == 0 && status < 0))
-			break;
-
 		/* If we've sent the entire packet, immediately
 		 * reset the count of bytes sent. */
 		req->rq_bytes_sent += sent;
@@ -689,10 +686,12 @@ static int xs_tcp_send_request(struct rpc_task *task)
 			return 0;
 		}
 
-		if (sent != 0)
-			continue;
-		status = -EAGAIN;
-		break;
+		if (status < 0)
+			break;
+		if (sent == 0) {
+			status = -EAGAIN;
+			break;
+		}
 	}
 	if (status == -EAGAIN && sk_stream_is_writeable(transport->inet))
 		status = -ENOBUFS;
-- 
2.4.3

