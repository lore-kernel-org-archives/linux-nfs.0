Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36038 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752490AbeAOEFP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jan 2018 23:05:15 -0500
Received: by mail-io0-f193.google.com with SMTP id l17so1859189ioc.3
        for <linux-nfs@vger.kernel.org>; Sun, 14 Jan 2018 20:05:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Add explicit rescheduling points in the receive path
Date: Sun, 14 Jan 2018 23:05:08 -0500
Message-Id: <20180115040508.100921-2-trond.myklebust@primarydata.com>
In-Reply-To: <20180115040508.100921-1-trond.myklebust@primarydata.com>
References: <20180115040508.100921-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When reading the reply from the server, insert an explicit
cond_resched() to avoid starving higher priority tasks.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 620be573d78b..18803021f242 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1005,6 +1005,7 @@ static void xs_local_data_receive(struct sock_xprt *transport)
 	struct sock *sk;
 	int err;
 
+restart:
 	mutex_lock(&transport->recv_mutex);
 	sk = transport->inet;
 	if (sk == NULL)
@@ -1018,6 +1019,11 @@ static void xs_local_data_receive(struct sock_xprt *transport)
 		}
 		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 			break;
+		if (need_resched()) {
+			mutex_unlock(&transport->recv_mutex);
+			cond_resched();
+			goto restart;
+		}
 	}
 out:
 	mutex_unlock(&transport->recv_mutex);
@@ -1096,6 +1102,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 	struct sock *sk;
 	int err;
 
+restart:
 	mutex_lock(&transport->recv_mutex);
 	sk = transport->inet;
 	if (sk == NULL)
@@ -1109,6 +1116,11 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		}
 		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 			break;
+		if (need_resched()) {
+			mutex_unlock(&transport->recv_mutex);
+			cond_resched();
+			goto restart;
+		}
 	}
 out:
 	mutex_unlock(&transport->recv_mutex);
@@ -1528,16 +1540,16 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 		.arg.data = xprt,
 	};
 	unsigned long total = 0;
-	int loop;
 	int read = 0;
 
+restart:
 	mutex_lock(&transport->recv_mutex);
 	sk = transport->inet;
 	if (sk == NULL)
 		goto out;
 
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
-	for (loop = 0; loop < 64; loop++) {
+	for (;;) {
 		rd_desc.count = RPC_TCP_READ_CHUNK_SZ;
 		lock_sock(sk);
 		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
@@ -1548,6 +1560,11 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 		}
 		release_sock(sk);
 		total += read;
+		if (need_resched()) {
+			mutex_unlock(&transport->recv_mutex);
+			cond_resched();
+			goto restart;
+		}
 	}
 	if (test_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
 		queue_work(xprtiod_workqueue, &transport->recv_worker);
-- 
2.14.3

