Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757970AbcHYQnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Aug 2016 12:43:53 -0400
From: Paolo Abeni <pabeni@redhat.com>
To: netdev@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        Jan Stancek <jstancek@redhat.com>
Subject: [PATCH net] sunrpc: fix UDP memory accounting
Date: Thu, 25 Aug 2016 18:42:35 +0200
Message-Id: <32a391a2469b4161dc2375c6b6374b8229b3dd37.1472126188.git.pabeni@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The commit f9b2ee714c5c ("SUNRPC: Move UDP receive data path
into a workqueue context"), as a side effect, moved the
skb_free_datagram() call outside the scope of the related socket
lock, but UDP sockets require such lock to be held for proper
memory accounting.
Fix it by replacing skb_free_datagram() with
skb_free_datagram_locked().

Fixes: f9b2ee714c5c ("SUNRPC: Move UDP receive data path into a workqueue context")
Reported-and-tested-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8ede3bc..bf16883 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1074,7 +1074,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		skb = skb_recv_datagram(sk, 0, 1, &err);
 		if (skb != NULL) {
 			xs_udp_data_read_skb(&transport->xprt, sk, skb);
-			skb_free_datagram(sk, skb);
+			skb_free_datagram_locked(sk, skb);
 			continue;
 		}
 		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-- 
1.8.3.1

