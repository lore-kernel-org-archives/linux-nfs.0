Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38646 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728343AbeIQScA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:32:00 -0400
Received: by mail-qt0-f194.google.com with SMTP id x7-v6so15111389qtk.5
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:45 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.43
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:43 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 43/44] SUNRPC: Clean up xs_udp_data_receive()
Date: Mon, 17 Sep 2018 09:03:34 -0400
Message-Id: <20180917130335.112832-44-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-43-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
 <20180917130335.112832-42-trond.myklebust@hammerspace.com>
 <20180917130335.112832-43-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the retry logic.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1daa179b7706..175347f62875 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1341,25 +1341,18 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 	struct sock *sk;
 	int err;
 
-restart:
 	mutex_lock(&transport->recv_mutex);
 	sk = transport->inet;
 	if (sk == NULL)
 		goto out;
+	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 	for (;;) {
 		skb = skb_recv_udp(sk, 0, 1, &err);
-		if (skb != NULL) {
-			xs_udp_data_read_skb(&transport->xprt, sk, skb);
-			consume_skb(skb);
-			continue;
-		}
-		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
+		if (skb == NULL)
 			break;
-		if (need_resched()) {
-			mutex_unlock(&transport->recv_mutex);
-			cond_resched();
-			goto restart;
-		}
+		xs_udp_data_read_skb(&transport->xprt, sk, skb);
+		consume_skb(skb);
+		cond_resched();
 	}
 out:
 	mutex_unlock(&transport->recv_mutex);
-- 
2.17.1
