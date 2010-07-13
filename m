From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 15/30] netvm: network reserve infrastructure
Date: Tue, 13 Jul 2010 06:19:40 -0400
Message-ID: <20100713101939.2835.90633.sendpatchset@danny.redhat>
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

>From e8a09c013cf8416ece804ddcbc0d016d2f936e6d Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:06:54 +0800
Subject: [PATCH 15/30] netvm: network reserve infrastructure

Provide the basic infrastructure to reserve and charge/account network memory.

We provide the following reserve tree:

1)  total network reserve
2)    network TX reserve
3)      protocol TX pages
4)    network RX reserve
5)      SKB data reserve

[1] is used to make all the network reserves a single subtree, for easy
manipulation.

[2] and [4] are merely for eastetic reasons.

The TX pages reserve [3] is assumed bounded by it being the upper bound of
memory that can be used for sending pages (not quite true, but good enough)

The SKB reserve [5] is an aggregate reserve, which is used to charge SKB data
against in the fallback path.

The consumers for these reserves are sockets marked with:
  SOCK_MEMALLOC

Such sockets are to be used to service the VM (iow. to swap over). They
must be handled kernel side, exposing such a socket to user-space is a BUG.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/net/sock.h |   43 ++++++++++++++++++++-
 net/Kconfig        |    3 +
 net/core/sock.c    |  107 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 152 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 9ddb37b..1de14b6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -52,6 +52,7 @@
 #include <linux/mm.h>
 #include <linux/security.h>
 #include <linux/slab.h>
+#include <linux/reserve.h>
 
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -532,6 +533,7 @@ enum sock_flags {
 	SOCK_RCVTSTAMPNS, /* %SO_TIMESTAMPNS setting */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
+	SOCK_MEMALLOC, /* the VM depends on us - make sure we're serviced */
 	SOCK_TIMESTAMPING_TX_HARDWARE,  /* %SOF_TIMESTAMPING_TX_HARDWARE */
 	SOCK_TIMESTAMPING_TX_SOFTWARE,  /* %SOF_TIMESTAMPING_TX_SOFTWARE */
 	SOCK_TIMESTAMPING_RX_HARDWARE,  /* %SOF_TIMESTAMPING_RX_HARDWARE */
@@ -563,9 +565,48 @@ static inline int sock_flag(struct sock *sk, enum sock_flags flag)
 	return test_bit(flag, &sk->sk_flags);
 }
 
+static inline int sk_has_memalloc(struct sock *sk)
+{
+	return sock_flag(sk, SOCK_MEMALLOC);
+}
+
+extern struct mem_reserve net_rx_reserve;
+extern struct mem_reserve net_skb_reserve;
+
+#ifdef CONFIG_NETVM
+/*
+ * Guestimate the per request queue TX upper bound.
+ *
+ * Max packet size is 64k, and we need to reserve that much since the data
+ * might need to bounce it. Double it to be on the safe side.
+ */
+#define TX_RESERVE_PAGES DIV_ROUND_UP(2*65536, PAGE_SIZE)
+
+extern int memalloc_socks;
+
+static inline int sk_memalloc_socks(void)
+{
+	return memalloc_socks;
+}
+
+extern int sk_adjust_memalloc(int socks, long tx_reserve_pages);
+extern int sk_set_memalloc(struct sock *sk);
+extern int sk_clear_memalloc(struct sock *sk);
+#else
+static inline int sk_memalloc_socks(void)
+{
+	return 0;
+}
+
+static inline int sk_clear_memalloc(struct sock *sk)
+{
+	return 0;
+}
+#endif
+
 static inline gfp_t sk_allocation(struct sock *sk, gfp_t gfp_mask)
 {
-	return gfp_mask;
+	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
 }
 
 static inline void sk_acceptq_removed(struct sock *sk)
diff --git a/net/Kconfig b/net/Kconfig
index 0d68b40..2b61a85 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -284,4 +284,7 @@ source "net/9p/Kconfig"
 source "net/caif/Kconfig"
 
 
+config NETVM
+	def_bool n
+
 endif   # if NET
diff --git a/net/core/sock.c b/net/core/sock.c
index fef2434..6bd5765 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -111,6 +111,7 @@
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/user_namespace.h>
+#include <linux/reserve.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -224,6 +225,105 @@ int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
 
