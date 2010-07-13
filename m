From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 16/30] netvm: INET reserves
Date: Tue, 13 Jul 2010 06:19:52 -0400
Message-ID: <20100713101951.2835.89303.sendpatchset@danny.redhat>
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

>From e1a39da88a7b093474c48bb5f22f3b715e5ec205 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:17:23 +0800
Subject: [PATCH 16/30] netvm: INET reserves.

Add reserves for INET.

The two big users seem to be the route cache and ip-fragment cache.

Reserve the route cache under generic RX reserve, its usage is bounded by
the high reclaim watermark, and thus does not need further accounting.

Reserve the ip-fragement caches under SKB data reserve, these add to the
SKB RX limit. By ensuring we can at least receive as much data as fits in
the reassmbly line we avoid fragment attack deadlocks.

Adds to the reserve tree:

  total network reserve
    network TX reserve
      protocol TX pages
    network RX reserve
+     IPv6 route cache
+     IPv4 route cache
      SKB data reserve
+       IPv6 fragment cache
+       IPv4 fragment cache

[jeffm@suse.de: PROCFS typo fix]
[dfeng@redhat.com: build fix for removing .strategy]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/net/inet_frag.h  |    7 ++++++
 include/net/netns/ipv6.h |    4 +++
 net/ipv4/inet_fragment.c |    3 ++
 net/ipv4/ip_fragment.c   |   34 +++++++++++++++++++++++++++-
 net/ipv4/route.c         |   42 ++++++++++++++++++++++++++++++++++-
 net/ipv6/reassembly.c    |   55 ++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/route.c         |   47 +++++++++++++++++++++++++++++++++++++-
 7 files changed, 186 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 16ff29a..958ee27 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -1,6 +1,9 @@
 #ifndef __NET_FRAG_H__
 #define __NET_FRAG_H__
 
