Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36351 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdHPQTk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 12:19:40 -0400
Received: by mail-it0-f67.google.com with SMTP id o72so2675175ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 09:19:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/6] SUNRPC: Don't loop forever in xs_tcp_data_receive()
Date: Wed, 16 Aug 2017 12:19:26 -0400
Message-Id: <20170816161929.11271-4-trond.myklebust@primarydata.com>
In-Reply-To: <20170816161929.11271-3-trond.myklebust@primarydata.com>
References: <20170816161929.11271-1-trond.myklebust@primarydata.com>
 <20170816161929.11271-2-trond.myklebust@primarydata.com>
 <20170816161929.11271-3-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we don't hog the workqueue thread by requeuing the job
every 64 loops.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a2312f14beb4..e8f44fc76754 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1526,6 +1526,7 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 		.arg.data = xprt,
 	};
 	unsigned long total = 0;
+	int loop;
 	int read = 0;
 
 	mutex_lock(&transport->recv_mutex);
@@ -1534,20 +1535,20 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 		goto out;
 
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
-	for (;;) {
+	for (loop = 0; loop < 64; loop++) {
 		lock_sock(sk);
 		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
 		if (read <= 0) {
 			clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 			release_sock(sk);
-			if (!test_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-				break;
-		} else {
-			release_sock(sk);
-			total += read;
+			break;
 		}
+		release_sock(sk);
+		total += read;
 		rd_desc.count = 65536;
 	}
+	if (test_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
+		queue_work(xprtiod_workqueue, &transport->recv_worker);
 out:
 	mutex_unlock(&transport->recv_mutex);
 	trace_xs_tcp_data_ready(xprt, read, total);
-- 
2.13.5

