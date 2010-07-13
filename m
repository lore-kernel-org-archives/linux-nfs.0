From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 21/30] netvm: skb processing
Date: Tue, 13 Jul 2010 06:20:48 -0400
Message-ID: <20100713102047.2835.28057.sendpatchset@danny.redhat>
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

>From 15437174f171e197ecdfa5fe71ae89334bb58fd2 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 13:07:28 +0800
Subject: [PATCH 21/30] netvm: skb processing

In order to make sure emergency packets receive all memory needed to proceed
ensure processing of emergency SKBs happens under PF_MEMALLOC.

Use the (new) sk_backlog_rcv() wrapper to ensure this for backlog processing.

Skip taps, since those are user-space again.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/net/sock.h |    5 ++++
 net/core/dev.c     |   55 ++++++++++++++++++++++++++++++++++++++++++++++++---
 net/core/sock.c    |   16 +++++++++++++++
 3 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ac87f6f..aadf15c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -680,8 +680,13 @@ static inline __must_check int sk_add_backlog(struct sock *sk, struct sk_buff *s
 	return 0;
 }
 
+extern int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	if (skb_emergency(skb))
+		return __sk_backlog_rcv(sk, skb);
+
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index e85cc5f..7169b9b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2801,6 +2801,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	struct net_device *orig_or_bond;
 	int ret = NET_RX_DROP;
 	__be16 type;
+	unsigned long pflags = current->flags;
 
 	if (!netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
@@ -2808,9 +2809,21 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
 		return NET_RX_SUCCESS;
 
+	/* Emergency skb are special, they should
+	 *  - be delivered to SOCK_MEMALLOC sockets only
+	 *  - stay away from userspace
+	 *  - have bounded memory usage
+	 *
+	 * Use PF_MEMALLOC as a poor mans memory pool - the grouping kind.
+	 * This saves us from propagating the allocation context down to all
+	 * allocation sites.
+	 */
+	if (skb_emergency(skb))
+		current->flags |= PF_MEMALLOC;
+
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
+		goto out;
 
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
@@ -2852,6 +2865,9 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	}
 #endif
 
+	if (skb_emergency(skb))
+		goto skip_taps;
+
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
 		    ptype->dev == orig_dev) {
@@ -2861,13 +2877,17 @@ static int __netif_receive_skb(struct sk_buff *skb)
 		}
 	}
 
+skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
 	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 	if (!skb)
-		goto out;
+		goto unlock;
 ncls:
 #endif
 
+	if (!skb_emergency_protocol(skb))
+		goto drop;
+
 	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
@@ -2877,7 +2897,7 @@ ncls:
 		}
 		skb = rx_handler(skb);
 		if (!skb)
-			goto out;
+			goto unlock;
 	}
 
 	/*
@@ -2907,6 +2927,7 @@ ncls:
 	if (pt_prev) {
 		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+drop:
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
@@ -2914,11 +2935,37 @@ ncls:
 		ret = NET_RX_DROP;
 	}
 
-out:
+unlock:
 	rcu_read_unlock();
+out:
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 	return ret;
 }
 
+/*
+ * Filter the protocols for which the reserves are adequate.
+ *
+ * Before adding a protocol make sure that it is either covered by the existing
+ * reserves, or add reserves covering the memory need of the new protocol's
+ * packet processing.
+ */
+static int skb_emergency_protocol(struct sk_buff *skb)
+{
+	if (skb_emergency(skb))
+		switch (skb->protocol) {
+		case __constant_htons(ETH_P_ARP):
+		case __constant_htons(ETH_P_IP):
+		case __constant_htons(ETH_P_IPV6):
+		case __constant_htons(ETH_P_8021Q):
+			break;
+
+		default:
+			return 0;
+		}
+
+	return 1;
+}
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
diff --git a/net/core/sock.c b/net/core/sock.c
index f24560c..dfc2dfe 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -322,6 +322,22 @@ int sk_clear_memalloc(struct sock *sk)
 	return set;
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
+
+int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	int ret;
+	unsigned long pflags = current->flags;
+
+	/* these should have been dropped before queueing */
+	BUG_ON(!sk_has_memalloc(sk));
+
+	current->flags |= PF_MEMALLOC;
+	ret = sk->sk_backlog_rcv(sk, skb);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
+
+	return ret;
+}
+EXPORT_SYMBOL(__sk_backlog_rcv);
 #endif
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