+#include <linux/reserve.h>
+#include <linux/mutex.h>
+
 struct netns_frags {
 	int			nqueues;
 	atomic_t		mem;
@@ -10,6 +13,10 @@ struct netns_frags {
 	int			timeout;
 	int			high_thresh;
 	int			low_thresh;
+
+	/* reserves */
+	struct mutex		lock;
+	struct mem_reserve	reserve;
 };
 
 struct inet_frag_queue {
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 81abfcb..1f644b2 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -25,6 +25,8 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
 	int icmpv6_time;
+
+	struct mutex ip6_rt_lock;
 };
 
 struct netns_ipv6 {
@@ -58,6 +60,8 @@ struct netns_ipv6 {
 	struct sock             *ndisc_sk;
 	struct sock             *tcp_sk;
 	struct sock             *igmp_sk;
+
+	struct mem_reserve	ip6_rt_reserve;
 #ifdef CONFIG_IPV6_MROUTE
 #ifndef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
 	struct mr6_table	*mrt6;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index a2ca6ae..58270a3 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -20,6 +20,7 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
+#include <linux/reserve.h>
 
 #include <net/inet_frag.h>
 
@@ -75,6 +76,8 @@ void inet_frags_init_net(struct netns_frags *nf)
 	nf->nqueues = 0;
 	atomic_set(&nf->mem, 0);
 	INIT_LIST_HEAD(&nf->lru_list);
+	mutex_init(&nf->lock);
+	mem_reserve_init(&nf->reserve, "IP fragement cache", NULL);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index dd0dbf0..a2e2e05 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -45,6 +45,8 @@
 #include <linux/udp.h>
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/reserve.h>
+#include <linux/nsproxy.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -634,6 +636,34 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 }
 
 #ifdef CONFIG_SYSCTL
+static int
+proc_dointvec_fragment(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv4.frags.high_thresh);
+	ctl_table tmp = *table;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv4.frags.lock);
+	if (write) {
+		tmp.data = &new_bytes;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv4.frags.reserve,
+				new_bytes);
+		if (!ret)
+			net->ipv4.frags.high_thresh = new_bytes;
+	}
+	mutex_unlock(&net->ipv4.frags.lock);
+
+	return ret;
+}
+
 static int zero;
 
 static struct ctl_table ip4_frags_ns_ctl_table[] = {
@@ -642,7 +672,7 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
 	},
 	{
 		.procname	= "ipfrag_low_thresh",
@@ -740,6 +770,8 @@ static inline void ip4_frags_ctl_register(void)
 
 static int __net_init ipv4_frags_init_net(struct net *net)
 {
+	int ret;
+
 	/*
 	 * Fragment cache limits. We will commit 256K at one time. Should we
 	 * cross that limit we will prune down to 192K. This should cope with
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 03430de..548aa37 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -108,6 +108,7 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
+#include <linux/reserve.h>
 
 #define RT_FL_TOS(oldflp) \
     ((u32)(oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
@@ -268,6 +269,8 @@ static inline int rt_genid(struct net *net)
 	return atomic_read(&net->ipv4.rt_genid);
 }
 
+static struct mem_reserve ipv4_route_reserve;
+
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct seq_net_private p;
@@ -398,6 +401,34 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static struct mutex ipv4_route_lock;
+
+static int
+proc_dointvec_route(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	ctl_table tmp = *table;
+	int new_size, ret;
+
+	mutex_lock(&ipv4_route_lock);
+	if (write) {
+		tmp.data = &new_size;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+				ipv4_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			ip_rt_max_size = new_size;
+	}
+	mutex_unlock(&ipv4_route_lock);
+
+	return ret;
+}
+
 static const struct seq_operations rt_cache_seq_ops = {
 	.start  = rt_cache_seq_start,
 	.next   = rt_cache_seq_next,
@@ -3096,7 +3127,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= &proc_dointvec_route,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -3327,6 +3358,15 @@ int __init ip_rt_init(void)
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
+#ifdef CONFIG_PROC_FS
+	mutex_init(&ipv4_route_lock);
+#endif
+
+	mem_reserve_init(&ipv4_route_reserve, "IPv4 route cache",
+			&net_rx_reserve);
+	mem_reserve_kmem_cache_set(&ipv4_route_reserve,
+			ipv4_dst_ops.kmem_cachep, ip_rt_max_size);
+
 	devinet_init();
 	ip_fib_init();
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 545c414..6f02d8c 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -42,6 +42,7 @@
 #include <linux/jhash.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
+#include <linux/reserve.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -639,13 +640,41 @@ static const struct inet6_protocol frag_protocol =
 };
 
 #ifdef CONFIG_SYSCTL
+static int
+proc_dointvec_fragment(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv6.frags.high_thresh);
+	ctl_table tmp = *table;
+	int new_bytes, ret;
+
+	mutex_lock(&net->ipv6.frags.lock);
+	if (write) {
+		tmp.data = &new_bytes;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+					      new_bytes);
+		if (!ret)
+			net->ipv6.frags.high_thresh = new_bytes;
+	}
+	mutex_unlock(&net->ipv6.frags.lock);
+
+	return ret;
+}
+
 static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{
 		.procname	= "ip6frag_high_thresh",
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= &proc_dointvec_fragment,
 	},
 	{
 		.procname	= "ip6frag_low_thresh",
@@ -750,17 +779,39 @@ static inline void ip6_frags_sysctl_unregister(void)
 
 static int __net_init ipv6_frags_init_net(struct net *net)
 {
+	int ret;
+
 	net->ipv6.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
 	net->ipv6.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	net->ipv6.frags.timeout = IPV6_FRAG_TIMEOUT;
 
 	inet_frags_init_net(&net->ipv6.frags);
 
-	return ip6_frags_ns_sysctl_register(net);
+	ret = ip6_frags_ns_sysctl_register(net);
+	if (ret)
+		goto out_reg;
+
+	mem_reserve_init(&net->ipv6.frags.reserve, "IPv6 fragment cache",
+			 &net_skb_reserve);
+	ret = mem_reserve_kmalloc_set(&net->ipv6.frags.reserve,
+				      net->ipv6.frags.high_thresh);
+	if (ret)
+		goto out_reserve;
+
+	return 0;
+
+out_reserve:
+	mem_reserve_disconnect(&net->ipv6.frags.reserve);
+	ip6_frags_ns_sysctl_unregister(net);
+out_reg:
+	inet_frags_exit_net(&net->ipv6.frags, &ip6_frags);
+
+	return ret;
 }
 
 static void __net_exit ipv6_frags_exit_net(struct net *net)
 {
+	mem_reserve_disconnect(&net->ipv6.frags.reserve);
 	ip6_frags_ns_sysctl_unregister(net);
 	inet_frags_exit_net(&net->ipv6.frags, &ip6_frags);
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8f2d040..67aa341 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -37,6 +37,7 @@
 #include <linux/mroute6.h>
 #include <linux/init.h>
 #include <linux/if_arp.h>
+#include <linux/reserve.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/nsproxy.h>
@@ -2532,6 +2533,34 @@ int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
 		return -EINVAL;
 }
 
+static int
+proc_dointvec_route(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct net *net = container_of(table->data, struct net,
+				       ipv6.sysctl.ip6_rt_max_size);
+	ctl_table tmp = *table;
+	int new_size, ret;
+
+	mutex_lock(&net->ipv6.sysctl.ip6_rt_lock);
+	if (write) {
+		tmp.data = &new_size;
+		table = &tmp;
+	}
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (!ret && write) {
+		ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+				net->ipv6.ip6_dst_ops.kmem_cachep, new_size);
+		if (!ret)
+			net->ipv6.sysctl.ip6_rt_max_size = new_size;
+	}
+	mutex_unlock(&net->ipv6.sysctl.ip6_rt_lock);
+
+	return ret;
+}
+
 ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
@@ -2552,7 +2581,7 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	proc_dointvec,
+		.proc_handler	=	&proc_dointvec_route,
 	},
 	{
 		.procname	=	"gc_min_interval",
@@ -2627,6 +2656,8 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 		table[9].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
 	}
 
+	mutex_init(&net->ipv6.sysctl.ip6_rt_lock);
+
 	return table;
 }
 #endif
@@ -2676,6 +2707,14 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
 
+	mem_reserve_init(&net->ipv6.ip6_rt_reserve, "IPv6 route cache",
+			 &net_rx_reserve);
+	ret = mem_reserve_kmem_cache_set(&net->ipv6.ip6_rt_reserve,
+			net->ipv6.ip6_dst_ops.kmem_cachep,
+			net->ipv6.sysctl.ip6_rt_max_size);
+	if (ret)
+		goto out_reserve_fail;
+
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
 	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
@@ -2686,12 +2725,15 @@ static int __net_init ip6_route_net_init(struct net *net)
 out:
 	return ret;
 
+out_reserve_fail:
+	mem_reserve_disconnect(&net->ipv6.ip6_rt_reserve);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(net->ipv6.ip6_blk_hole_entry);
 out_ip6_prohibit_entry:
 	kfree(net->ipv6.ip6_prohibit_entry);
 out_ip6_null_entry:
-	kfree(net->ipv6.ip6_null_entry);
 #endif
+	kfree(net->ipv6.ip6_null_entry);
 out_ip6_dst_ops:
 	goto out;
 }
@@ -2702,6 +2744,7 @@ static void __net_exit ip6_route_net_exit(struct net *net)
 	proc_net_remove(net, "ipv6_route");
 	proc_net_remove(net, "rt6_stats");
 #endif
+	mem_reserve_disconnect(&net->ipv6.ip6_rt_reserve);
 	kfree(net->ipv6.ip6_null_entry);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->ipv6.ip6_prohibit_entry);
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
