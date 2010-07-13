From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 19/30] netvm: prevent a stream specific deadlock
Date: Tue, 13 Jul 2010 06:20:26 -0400
Message-ID: <20100713102025.2835.61045.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 97cab9c6b5964ba48bee576214d71edbef74d0a6 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:37:56 +0800
Subject: [PATCH 19/30] netvm: prevent a stream specific deadlock

It could happen that all !SOCK_MEMALLOC sockets have buffered so much data
that we're over the global rmem limit. This will prevent SOCK_MEMALLOC buffers
from receiving data, which will prevent userspace from running, which is needed
to reduce the buffered data.

Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/net/sock.h   |    7 ++++---
 net/core/sock.c      |    2 +-
 net/ipv4/tcp_input.c |   12 ++++++------
 net/sctp/ulpevent.c  |    2 +-
 4 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1de14b6..ac87f6f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -977,12 +977,13 @@ static inline int sk_wmem_schedule(struct sock *sk, int size)
 		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }
 
-static inline int sk_rmem_schedule(struct sock *sk, int size)
+static inline int sk_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	if (!sk_has_account(sk))
 		return 1;
-	return size <= sk->sk_forward_alloc ||
-		__sk_mem_schedule(sk, size, SK_MEM_RECV);
+	return skb->truesize <= sk->sk_forward_alloc ||
+		__sk_mem_schedule(sk, skb->truesize, SK_MEM_RECV) ||
+		skb_emergency(skb);
 }
 
 static inline void sk_mem_reclaim(struct sock *sk)
diff --git a/net/core/sock.c b/net/core/sock.c
index 6bd5765..f24560c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -399,7 +399,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	if (!sk_rmem_schedule(sk, skb->truesize)) {
+	if (!sk_rmem_schedule(sk, skb)) {
 		atomic_inc(&sk->sk_drops);
 		return -ENOBUFS;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0433466..cea2bc2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4340,19 +4340,19 @@ static void tcp_ofo_queue(struct sock *sk)
 static int tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
-static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
+static inline int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    !sk_rmem_schedule(sk, size)) {
+	    !sk_rmem_schedule(sk, skb)) {
 
 		if (tcp_prune_queue(sk) < 0)
 			return -1;
 
-		if (!sk_rmem_schedule(sk, size)) {
+		if (!sk_rmem_schedule(sk, skb)) {
 			if (!tcp_prune_ofo_queue(sk))
 				return -1;
 
-			if (!sk_rmem_schedule(sk, size))
+			if (!sk_rmem_schedule(sk, skb))
 				return -1;
 		}
 	}
@@ -4405,7 +4405,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		if (eaten <= 0) {
 queue_and_out:
 			if (eaten < 0 &&
-			    tcp_try_rmem_schedule(sk, skb->truesize))
+			    tcp_try_rmem_schedule(sk, skb))
 				goto drop;
 
 			skb_set_owner_r(skb, sk);
@@ -4476,7 +4476,7 @@ drop:
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (tcp_try_rmem_schedule(sk, skb->truesize))
+	if (tcp_try_rmem_schedule(sk, skb))
 		goto drop;
 
 	/* Disable header prediction. */
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index aa72e89..ebbbfea 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -702,7 +702,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	if (rx_count >= asoc->base.sk->sk_rcvbuf) {
 
 		if ((asoc->base.sk->sk_userlocks & SOCK_RCVBUF_LOCK) ||
-		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb->truesize)))
+		    (!sk_rmem_schedule(asoc->base.sk, chunk->skb)))
 			goto fail;
 	}
 
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