+static struct mem_reserve net_reserve;
+struct mem_reserve net_rx_reserve;
+EXPORT_SYMBOL_GPL(net_rx_reserve); /* modular ipv6 only */
+struct mem_reserve net_skb_reserve;
+EXPORT_SYMBOL_GPL(net_skb_reserve); /* modular ipv6 only */
+static struct mem_reserve net_tx_reserve;
+static struct mem_reserve net_tx_pages;
+
+#ifdef CONFIG_NETVM
+static DEFINE_MUTEX(memalloc_socks_lock);
+int memalloc_socks;
+
+/**
+ *	sk_adjust_memalloc - adjust the global memalloc reserve for critical RX
+ *	@socks: number of new %SOCK_MEMALLOC sockets
+ *	@tx_resserve_pages: number of pages to (un)reserve for TX
+ *
+ *	This function adjusts the memalloc reserve based on system demand.
+ *	The RX reserve is a limit, and only added once, not for each socket.
+ *
+ *	NOTE:
+ *	   @tx_reserve_pages is an upper-bound of memory used for TX hence
+ *	   we need not account the pages like we do for RX pages.
+ */
+int sk_adjust_memalloc(int socks, long tx_reserve_pages)
+{
+	int err;
+
+	mutex_lock(&memalloc_socks_lock);
+	err = mem_reserve_pages_add(&net_tx_pages, tx_reserve_pages);
+	if (err)
+		goto unlock;
+
+	/*
+	 * either socks is positive and we need to check for 0 -> !0
+	 * transition and connect the reserve tree when we observe it.
+	 */
+	if (!memalloc_socks && socks > 0) {
+		err = mem_reserve_connect(&net_reserve, &mem_reserve_root);
+		if (err) {
+			/*
+			 * if we failed to connect the tree, undo the tx
+			 * reserve so that failure has no side effects.
+			 */
+			mem_reserve_pages_add(&net_tx_pages, -tx_reserve_pages);
+			goto unlock;
+		}
+	}
+	memalloc_socks += socks;
+	/*
+	 * or socks is negative and we must observe the !0 -> 0 transition
+	 * and disconnect the reserve tree.
+	 */
+	if (!memalloc_socks && socks)
+		mem_reserve_disconnect(&net_reserve);
+
+unlock:
+	mutex_unlock(&memalloc_socks_lock);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(sk_adjust_memalloc);
+
+/**
+ *	sk_set_memalloc - sets %SOCK_MEMALLOC
+ *	@sk: socket to set it on
+ *
+ *	Set %SOCK_MEMALLOC on a socket and increase the memalloc reserve
+ *	accordingly.
+ */
+int sk_set_memalloc(struct sock *sk)
+{
+	int set = sock_flag(sk, SOCK_MEMALLOC);
+
+	if (!set) {
+		int err = sk_adjust_memalloc(1, 0);
+		if (err)
+			return err;
+
+		sock_set_flag(sk, SOCK_MEMALLOC);
+		sk->sk_allocation |= __GFP_MEMALLOC;
+	}
+	return !set;
+}
+EXPORT_SYMBOL_GPL(sk_set_memalloc);
+
+int sk_clear_memalloc(struct sock *sk)
+{
+	int set = sock_flag(sk, SOCK_MEMALLOC);
+	if (set) {
+		sk_adjust_memalloc(-1, 0);
+		sock_reset_flag(sk, SOCK_MEMALLOC);
+		sk->sk_allocation &= ~__GFP_MEMALLOC;
+	}
+	return set;
+}
+EXPORT_SYMBOL_GPL(sk_clear_memalloc);
+#endif
+
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
 	struct timeval tv;
@@ -1121,6 +1221,7 @@ static void __sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
 
+	sk_clear_memalloc(sk);
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 
@@ -1300,6 +1401,12 @@ void __init sk_init(void)
 		sysctl_wmem_max = 131071;
 		sysctl_rmem_max = 131071;
 	}
+
+	mem_reserve_init(&net_reserve, "total network reserve", NULL);
+	mem_reserve_init(&net_rx_reserve, "network RX reserve", &net_reserve);
+	mem_reserve_init(&net_skb_reserve, "SKB data reserve", &net_rx_reserve);
+	mem_reserve_init(&net_tx_reserve, "network TX reserve", &net_reserve);
+	mem_reserve_init(&net_tx_pages, "protocol TX pages", &net_tx_reserve);
 }
 
 /*
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
