Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:37996 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755275Ab2ENH5q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 03:57:46 -0400
From: Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC net-next 2/2] net: Convert net_ratelimit uses to net_<level>_ratelimited
Date: Mon, 14 May 2012 00:56:26 -0700
Message-Id: <5485b03dda7bc8f5f34215cc09178cfabe184a4e.1336981915.git.joe@perches.com>
In-Reply-To: <cover.1336981915.git.joe@perches.com>
References: <cover.1336981915.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Standardize the net core ratelimited logging functions.

Coalesce formats, align arguments.
Change a printk then vprintk sequence to use printf extension %pV.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/ioctl.c                                |    8 +--
 net/caif/caif_socket.c                         |   10 ++---
 net/core/dev.c                                 |   30 ++++++--------
 net/core/pktgen.c                              |    7 +--
 net/core/rtnetlink.c                           |    8 +--
 net/core/skbuff.c                              |   11 ++---
 net/decnet/dn_fib.c                            |    5 +-
 net/decnet/dn_neigh.c                          |   22 ++++-------
 net/decnet/dn_nsp_in.c                         |   11 +++--
 net/decnet/dn_nsp_out.c                        |    5 +-
 net/decnet/dn_route.c                          |   15 ++-----
 net/decnet/dn_table.c                          |    4 +-
 net/decnet/netfilter/dn_rtmsg.c                |    3 +-
 net/ipv4/icmp.c                                |   20 ++++-----
 net/ipv4/ip_fragment.c                         |    3 +-
 net/ipv4/ip_input.c                            |   13 +++---
 net/ipv4/ip_options.c                          |    6 ++-
 net/ipv4/ip_output.c                           |    4 +-
 net/ipv4/ipconfig.c                            |   11 ++---
 net/ipv4/ipmr.c                                |    3 +-
 net/ipv4/netfilter/arp_tables.c                |    5 +-
 net/ipv4/netfilter/ip_tables.c                 |    3 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    3 +-
 net/ipv4/netfilter/nf_nat_h323.c               |   26 ++++--------
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |    8 +--
 net/ipv4/route.c                               |   40 ++++++++-----------
 net/ipv4/tcp.c                                 |   14 +++---
 net/ipv4/tcp_input.c                           |    7 +--
 net/ipv4/tcp_ipv4.c                            |   11 ++---
 net/ipv4/tcp_output.c                          |    3 +-
 net/ipv6/addrconf.c                            |   17 +++-----
 net/ipv6/ah6.c                                 |    4 +-
 net/ipv6/ip6_output.c                          |    3 +-
 net/ipv6/ip6_tunnel.c                          |   33 +++++----------
 net/ipv6/ip6mr.c                               |    3 +-
 net/ipv6/netfilter/ip6_tables.c                |    3 +-
 net/ipv6/netfilter/ip6t_REJECT.c               |    6 +--
 net/ipv6/netfilter/ip6table_mangle.c           |    3 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    3 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    7 +--
 net/ipv6/reassembly.c                          |    6 +--
 net/ipv6/route.c                               |   12 +----
 net/ipv6/sit.c                                 |    6 +--
 net/ipv6/tcp_ipv6.c                            |   10 ++---
 net/llc/af_llc.c                               |    7 +--
 net/mac80211/agg-rx.c                          |   13 ++----
 net/mac80211/ht.c                              |    8 ++--
 net/mac80211/ibss.c                            |   10 ++---
 net/mac80211/mlme.c                            |   12 ++---
 net/mac80211/rx.c                              |   11 ++---
 net/mac80211/tx.c                              |   17 +++-----
 net/netfilter/nf_conntrack_amanda.c            |    3 +-
 net/netfilter/nf_conntrack_core.c              |    5 +--
 net/netfilter/nf_conntrack_expect.c            |    4 +-
 net/netfilter/nf_conntrack_h323_main.c         |    9 +---
 net/netfilter/nf_conntrack_irc.c               |    8 +--
 net/netfilter/nfnetlink_queue.c                |    9 +---
 net/netfilter/xt_TCPMSS.c                      |   10 ++---
 net/netfilter/xt_hashlimit.c                   |    3 +-
 net/openvswitch/vport-netdev.c                 |    6 +-
 net/sched/act_ipt.c                            |    7 +--
 net/sched/act_mirred.c                         |    5 +-
 net/sched/cls_u32.c                            |    3 +-
 net/sched/ematch.c                             |    4 +-
 net/sched/sch_api.c                            |   10 ++---
 net/sched/sch_generic.c                        |   11 ++---
 net/sched/sch_gred.c                           |   12 ++----
 net/sctp/sm_sideeffect.c                       |    5 +-
 net/sctp/sm_statefuns.c                        |   18 ++++-----
 net/sctp/socket.c                              |    6 +--
 net/socket.c                                   |    3 +-
 net/sunrpc/svc.c                               |   18 ++++-----
 net/sunrpc/svc_xprt.c                          |   13 ++----
 net/sunrpc/svcsock.c                           |   28 +++++--------
 net/wireless/lib80211_crypt_ccmp.c             |   33 +++++----------
 net/wireless/lib80211_crypt_tkip.c             |   50 ++++++++----------------
 76 files changed, 306 insertions(+), 490 deletions(-)

diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 62dc8bf..bbd3b63 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -97,9 +97,8 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd,
 			error = sock_get_timestampns(sk, argp);
 		goto done;
 	case ATM_SETSC:
-		if (net_ratelimit())
-			pr_warning("ATM_SETSC is obsolete; used by %s:%d\n",
-				   current->comm, task_pid_nr(current));
+		net_warn_ratelimited("ATM_SETSC is obsolete; used by %s:%d\n",
+				     current->comm, task_pid_nr(current));
 		error = 0;
 		goto done;
 	case ATMSIGD_CTRL:
@@ -123,8 +122,7 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd,
 		   work for 32-bit userspace. TBH I don't really want
 		   to think about it at all. dwmw2. */
 		if (compat) {
-			if (net_ratelimit())
-				pr_warning("32-bit task cannot be atmsigd\n");
+			net_warn_ratelimited("32-bit task cannot be atmsigd\n");
 			error = -EINVAL;
 			goto done;
 		}
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 0dccdb3..fb89443 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -131,10 +131,9 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 		(unsigned int)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
-		if (net_ratelimit())
-			pr_debug("sending flow OFF (queue len = %d %d)\n",
-					atomic_read(&cf_sk->sk.sk_rmem_alloc),
-					sk_rcvbuf_lowwater(cf_sk));
+		net_dbg_ratelimited("sending flow OFF (queue len = %d %d)\n",
+				    atomic_read(&cf_sk->sk.sk_rmem_alloc),
+				    sk_rcvbuf_lowwater(cf_sk));
 		set_rx_flow_off(cf_sk);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
@@ -144,8 +143,7 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		return err;
 	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
-		if (net_ratelimit())
-			pr_debug("sending flow OFF due to rmem_schedule\n");
+		net_dbg_ratelimited("sending flow OFF due to rmem_schedule\n");
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
 	skb->dev = NULL;
diff --git a/net/core/dev.c b/net/core/dev.c
index a2be59f..3dd8539 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1673,10 +1673,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 			if (skb_network_header(skb2) < skb2->data ||
 			    skb2->network_header > skb2->tail) {
-				if (net_ratelimit())
-					pr_crit("protocol %04x is buggy, dev %s\n",
-						ntohs(skb2->protocol),
-						dev->name);
+				net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
+						     ntohs(skb2->protocol),
+						     dev->name);
 				skb_reset_network_header(skb2);
 			}
 
@@ -2343,11 +2342,9 @@ EXPORT_SYMBOL(__skb_tx_hash);
 static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
-		if (net_ratelimit()) {
-			pr_warn("%s selects TX queue %d, but real number of TX queues is %d\n",
-				dev->name, queue_index,
-				dev->real_num_tx_queues);
-		}
+		net_warn_ratelimited("%s selects TX queue %d, but real number of TX queues is %d\n",
+				     dev->name, queue_index,
+				     dev->real_num_tx_queues);
 		return 0;
 	}
 	return queue_index;
@@ -2589,17 +2586,15 @@ int dev_queue_xmit(struct sk_buff *skb)
 				}
 			}
 			HARD_TX_UNLOCK(dev, txq);
-			if (net_ratelimit())
-				pr_crit("Virtual device %s asks to queue packet!\n",
-					dev->name);
+			net_crit_ratelimited("Virtual device %s asks to queue packet!\n",
+					     dev->name);
 		} else {
 			/* Recursion is detected! It is possible,
 			 * unfortunately
 			 */
 recursion_alert:
-			if (net_ratelimit())
-				pr_crit("Dead loop on virtual device %s, fix it urgently!\n",
-					dev->name);
+			net_crit_ratelimited("Dead loop on virtual device %s, fix it urgently!\n",
+					     dev->name);
 		}
 	}
 
@@ -3080,9 +3075,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 	struct Qdisc *q;
 
 	if (unlikely(MAX_RED_LOOP < ttl++)) {
-		if (net_ratelimit())
-			pr_warn("Redir loop detected Dropping packet (%d->%d)\n",
-				skb->skb_iif, dev->ifindex);
+		net_warn_ratelimited("Redir loop detected Dropping packet (%d->%d)\n",
+				     skb->skb_iif, dev->ifindex);
 		return TC_ACT_SHOT;
 	}
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ffb5d38..3391257 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2934,8 +2934,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 	if (datalen < sizeof(struct pktgen_hdr)) {
 		datalen = sizeof(struct pktgen_hdr);
-		if (net_ratelimit())
-			pr_info("increased datalen to %d\n", datalen);
+		net_info_ratelimited("increased datalen to %d\n", datalen);
 	}
 
 	udph->source = htons(pkt_dev->cur_udp_src);
@@ -3365,8 +3364,8 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->errors++;
 		break;
 	default: /* Drivers are not supposed to return other values! */
-		if (net_ratelimit())
-			pr_info("%s xmit error: %d\n", pkt_dev->odevname, ret);
+		net_info_ratelimited("%s xmit error: %d\n",
+				     pkt_dev->odevname, ret);
 		pkt_dev->errors++;
 		/* fallthru */
 	case NETDEV_TX_LOCKED:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b442d35..21318d1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1524,11 +1524,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	err = 0;
 
 errout:
-	if (err < 0 && modified && net_ratelimit())
-		printk(KERN_WARNING "A link change request failed with "
-		       "some changes committed already. Interface %s may "
-		       "have been left with an inconsistent configuration, "
-		       "please check.\n", dev->name);
+	if (err < 0 && modified)
+		net_warn_ratelimited("A link change request failed with some changes committed already. Interface %s may have been left with an inconsistent configuration, please check.\n",
+				     dev->name);
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2c35da8..2a18719 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3299,10 +3299,8 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
 {
 	if (unlikely(start > skb_headlen(skb)) ||
 	    unlikely((int)start + off > skb_headlen(skb) - 2)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "bad partial csum: csum=%u/%u len=%u\n",
-			       start, off, skb_headlen(skb));
+		net_warn_ratelimited("bad partial csum: csum=%u/%u len=%u\n",
+				     start, off, skb_headlen(skb));
 		return false;
 	}
 	skb->ip_summed = CHECKSUM_PARTIAL;
@@ -3314,8 +3312,7 @@ EXPORT_SYMBOL_GPL(skb_partial_csum_set);
 
 void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 {
-	if (net_ratelimit())
-		pr_warning("%s: received packets cannot be forwarded"
-			   " while LRO is enabled\n", skb->dev->name);
+	net_warn_ratelimited("%s: received packets cannot be forwarded while LRO is enabled\n",
+			     skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 65a8cd7..7eaf987 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -438,9 +438,8 @@ int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowidn
 			res->fi = NULL;
 			return 1;
 		default:
-			if (net_ratelimit())
-				printk("DECnet: impossible routing event : dn_fib_semantic_match type=%d\n",
-				       type);
+			net_err_ratelimited("DECnet: impossible routing event : dn_fib_semantic_match type=%d\n",
+					    type);
 			res->fi = NULL;
 			return -EINVAL;
 		}
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index ee7013f..ac90f658 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -162,8 +162,8 @@ static int dn_neigh_construct(struct neighbour *neigh)
 	else if ((dev->type == ARPHRD_ETHER) || (dev->type == ARPHRD_LOOPBACK))
 		dn_dn2eth(neigh->ha, dn->addr);
 	else {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "Trying to create neigh for hw %d\n",  dev->type);
+		net_dbg_ratelimited("Trying to create neigh for hw %d\n",
+				    dev->type);
 		return -EINVAL;
 	}
 
@@ -236,15 +236,13 @@ static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb_headroom(skb) < headroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, headroom);
 		if (skb2 == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "dn_long_output: no memory\n");
+			net_crit_ratelimited("dn_long_output: no memory\n");
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
 		kfree_skb(skb);
 		skb = skb2;
-		if (net_ratelimit())
-			printk(KERN_INFO "dn_long_output: Increasing headroom\n");
+		net_info_ratelimited("dn_long_output: Increasing headroom\n");
 	}
 
 	data = skb_push(skb, sizeof(struct dn_long_packet) + 3);
@@ -281,15 +279,13 @@ static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb_headroom(skb) < headroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, headroom);
 		if (skb2 == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "dn_short_output: no memory\n");
+			net_crit_ratelimited("dn_short_output: no memory\n");
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
 		kfree_skb(skb);
 		skb = skb2;
-		if (net_ratelimit())
-			printk(KERN_INFO "dn_short_output: Increasing headroom\n");
+		net_info_ratelimited("dn_short_output: Increasing headroom\n");
 	}
 
 	data = skb_push(skb, sizeof(struct dn_short_packet) + 2);
@@ -322,15 +318,13 @@ static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb_headroom(skb) < headroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, headroom);
 		if (skb2 == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "dn_phase3_output: no memory\n");
+			net_crit_ratelimited("dn_phase3_output: no memory\n");
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
 		kfree_skb(skb);
 		skb = skb2;
-		if (net_ratelimit())
-			printk(KERN_INFO "dn_phase3_output: Increasing headroom\n");
+		net_info_ratelimited("dn_phase3_output: Increasing headroom\n");
 	}
 
 	data = skb_push(skb, sizeof(struct dn_short_packet) + 2);
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 58084f3..c344163 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -80,12 +80,15 @@ extern int decnet_log_martians;
 
 static void dn_log_martian(struct sk_buff *skb, const char *msg)
 {
-	if (decnet_log_martians && net_ratelimit()) {
+	if (decnet_log_martians) {
 		char *devname = skb->dev ? skb->dev->name : "???";
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
-		printk(KERN_INFO "DECnet: Martian packet (%s) dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n",
-		       msg, devname, le16_to_cpu(cb->src), le16_to_cpu(cb->dst),
-		       le16_to_cpu(cb->src_port), le16_to_cpu(cb->dst_port));
+		net_info_ratelimited("DECnet: Martian packet (%s) dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n",
+				     msg, devname,
+				     le16_to_cpu(cb->src),
+				     le16_to_cpu(cb->dst),
+				     le16_to_cpu(cb->src_port),
+				     le16_to_cpu(cb->dst_port));
 	}
 }
 
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index b952f88..564a6ad 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -1,4 +1,3 @@
-
 /*
  * DECnet       An implementation of the DECnet protocol suite for the LINUX
  *              operating system.  DECnet is implemented using the  BSD Socket
@@ -554,8 +553,8 @@ static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
 	unsigned char *msg;
 
 	if ((dst == NULL) || (rem == 0)) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "DECnet: dn_nsp_do_disc: BUG! Please report this to SteveW@ACM.org rem=%u dst=%p\n", le16_to_cpu(rem), dst);
+		net_dbg_ratelimited("DECnet: dn_nsp_do_disc: BUG! Please report this to SteveW@ACM.org rem=%u dst=%p\n",
+				    le16_to_cpu(rem), dst);
 		return;
 	}
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 7e1f878..586302e 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -748,8 +748,7 @@ static int dn_output(struct sk_buff *skb)
 		       dn_to_neigh_output);
 
 error:
-	if (net_ratelimit())
-		printk(KERN_DEBUG "dn_output: This should not happen\n");
+	net_dbg_ratelimited("dn_output: This should not happen\n");
 
 	kfree_skb(skb);
 
@@ -807,12 +806,10 @@ drop:
  */
 static int dn_rt_bug(struct sk_buff *skb)
 {
-	if (net_ratelimit()) {
-		struct dn_skb_cb *cb = DN_SKB_CB(skb);
+	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 
-		printk(KERN_DEBUG "dn_rt_bug: skb from:%04x to:%04x\n",
-				le16_to_cpu(cb->src), le16_to_cpu(cb->dst));
-	}
+	net_dbg_ratelimited("dn_rt_bug: skb from:%04x to:%04x\n",
+			    le16_to_cpu(cb->src), le16_to_cpu(cb->dst));
 
 	kfree_skb(skb);
 
@@ -1327,9 +1324,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 
 		out_dev = DN_FIB_RES_DEV(res);
 		if (out_dev == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "Bug in dn_route_input_slow() "
-						 "No output device\n");
+			net_crit_ratelimited("Bug in dn_route_input_slow() No output device\n");
 			goto e_inval;
 		}
 		dev_hold(out_dev);
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index a9a62f2..650f338 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -836,8 +836,8 @@ struct dn_fib_table *dn_fib_get_table(u32 n, int create)
 	if (!create)
 		return NULL;
 
-	if (in_interrupt() && net_ratelimit()) {
-		printk(KERN_DEBUG "DECnet: BUG! Attempt to create routing table from interrupt\n");
+	if (in_interrupt()) {
+		net_dbg_ratelimited("DECnet: BUG! Attempt to create routing table from interrupt\n");
 		return NULL;
 	}
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 1531135..44b8909 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -57,8 +57,7 @@ nlmsg_failure:
 	if (skb)
 		kfree_skb(skb);
 	*errp = -ENOMEM;
-	if (net_ratelimit())
-		printk(KERN_ERR "dn_rtmsg: error creating netlink message\n");
+	net_err_ratelimited("dn_rtmsg: error creating netlink message\n");
 	return NULL;
 }
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 2cb2bf8..c75efbd 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -713,11 +713,10 @@ static void icmp_unreach(struct sk_buff *skb)
 
 	if (!net->ipv4.sysctl_icmp_ignore_bogus_error_responses &&
 	    inet_addr_type(net, iph->daddr) == RTN_BROADCAST) {
-		if (net_ratelimit())
-			pr_warn("%pI4 sent an invalid ICMP type %u, code %u error to a broadcast: %pI4 on %s\n",
-				&ip_hdr(skb)->saddr,
-				icmph->type, icmph->code,
-				&iph->daddr, skb->dev->name);
+		net_warn_ratelimited("%pI4 sent an invalid ICMP type %u, code %u error to a broadcast: %pI4 on %s\n",
+				     &ip_hdr(skb)->saddr,
+				     icmph->type, icmph->code,
+				     &iph->daddr, skb->dev->name);
 		goto out;
 	}
 
@@ -906,8 +905,7 @@ out_err:
 static void icmp_address(struct sk_buff *skb)
 {
 #if 0
-	if (net_ratelimit())
-		printk(KERN_DEBUG "a guy asks for address mask. Who is it?\n");
+	net_dbg_ratelimited("a guy asks for address mask. Who is it?\n");
 #endif
 }
 
@@ -943,10 +941,10 @@ static void icmp_address_reply(struct sk_buff *skb)
 			    inet_ifa_match(ip_hdr(skb)->saddr, ifa))
 				break;
 		}
-		if (!ifa && net_ratelimit()) {
-			pr_info("Wrong address mask %pI4 from %s/%pI4\n",
-				mp, dev->name, &ip_hdr(skb)->saddr);
-		}
+		if (!ifa)
+			net_info_ratelimited("Wrong address mask %pI4 from %s/%pI4\n",
+					     mp,
+					     dev->name, &ip_hdr(skb)->saddr);
 	}
 }
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 71e5c32..9f9bd13 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -644,8 +644,7 @@ out_nomem:
 	err = -ENOMEM;
 	goto out_fail;
 out_oversize:
-	if (net_ratelimit())
-		pr_info("Oversized IP packet from %pI4\n", &qp->saddr);
+	net_info_ratelimited("Oversized IP packet from %pI4\n", &qp->saddr);
 out_fail:
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 	return err;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 26eccc5..8590144 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -210,9 +210,8 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 			int ret;
 
 			if (!net_eq(net, &init_net) && !ipprot->netns_ok) {
-				if (net_ratelimit())
-					printk("%s: proto %d isn't netns-ready\n",
-						__func__, protocol);
+				net_info_ratelimited("%s: proto %d isn't netns-ready\n",
+						     __func__, protocol);
 				kfree_skb(skb);
 				goto out;
 			}
@@ -298,10 +297,10 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 
 		if (in_dev) {
 			if (!IN_DEV_SOURCE_ROUTE(in_dev)) {
-				if (IN_DEV_LOG_MARTIANS(in_dev) &&
-				    net_ratelimit())
-					pr_info("source route option %pI4 -> %pI4\n",
-						&iph->saddr, &iph->daddr);
+				if (IN_DEV_LOG_MARTIANS(in_dev))
+					net_info_ratelimited("source route option %pI4 -> %pI4\n",
+							     &iph->saddr,
+							     &iph->daddr);
 				goto drop;
 			}
 		}
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 95722ed..708b994 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -578,8 +578,10 @@ void ip_forward_options(struct sk_buff *skb)
 			ip_hdr(skb)->daddr = opt->nexthop;
 			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
 			optptr[2] = srrptr+4;
-		} else if (net_ratelimit())
-			pr_crit("%s(): Argh! Destination lost!\n", __func__);
+		} else {
+			net_crit_ratelimited("%s(): Argh! Destination lost!\n",
+					     __func__);
+		}
 		if (opt->ts_needaddr) {
 			optptr = raw + opt->ts;
 			ip_rt_get_source(&optptr[optptr[2]-9], skb, rt);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4910176..451f97c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -214,8 +214,8 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	}
 	rcu_read_unlock();
 
-	if (net_ratelimit())
-		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
+	net_dbg_ratelimited("%s: No header cache and no neighbour!\n",
+			    __func__);
 	kfree_skb(skb);
 	return -EINVAL;
 }
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f267280..24a3df9 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -955,8 +955,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 
 	/* Fragments are not supported */
 	if (ip_is_fragment(h)) {
-		if (net_ratelimit())
-			pr_err("DHCP/BOOTP: Ignoring fragmented reply\n");
+		net_err_ratelimited("DHCP/BOOTP: Ignoring fragmented reply\n");
 		goto drop;
 	}
 
@@ -1004,16 +1003,14 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	/* Is it a reply to our BOOTP request? */
 	if (b->op != BOOTP_REPLY ||
 	    b->xid != d->xid) {
-		if (net_ratelimit())
-			pr_err("DHCP/BOOTP: Reply not for us, op[%x] xid[%x]\n",
-			       b->op, b->xid);
+		net_err_ratelimited("DHCP/BOOTP: Reply not for us, op[%x] xid[%x]\n",
+				    b->op, b->xid);
 		goto drop_unlock;
 	}
 
 	/* Is it a reply for the device we are configuring? */
 	if (b->xid != ic_dev_xid) {
-		if (net_ratelimit())
-			pr_err("DHCP/BOOTP: Ignoring delayed packet\n");
+		net_err_ratelimited("DHCP/BOOTP: Ignoring delayed packet\n");
 		goto drop_unlock;
 	}
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5bef604..a9e519a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -949,8 +949,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	ret = sock_queue_rcv_skb(mroute_sk, skb);
 	rcu_read_unlock();
 	if (ret < 0) {
-		if (net_ratelimit())
-			pr_warn("mroute: pending queue full, dropping entries\n");
+		net_warn_ratelimited("mroute: pending queue full, dropping entries\n");
 		kfree_skb(skb);
 	}
 
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a393527..97e61ea 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -221,9 +221,8 @@ static inline int arp_checkentry(const struct arpt_arp *arp)
 static unsigned int
 arpt_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	if (net_ratelimit())
-		pr_err("arp_tables: error: '%s'\n",
-		       (const char *)par->targinfo);
+	net_err_ratelimited("arp_tables: error: '%s'\n",
+			    (const char *)par->targinfo);
 
 	return NF_DROP;
 }
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 585b80f..170b1fd 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -153,8 +153,7 @@ ip_checkentry(const struct ipt_ip *ip)
 static unsigned int
 ipt_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	if (net_ratelimit())
-		pr_info("error: `%s'\n", (const char *)par->targinfo);
+	net_info_ratelimited("error: `%s'\n", (const char *)par->targinfo);
 
 	return NF_DROP;
 }
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index a639967..fe5daea 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -246,8 +246,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 			dport = ports[1];
 		}
 	} else {
-		if (net_ratelimit())
-			pr_info("unknown protocol %u\n", iph->protocol);
+		net_info_ratelimited("unknown protocol %u\n", iph->protocol);
 	}
 
 	switch (config->hash_mode) {
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 8253670..cad29c1 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -42,9 +42,7 @@ static int set_addr(struct sk_buff *skb,
 		if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
-			if (net_ratelimit())
-				pr_notice("nf_nat_h323: nf_nat_mangle_tcp_packet"
-				       " error\n");
+			net_notice_ratelimited("nf_nat_h323: nf_nat_mangle_tcp_packet error\n");
 			return -1;
 		}
 
@@ -58,9 +56,7 @@ static int set_addr(struct sk_buff *skb,
 		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
-			if (net_ratelimit())
-				pr_notice("nf_nat_h323: nf_nat_mangle_udp_packet"
-				       " error\n");
+			net_notice_ratelimited("nf_nat_h323: nf_nat_mangle_udp_packet error\n");
 			return -1;
 		}
 		/* nf_nat_mangle_udp_packet uses skb_make_writable() to copy
@@ -214,8 +210,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 
 	/* Run out of expectations */
 	if (i >= H323_RTP_CHANNEL_MAX) {
-		if (net_ratelimit())
-			pr_notice("nf_nat_h323: out of expectations\n");
+		net_notice_ratelimited("nf_nat_h323: out of expectations\n");
 		return 0;
 	}
 
@@ -244,8 +239,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (nated_port == 0) {	/* No port available */
-		if (net_ratelimit())
-			pr_notice("nf_nat_h323: out of RTP ports\n");
+		net_notice_ratelimited("nf_nat_h323: out of RTP ports\n");
 		return 0;
 	}
 
@@ -308,8 +302,7 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (nated_port == 0) {	/* No port available */
-		if (net_ratelimit())
-			pr_notice("nf_nat_h323: out of TCP ports\n");
+		net_notice_ratelimited("nf_nat_h323: out of TCP ports\n");
 		return 0;
 	}
 
@@ -365,8 +358,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (nated_port == 0) {	/* No port available */
-		if (net_ratelimit())
-			pr_notice("nf_nat_q931: out of TCP ports\n");
+		net_notice_ratelimited("nf_nat_q931: out of TCP ports\n");
 		return 0;
 	}
 
@@ -456,8 +448,7 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (nated_port == 0) {	/* No port available */
-		if (net_ratelimit())
-			pr_notice("nf_nat_ras: out of TCP ports\n");
+		net_notice_ratelimited("nf_nat_ras: out of TCP ports\n");
 		return 0;
 	}
 
@@ -545,8 +536,7 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (nated_port == 0) {	/* No port available */
-		if (net_ratelimit())
-			pr_notice("nf_nat_q931: out of TCP ports\n");
+		net_notice_ratelimited("nf_nat_q931: out of TCP ports\n");
 		return 0;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 2133c30..746edec 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1206,8 +1206,7 @@ static int snmp_translate(struct nf_conn *ct,
 
 	if (!snmp_parse_mangle((unsigned char *)udph + sizeof(struct udphdr),
 			       paylen, &map, &udph->check)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "bsalg: parser failed\n");
+		net_warn_ratelimited("bsalg: parser failed\n");
 		return NF_DROP;
 	}
 	return NF_ACCEPT;
@@ -1241,9 +1240,8 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 	 * can mess around with the payload.
 	 */
 	if (ntohs(udph->len) != skb->len - (iph->ihl << 2)) {
-		 if (net_ratelimit())
-			 printk(KERN_WARNING "SNMP: dropping malformed packet src=%pI4 dst=%pI4\n",
-				&iph->saddr, &iph->daddr);
+		net_warn_ratelimited("SNMP: dropping malformed packet src=%pI4 dst=%pI4\n",
+				     &iph->saddr, &iph->daddr);
 		 return NF_DROP;
 	}
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5773f5d..42d7644 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -960,8 +960,7 @@ void rt_cache_flush_batch(struct net *net)
 
 static void rt_emergency_hash_rebuild(struct net *net)
 {
-	if (net_ratelimit())
-		pr_warn("Route hash chain too long!\n");
+	net_warn_ratelimited("Route hash chain too long!\n");
 	rt_cache_invalidate(net);
 }
 
@@ -1084,8 +1083,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
 		goto out;
 	if (dst_entries_get_slow(&ipv4_dst_ops) < ip_rt_max_size)
 		goto out;
-	if (net_ratelimit())
-		pr_warn("dst cache overflow\n");
+	net_warn_ratelimited("dst cache overflow\n");
 	RT_CACHE_STAT_INC(gc_dst_overflow);
 	return 1;
 
@@ -1182,8 +1180,7 @@ restart:
 		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
 			int err = rt_bind_neighbour(rt);
 			if (err) {
-				if (net_ratelimit())
-					pr_warn("Neighbour table failure & not caching routes\n");
+				net_warn_ratelimited("Neighbour table failure & not caching routes\n");
 				ip_rt_put(rt);
 				return ERR_PTR(err);
 			}
@@ -1299,8 +1296,7 @@ restart:
 				goto restart;
 			}
 
-			if (net_ratelimit())
-				pr_warn("Neighbour table overflow\n");
+			net_warn_ratelimited("Neighbour table overflow\n");
 			rt_drop(rt);
 			return ERR_PTR(-ENOBUFS);
 		}
@@ -1503,11 +1499,11 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 
 reject_redirect:
 #ifdef CONFIG_IP_ROUTE_VERBOSE
-	if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
-		pr_info("Redirect from %pI4 on %s about %pI4 ignored\n"
-			"  Advised path = %pI4 -> %pI4\n",
-			&old_gw, dev->name, &new_gw,
-			&saddr, &daddr);
+	if (IN_DEV_LOG_MARTIANS(in_dev))
+		net_info_ratelimited("Redirect from %pI4 on %s about %pI4 ignored\n"
+				     "  Advised path = %pI4 -> %pI4\n",
+				     &old_gw, dev->name, &new_gw,
+				     &saddr, &daddr);
 #endif
 	;
 }
@@ -1617,11 +1613,10 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		++peer->rate_tokens;
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 		if (log_martians &&
-		    peer->rate_tokens == ip_rt_redirect_number &&
-		    net_ratelimit())
-			pr_warn("host %pI4/if%d ignores redirects for %pI4 to %pI4\n",
-				&ip_hdr(skb)->saddr, rt->rt_iif,
-				&rt->rt_dst, &rt->rt_gateway);
+		    peer->rate_tokens == ip_rt_redirect_number)
+			net_warn_ratelimited("host %pI4/if%d ignores redirects for %pI4 to %pI4\n",
+					     &ip_hdr(skb)->saddr, rt->rt_iif,
+					     &rt->rt_dst, &rt->rt_gateway);
 #endif
 	}
 }
@@ -2135,8 +2130,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	/* get a working reference to the output device */
 	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
 	if (out_dev == NULL) {
-		if (net_ratelimit())
-			pr_crit("Bug in ip_route_input_slow(). Please report.\n");
+		net_crit_ratelimited("Bug in ip_route_input_slow(). Please report.\n");
 		return -EINVAL;
 	}
 
@@ -2407,9 +2401,9 @@ no_route:
 martian_destination:
 	RT_CACHE_STAT_INC(in_martian_dst);
 #ifdef CONFIG_IP_ROUTE_VERBOSE
-	if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
-		pr_warn("martian destination %pI4 from %pI4, dev %s\n",
-			&daddr, &saddr, dev->name);
+	if (IN_DEV_LOG_MARTIANS(in_dev))
+		net_warn_ratelimited("martian destination %pI4 from %pI4, dev %s\n",
+				     &daddr, &saddr, dev->name);
 #endif
 
 e_hostunreach:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 86e2cf2..feb2e25 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1745,9 +1745,9 @@ do_prequeue:
 		}
 		if ((flags & MSG_PEEK) &&
 		    (peek_seq - copied - urg_hole != tp->copied_seq)) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
-				       current->comm, task_pid_nr(current));
+			net_dbg_ratelimited("TCP(%s:%d): Application bug, race in MSG_PEEK\n",
+					    current->comm,
+					    task_pid_nr(current));
 			peek_seq = tp->copied_seq;
 		}
 		continue;
@@ -2002,10 +2002,10 @@ bool tcp_check_oom(struct sock *sk, int shift)
 	too_many_orphans = tcp_too_many_orphans(sk, shift);
 	out_of_socket_memory = tcp_out_of_memory(sk);
 
-	if (too_many_orphans && net_ratelimit())
-		pr_info("too many orphaned sockets\n");
-	if (out_of_socket_memory && net_ratelimit())
-		pr_info("out of memory -- consider tuning tcp_mem\n");
+	if (too_many_orphans)
+		net_info_ratelimited("too many orphaned sockets\n");
+	if (out_of_socket_memory)
+		net_info_ratelimited("out of memory -- consider tuning tcp_mem\n");
 	return too_many_orphans || out_of_socket_memory;
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b99ada2..100b242 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3952,10 +3952,9 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 					__u8 snd_wscale = *(__u8 *)ptr;
 					opt_rx->wscale_ok = 1;
 					if (snd_wscale > 14) {
-						if (net_ratelimit())
-							pr_info("%s: Illegal window scaling value %d >14 received\n",
-								__func__,
-								snd_wscale);
+						net_info_ratelimited("%s: Illegal window scaling value %d >14 received\n",
+								     __func__,
+								     snd_wscale);
 						snd_wscale = 14;
 					}
 					opt_rx->snd_wscale = snd_wscale;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4ff5e1f..2e76ffb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1239,12 +1239,11 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 				      NULL, NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
-		if (net_ratelimit()) {
-			pr_info("MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
-				&iph->saddr, ntohs(th->source),
-				&iph->daddr, ntohs(th->dest),
-				genhash ? " tcp_v4_calc_md5_hash failed" : "");
-		}
+		net_info_ratelimited("MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
+				     &iph->saddr, ntohs(th->source),
+				     &iph->daddr, ntohs(th->dest),
+				     genhash ? " tcp_v4_calc_md5_hash failed"
+				     : "");
 		return 1;
 	}
 	return 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d947330..7979bfd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2181,8 +2181,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 
 #if FASTRETRANS_DEBUG > 0
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "retrans_out leaked.\n");
+			net_dbg_ratelimited("retrans_out leaked\n");
 		}
 #endif
 		if (!tp->retrans_out)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8b7f100..4d1d51a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1415,9 +1415,8 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		return;
 	}
 
-	if (net_ratelimit())
-		printk(KERN_INFO "%s: IPv6 duplicate address %pI6c detected!\n",
-			ifp->idev->dev->name, &ifp->addr);
+	net_info_ratelimited("%s: IPv6 duplicate address %pI6c detected!\n",
+			     ifp->idev->dev->name, &ifp->addr);
 
 	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
 		struct in6_addr addr;
@@ -1847,16 +1846,15 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	prefered_lft = ntohl(pinfo->prefered);
 
 	if (prefered_lft > valid_lft) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "addrconf: prefix option has invalid lifetime\n");
+		net_warn_ratelimited("addrconf: prefix option has invalid lifetime\n");
 		return;
 	}
 
 	in6_dev = in6_dev_get(dev);
 
 	if (in6_dev == NULL) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "addrconf: device %s not configured\n", dev->name);
+		net_dbg_ratelimited("addrconf: device %s not configured\n",
+				    dev->name);
 		return;
 	}
 
@@ -1931,9 +1929,8 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 			}
 			goto ok;
 		}
-		if (net_ratelimit())
-			printk(KERN_DEBUG "IPv6 addrconf: prefix with wrong length %d\n",
-			       pinfo->prefix_len);
+		net_dbg_ratelimited("IPv6 addrconf: prefix with wrong length %d\n",
+				    pinfo->prefix_len);
 		in6_dev_put(in6_dev);
 		return;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 2ae79db..a9f4156 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -189,8 +189,8 @@ static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *des
 
 				hao = (struct ipv6_destopt_hao *)&opt[off];
 				if (hao->length != sizeof(hao->addr)) {
-					if (net_ratelimit())
-						printk(KERN_WARNING "destopt hao: invalid header length: %u\n", hao->length);
+					net_warn_ratelimited("destopt hao: invalid header length: %u\n",
+							     hao->length);
 					goto bad;
 				}
 				final_addr = hao->addr;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d8e05af2..be2264e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -252,8 +252,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 			       dst->dev, dst_output);
 	}
 
-	if (net_ratelimit())
-		printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
+	net_dbg_ratelimited("IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_FRAGFAILS);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 5df487c..27fec27 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -460,19 +460,14 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		__u32 mtu;
 	case ICMPV6_DEST_UNREACH:
-		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "%s: Path to destination invalid "
-			       "or inactive!\n", t->parms.name);
+		net_warn_ratelimited("%s: Path to destination invalid or inactive!\n",
+				     t->parms.name);
 		rel_msg = 1;
 		break;
 	case ICMPV6_TIME_EXCEED:
 		if ((*code) == ICMPV6_EXC_HOPLIMIT) {
-			if (net_ratelimit())
-				printk(KERN_WARNING
-				       "%s: Too small hop limit or "
-				       "routing loop in tunnel!\n",
-				       t->parms.name);
+			net_warn_ratelimited("%s: Too small hop limit or routing loop in tunnel!\n",
+					     t->parms.name);
 			rel_msg = 1;
 		}
 		break;
@@ -484,17 +479,13 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 		if (teli && teli == *info - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
 			if (tel->encap_limit == 0) {
-				if (net_ratelimit())
-					printk(KERN_WARNING
-					       "%s: Too small encapsulation "
-					       "limit or routing loop in "
-					       "tunnel!\n", t->parms.name);
+				net_warn_ratelimited("%s: Too small encapsulation limit or routing loop in tunnel!\n",
+						     t->parms.name);
 				rel_msg = 1;
 			}
-		} else if (net_ratelimit()) {
-			printk(KERN_WARNING
-			       "%s: Recipient unable to parse tunneled "
-			       "packet!\n ", t->parms.name);
+		} else {
+			net_warn_ratelimited("%s: Recipient unable to parse tunneled packet!\n",
+					     t->parms.name);
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
@@ -919,10 +910,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 
 	if (tdev == dev) {
 		stats->collisions++;
-		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "%s: Local routing loop detected!\n",
-			       t->parms.name);
+		net_warn_ratelimited("%s: Local routing loop detected!\n",
+				     t->parms.name);
 		goto tx_err_dst_release;
 	}
 	mtu = dst_mtu(dst) - sizeof (*ipv6h);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index efc0098..ba936e1 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1147,8 +1147,7 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 	 */
 	ret = sock_queue_rcv_skb(mrt->mroute6_sk, skb);
 	if (ret < 0) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "mroute6: pending queue full, dropping entries.\n");
+		net_warn_ratelimited("mroute6: pending queue full, dropping entries\n");
 		kfree_skb(skb);
 	}
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 308bdd6..d7cb045 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -181,8 +181,7 @@ ip6_checkentry(const struct ip6t_ip6 *ipv6)
 static unsigned int
 ip6t_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	if (net_ratelimit())
-		pr_info("error: `%s'\n", (const char *)par->targinfo);
+	net_info_ratelimited("error: `%s'\n", (const char *)par->targinfo);
 
 	return NF_DROP;
 }
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index aad2fa4..fd4fb34 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -114,8 +114,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 			 GFP_ATOMIC);
 
 	if (!nskb) {
-		if (net_ratelimit())
-			pr_debug("cannot alloc skb\n");
+		net_dbg_ratelimited("cannot alloc skb\n");
 		dst_release(dst);
 		return;
 	}
@@ -210,8 +209,7 @@ reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		send_reset(net, skb);
 		break;
 	default:
-		if (net_ratelimit())
-			pr_info("case %u not handled yet\n", reject->with);
+		net_info_ratelimited("case %u not handled yet\n", reject->with);
 		break;
 	}
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 00d1917..4d78240 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -42,8 +42,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			pr_warning("ip6t_hook: happy cracking.\n");
+		net_warn_ratelimited("ip6t_hook: happy cracking\n");
 		return NF_ACCEPT;
 	}
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index fe925e4..3224ef9 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -232,8 +232,7 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct ipv6hdr)) {
-		if (net_ratelimit())
-			pr_notice("ipv6_conntrack_local: packet too short\n");
+		net_notice_ratelimited("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
 	return __ipv6_conntrack_in(dev_net(out), hooknum, skb, okfn);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 48a2be1..c9c78c2 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -444,12 +444,11 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	return head;
 
 out_oversize:
-	if (net_ratelimit())
-		printk(KERN_DEBUG "nf_ct_frag6_reasm: payload len = %d\n", payload_len);
+	net_dbg_ratelimited("nf_ct_frag6_reasm: payload len = %d\n",
+			    payload_len);
 	goto out_fail;
 out_oom:
-	if (net_ratelimit())
-		printk(KERN_DEBUG "nf_ct_frag6_reasm: no memory for reassembly\n");
+	net_dbg_ratelimited("nf_ct_frag6_reasm: no memory for reassembly\n");
 out_fail:
 	return NULL;
 }
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 54c5d2b..f1b86fd 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -518,12 +518,10 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	return 1;
 
 out_oversize:
-	if (net_ratelimit())
-		printk(KERN_DEBUG "ip6_frag_reasm: payload len = %d\n", payload_len);
+	net_dbg_ratelimited("ip6_frag_reasm: payload len = %d\n", payload_len);
 	goto out_fail;
 out_oom:
-	if (net_ratelimit())
-		printk(KERN_DEBUG "ip6_frag_reasm: no memory for reassembly\n");
+	net_dbg_ratelimited("ip6_frag_reasm: no memory for reassembly\n");
 out_fail:
 	rcu_read_lock();
 	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0aefc36..e20e320 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -794,9 +794,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
 				goto retry;
 			}
 
-			if (net_ratelimit())
-				printk(KERN_WARNING
-				       "ipv6: Neighbour table overflow.\n");
+			net_warn_ratelimited("ipv6: Neighbour table overflow\n");
 			dst_free(&rt->dst);
 			return NULL;
 		}
@@ -1643,9 +1641,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
 
 	if (rt == net->ipv6.ip6_null_entry) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "rt6_redirect: source isn't a valid nexthop "
-			       "for redirect target\n");
+		net_dbg_ratelimited("rt6_redirect: source isn't a valid nexthop for redirect target\n");
 		goto out;
 	}
 
@@ -2106,9 +2102,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	int err;
 
 	if (!rt) {
-		if (net_ratelimit())
-			pr_warning("IPv6:  Maximum number of routes reached,"
-				   " consider increasing route/max_size.\n");
+		net_warn_ratelimited("IPv6:  Maximum number of routes reached, consider increasing route/max_size\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e5fef94..a36a097 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -702,8 +702,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "sit: nexthop == NULL\n");
+			net_dbg_ratelimited("sit: nexthop == NULL\n");
 			goto tx_error;
 		}
 
@@ -732,8 +731,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
 		if (neigh == NULL) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "sit: nexthop == NULL\n");
+			net_dbg_ratelimited("sit: nexthop == NULL\n");
 			goto tx_error;
 		}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 078d039..4cf55ae 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -723,12 +723,10 @@ static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 				      NULL, NULL, skb);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash %s for [%pI6c]:%u->[%pI6c]:%u\n",
-			       genhash ? "failed" : "mismatch",
-			       &ip6h->saddr, ntohs(th->source),
-			       &ip6h->daddr, ntohs(th->dest));
-		}
+		net_info_ratelimited("MD5 Hash %s for [%pI6c]:%u->[%pI6c]:%u\n",
+				     genhash ? "failed" : "mismatch",
+				     &ip6h->saddr, ntohs(th->source),
+				     &ip6h->daddr, ntohs(th->dest));
 		return 1;
 	}
 	return 0;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 17bc85d..78424f4 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -806,10 +806,9 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 			sk_wait_data(sk, &timeo);
 
 		if ((flags & MSG_PEEK) && peek_seq != llc->copied_seq) {
-			if (net_ratelimit())
-				printk(KERN_DEBUG "LLC(%s:%d): Application "
-						  "bug, race in MSG_PEEK.\n",
-				       current->comm, task_pid_nr(current));
+			net_dbg_ratelimited("LLC(%s:%d): Application bug, race in MSG_PEEK\n",
+					    current->comm,
+					    task_pid_nr(current));
 			peek_seq = llc->copied_seq;
 		}
 		continue;
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index a070d4f..26ddb69 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -260,11 +260,8 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 	    (buf_size > IEEE80211_MAX_AMPDU_BUF)) {
 		status = WLAN_STATUS_INVALID_QOS_PARAM;
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_DEBUG "AddBA Req with bad params from "
-				"%pM on tid %u. policy %d, buffer size %d\n",
-				mgmt->sa, tid, ba_policy,
-				buf_size);
+		net_dbg_ratelimited("AddBA Req with bad params from %pM on tid %u. policy %d, buffer size %d\n",
+				    mgmt->sa, tid, ba_policy, buf_size);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 		goto end_no_lock;
 	}
@@ -281,10 +278,8 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 	if (sta->ampdu_mlme.tid_rx[tid]) {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-		if (net_ratelimit())
-			printk(KERN_DEBUG "unexpected AddBA Req from "
-				"%pM on tid %u\n",
-				mgmt->sa, tid);
+		net_dbg_ratelimited("unexpected AddBA Req from %pM on tid %u\n",
+				    mgmt->sa, tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 		/* delete existing Rx BA session on the same tid */
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 9b60336..6f8615c 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -306,10 +306,10 @@ void ieee80211_process_delba(struct ieee80211_sub_if_data *sdata,
 	initiator = (params & IEEE80211_DELBA_PARAM_INITIATOR_MASK) >> 11;
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	if (net_ratelimit())
-		printk(KERN_DEBUG "delba from %pM (%s) tid %d reason code %d\n",
-			mgmt->sa, initiator ? "initiator" : "recipient", tid,
-			le16_to_cpu(mgmt->u.action.u.delba.reason_code));
+	net_dbg_ratelimited("delba from %pM (%s) tid %d reason code %d\n",
+			    mgmt->sa, initiator ? "initiator" : "recipient",
+			    tid,
+			    le16_to_cpu(mgmt->u.action.u.delba.reason_code));
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	if (initiator == WLAN_BACK_INITIATOR)
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index d307d3b..de542c4 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -303,9 +303,8 @@ ieee80211_ibss_add_sta(struct ieee80211_sub_if_data *sdata,
 	 * 	allow new one to be added.
 	 */
 	if (local->num_sta >= IEEE80211_IBSS_MAX_STA_ENTRIES) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: No room for a new IBSS STA entry %pM\n",
-			       sdata->name, addr);
+		net_dbg_ratelimited("%s: No room for a new IBSS STA entry %pM\n",
+				    sdata->name, addr);
 		rcu_read_lock();
 		return NULL;
 	}
@@ -582,9 +581,8 @@ void ieee80211_ibss_rx_no_sta(struct ieee80211_sub_if_data *sdata,
 	 * 	allow new one to be added.
 	 */
 	if (local->num_sta >= IEEE80211_IBSS_MAX_STA_ENTRIES) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: No room for a new IBSS STA entry %pM\n",
-			       sdata->name, addr);
+		net_dbg_ratelimited("%s: No room for a new IBSS STA entry %pM\n",
+				    sdata->name, addr);
 		return;
 	}
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index b1c617f..fc17dd7 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1567,9 +1567,9 @@ static void ieee80211_mgd_probe_ap(struct ieee80211_sub_if_data *sdata,
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	if (beacon && net_ratelimit())
-		printk(KERN_DEBUG "%s: detected beacon loss from AP "
-		       "- sending probe request\n", sdata->name);
+	if (beacon)
+		net_dbg_ratelimited("%s: detected beacon loss from AP - sending probe request\n",
+				    sdata->name);
 #endif
 
 	/*
@@ -2404,10 +2404,8 @@ static void ieee80211_rx_mgmt_beacon(struct ieee80211_sub_if_data *sdata,
 
 	if (ifmgd->flags & IEEE80211_STA_BEACON_POLL) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: cancelling probereq poll due "
-			       "to a received beacon\n", sdata->name);
-		}
+		net_dbg_ratelimited("%s: cancelling probereq poll due to a received beacon\n",
+				    sdata->name);
 #endif
 		ifmgd->flags &= ~IEEE80211_STA_BEACON_POLL;
 		mutex_lock(&local->iflist_mtx);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index d722c40..8257a09 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1752,9 +1752,9 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 			 * local net stack and back to the wireless medium
 			 */
 			xmit_skb = skb_copy(skb, GFP_ATOMIC);
-			if (!xmit_skb && net_ratelimit())
-				printk(KERN_DEBUG "%s: failed to clone "
-				       "multicast frame\n", dev->name);
+			if (!xmit_skb)
+				net_dbg_ratelimited("%s: failed to clone multicast frame\n",
+						    dev->name);
 		} else {
 			dsta = sta_info_get(sdata, skb->data);
 			if (dsta) {
@@ -1957,9 +1957,8 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 
 	fwd_skb = skb_copy(skb, GFP_ATOMIC);
 	if (!fwd_skb) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: failed to clone mesh frame\n",
-					sdata->name);
+		net_dbg_ratelimited("%s: failed to clone mesh frame\n",
+				    sdata->name);
 		goto out;
 	}
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index e03abc7..5f827a6 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -413,9 +413,8 @@ ieee80211_tx_h_multicast_ps_buf(struct ieee80211_tx_data *tx)
 
 	if (skb_queue_len(&tx->sdata->bss->ps_bc_buf) >= AP_MAX_BC_BUFFER) {
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: BC TX buffer full - dropping the oldest frame\n",
-			       tx->sdata->name);
+		net_dbg_ratelimited("%s: BC TX buffer full - dropping the oldest frame\n",
+				    tx->sdata->name);
 #endif
 		dev_kfree_skb(skb_dequeue(&tx->sdata->bss->ps_bc_buf));
 	} else
@@ -476,10 +475,8 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 		if (skb_queue_len(&sta->ps_tx_buf[ac]) >= STA_MAX_TX_BUFFER) {
 			struct sk_buff *old = skb_dequeue(&sta->ps_tx_buf[ac]);
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-			if (net_ratelimit())
-				printk(KERN_DEBUG "%s: STA %pM TX buffer for "
-				       "AC %d full - dropping oldest frame\n",
-				       tx->sdata->name, sta->sta.addr, ac);
+			net_dbg_ratelimited("%s: STA %pM TX buffer for AC %d full - dropping oldest frame\n",
+					    tx->sdata->name, sta->sta.addr, ac);
 #endif
 			dev_kfree_skb(old);
 		} else
@@ -1965,10 +1962,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		     (cpu_to_be16(ethertype) != sdata->control_port_protocol ||
 		      !ether_addr_equal(sdata->vif.addr, skb->data + ETH_ALEN)))) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: dropped frame to %pM"
-			       " (unauthorized port)\n", dev->name,
-			       hdr.addr1);
+		net_dbg_ratelimited("%s: dropped frame to %pM (unauthorized port)\n",
+				    dev->name, hdr.addr1);
 #endif
 
 		I802_DEBUG_INC(local->tx_handlers_drop_unauth_port);
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 13fd2c5..f2de8c5 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -107,8 +107,7 @@ static int amanda_help(struct sk_buff *skb,
 	/* No data? */
 	dataoff = protoff + sizeof(struct udphdr);
 	if (dataoff >= skb->len) {
-		if (net_ratelimit())
-			printk(KERN_ERR "amanda_help: skblen = %u\n", skb->len);
+		net_err_ratelimited("amanda_help: skblen = %u\n", skb->len);
 		return NF_ACCEPT;
 	}
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 32c5909..ac3af97 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -683,10 +683,7 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
 		if (!early_drop(net, hash_bucket(hash, net))) {
 			atomic_dec(&net->ct.count);
-			if (net_ratelimit())
-				printk(KERN_WARNING
-				       "nf_conntrack: table full, dropping"
-				       " packet.\n");
+			net_warn_ratelimited("nf_conntrack: table full, dropping packet\n");
 			return ERR_PTR(-ENOMEM);
 		}
 	}
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4147ba3..45cf602 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -424,9 +424,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	}
 
 	if (net->ct.expect_count >= nf_ct_expect_max) {
-		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "nf_conntrack: expectation table full\n");
+		net_warn_ratelimited("nf_conntrack: expectation table full\n");
 		ret = -EMFILE;
 	}
 out:
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 471b054..93c13eb 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -605,8 +605,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 
       drop:
 	spin_unlock_bh(&nf_h323_lock);
-	if (net_ratelimit())
-		pr_info("nf_ct_h245: packet dropped\n");
+	net_info_ratelimited("nf_ct_h245: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1156,8 +1155,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 
       drop:
 	spin_unlock_bh(&nf_h323_lock);
-	if (net_ratelimit())
-		pr_info("nf_ct_q931: packet dropped\n");
+	net_info_ratelimited("nf_ct_q931: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1731,8 +1729,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 
       drop:
 	spin_unlock_bh(&nf_h323_lock);
-	if (net_ratelimit())
-		pr_info("nf_ct_ras: packet dropped\n");
+	net_info_ratelimited("nf_ct_ras: packet dropped\n");
 	return NF_DROP;
 }
 
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 4f9390b..81366c1 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -185,11 +185,9 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 			tuple = &ct->tuplehash[dir].tuple;
 			if (tuple->src.u3.ip != dcc_ip &&
 			    tuple->dst.u3.ip != dcc_ip) {
-				if (net_ratelimit())
-					printk(KERN_WARNING
-						"Forged DCC command from %pI4: %pI4:%u\n",
-						&tuple->src.u3.ip,
-						&dcc_ip, dcc_port);
+				net_warn_ratelimited("Forged DCC command from %pI4: %pI4:%u\n",
+						     &tuple->src.u3.ip,
+						     &dcc_ip, dcc_port);
 				continue;
 			}
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 8d6bcf3..4162437 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -395,8 +395,7 @@ nlmsg_failure:
 nla_put_failure:
 	if (skb)
 		kfree_skb(skb);
-	if (net_ratelimit())
-		printk(KERN_ERR "nf_queue: error creating packet message\n");
+	net_err_ratelimited("nf_queue: error creating packet message\n");
 	return NULL;
 }
 
@@ -433,10 +432,8 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	}
 	if (queue->queue_total >= queue->queue_maxlen) {
 		queue->queue_dropped++;
-		if (net_ratelimit())
-			  printk(KERN_WARNING "nf_queue: full at %d entries, "
-				 "dropping packets(s).\n",
-				 queue->queue_total);
+		net_warn_ratelimited("nf_queue: full at %d entries, dropping packets(s)\n",
+				     queue->queue_total);
 		goto err_out_free_nskb;
 	}
 	entry->id = ++queue->id_sequence;
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 190ad37..71a266d 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -67,15 +67,13 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
-			if (net_ratelimit())
-				pr_err("unknown or invalid path-MTU (%u)\n",
-				       dst_mtu(skb_dst(skb)));
+			net_err_ratelimited("unknown or invalid path-MTU (%u)\n",
+					    dst_mtu(skb_dst(skb)));
 			return -1;
 		}
 		if (in_mtu <= minlen) {
-			if (net_ratelimit())
-				pr_err("unknown or invalid path-MTU (%u)\n",
-				       in_mtu);
+			net_err_ratelimited("unknown or invalid path-MTU (%u)\n",
+					    in_mtu);
 			return -1;
 		}
 		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index d0424f9..5d5af1d 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -171,8 +171,7 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 
 	if (ht->cfg.max && ht->count >= ht->cfg.max) {
 		/* FIXME: do something. question is what.. */
-		if (net_ratelimit())
-			pr_err("max count of %u reached\n", ht->cfg.max);
+		net_err_ratelimited("max count of %u reached\n", ht->cfg.max);
 		ent = NULL;
 	} else
 		ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 5920bda..3fd6c0d 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -157,9 +157,9 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 	int len;
 
 	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
-		if (net_ratelimit())
-			pr_warn("%s: dropped over-mtu packet: %d > %d\n",
-				ovs_dp_name(vport->dp), packet_length(skb), mtu);
+		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
+				     ovs_dp_name(vport->dp),
+				     packet_length(skb), mtu);
 		goto error;
 	}
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 0beba0e..60e281a 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/ipt.c	iptables target interface
+ * net/sched/ipt.c     iptables target interface
  *
  *TODO: Add other tables. For now we only support the ipv4 table targets
  *
@@ -235,9 +235,8 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 		result = TC_ACT_PIPE;
 		break;
 	default:
-		if (net_ratelimit())
-			pr_notice("tc filter: Bogus netfilter code"
-				  " %d assume ACCEPT\n", ret);
+		net_notice_ratelimited("tc filter: Bogus netfilter code %d assume ACCEPT\n",
+				       ret);
 		result = TC_POLICE_OK;
 		break;
 	}
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index d583aea..fe81cc1 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -174,9 +174,8 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	if (!(dev->flags & IFF_UP)) {
-		if (net_ratelimit())
-			pr_notice("tc mirred to Houston: device %s is down\n",
-				  dev->name);
+		net_notice_ratelimited("tc mirred to Houston: device %s is down\n",
+				       dev->name);
 		goto out;
 	}
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 591b006..d45373f 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -234,8 +234,7 @@ out:
 	return -1;
 
 deadloop:
-	if (net_ratelimit())
-		pr_warning("cls_u32: dead loop\n");
+	net_warn_ratelimited("cls_u32: dead loop\n");
 	return -1;
 }
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index aca233c..3a633de 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -537,9 +537,7 @@ pop_stack:
 	return res;
 
 stack_overflow:
-	if (net_ratelimit())
-		pr_warning("tc ematch: local stack overflow,"
-			   " increase NET_EMATCH_STACK\n");
+	net_warn_ratelimited("tc ematch: local stack overflow, increase NET_EMATCH_STACK\n");
 	return -1;
 }
 EXPORT_SYMBOL(__tcf_em_tree_match);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d2daefc..085ce53 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1691,12 +1691,10 @@ reclassify:
 		tp = otp;
 
 		if (verd++ >= MAX_REC_LOOP) {
-			if (net_ratelimit())
-				pr_notice("%s: packet reclassify loop"
-					  " rule prio %u protocol %02x\n",
-					  tp->q->ops->id,
-					  tp->prio & 0xffff,
-					  ntohs(tp->protocol));
+			net_notice_ratelimited("%s: packet reclassify loop rule prio %u protocol %02x\n",
+					       tp->q->ops->id,
+					       tp->prio & 0xffff,
+					       ntohs(tp->protocol));
 			return TC_ACT_SHOT;
 		}
 		skb->tc_verd = SET_TC_VERD(skb->tc_verd, verd);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0eb1202..511323e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -86,9 +86,8 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * deadloop is detected. Return OK to try the next skb.
 		 */
 		kfree_skb(skb);
-		if (net_ratelimit())
-			pr_warning("Dead loop on netdevice %s, fix it urgently!\n",
-				   dev_queue->dev->name);
+		net_warn_ratelimited("Dead loop on netdevice %s, fix it urgently!\n",
+				     dev_queue->dev->name);
 		ret = qdisc_qlen(q);
 	} else {
 		/*
@@ -136,9 +135,9 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		ret = handle_dev_cpu_collision(skb, txq, q);
 	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
-		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
-			pr_warning("BUG %s code %d qlen %d\n",
-				   dev->name, ret, q->q.qlen);
+		if (unlikely(ret != NETDEV_TX_BUSY))
+			net_warn_ratelimited("BUG %s code %d qlen %d\n",
+					     dev->name, ret, q->q.qlen);
 
 		ret = dev_requeue_skb(skb, q);
 	}
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index ab620bf..e901583 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -255,10 +255,8 @@ static struct sk_buff *gred_dequeue(struct Qdisc *sch)
 		u16 dp = tc_index_to_dp(skb);
 
 		if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
-			if (net_ratelimit())
-				pr_warning("GRED: Unable to relocate VQ 0x%x "
-					   "after dequeue, screwing up "
-					   "backlog.\n", tc_index_to_dp(skb));
+			net_warn_ratelimited("GRED: Unable to relocate VQ 0x%x after dequeue, screwing up backlog\n",
+					     tc_index_to_dp(skb));
 		} else {
 			q->backlog -= qdisc_pkt_len(skb);
 
@@ -287,10 +285,8 @@ static unsigned int gred_drop(struct Qdisc *sch)
 		u16 dp = tc_index_to_dp(skb);
 
 		if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
-			if (net_ratelimit())
-				pr_warning("GRED: Unable to relocate VQ 0x%x "
-					   "while dropping, screwing up "
-					   "backlog.\n", tc_index_to_dp(skb));
+			net_warn_ratelimited("GRED: Unable to relocate VQ 0x%x while dropping, screwing up backlog\n",
+					     tc_index_to_dp(skb));
 		} else {
 			q->backlog -= len;
 			q->stats.other++;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index fbb374c..c96d1a8 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1161,9 +1161,8 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 		break;
 
 	case SCTP_DISPOSITION_VIOLATION:
-		if (net_ratelimit())
-			pr_err("protocol violation state %d chunkid %d\n",
-			       state, subtype.chunk);
+		net_err_ratelimited("protocol violation state %d chunkid %d\n",
+				    state, subtype.chunk);
 		break;
 
 	case SCTP_DISPOSITION_NOT_IMPL:
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index a147b4d..9fca103 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1129,17 +1129,15 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 	/* This should never happen, but lets log it if so.  */
 	if (unlikely(!link)) {
 		if (from_addr.sa.sa_family == AF_INET6) {
-			if (net_ratelimit())
-				pr_warn("%s association %p could not find address %pI6\n",
-					__func__,
-					asoc,
-					&from_addr.v6.sin6_addr);
+			net_warn_ratelimited("%s association %p could not find address %pI6\n",
+					     __func__,
+					     asoc,
+					     &from_addr.v6.sin6_addr);
 		} else {
-			if (net_ratelimit())
-				pr_warn("%s association %p could not find address %pI4\n",
-					__func__,
-					asoc,
-					&from_addr.v4.sin_addr.s_addr);
+			net_warn_ratelimited("%s association %p could not find address %pI4\n",
+					     __func__,
+					     asoc,
+					     &from_addr.v4.sin_addr.s_addr);
 		}
 		return SCTP_DISPOSITION_DISCARD;
 	}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 92ba71d..b3b8a8d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5840,10 +5840,8 @@ SCTP_STATIC int sctp_listen_start(struct sock *sk, int backlog)
 	if (!sctp_sk(sk)->hmac && sctp_hmac_alg) {
 		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
 		if (IS_ERR(tfm)) {
-			if (net_ratelimit()) {
-				pr_info("failed to load transform for %s: %ld\n",
-					sctp_hmac_alg, PTR_ERR(tfm));
-			}
+			net_info_ratelimited("failed to load transform for %s: %ld\n",
+					     sctp_hmac_alg, PTR_ERR(tfm));
 			return -ENOSYS;
 		}
 		sctp_sk(sk)->hmac = tfm;
diff --git a/net/socket.c b/net/socket.c
index d3aaa4f..2a2898c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1234,8 +1234,7 @@ int __sock_create(struct net *net, int family, int type, int protocol,
 	 */
 	sock = sock_alloc();
 	if (!sock) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "socket: no more sockets\n");
+		net_warn_ratelimited("socket: no more sockets\n");
 		return -ENFILE;	/* Not exactly a match, but its the
 				   closest posix thing */
 	}
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4153846..017c011 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1041,23 +1041,21 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
  * Printk the given error with the address of the client that caused it.
  */
 static __printf(2, 3)
-int svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
+void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
-	int 	r;
 	char 	buf[RPC_MAX_ADDRBUFLEN];
 
-	if (!net_ratelimit())
-		return 0;
+	va_start(args, fmt);
 
-	printk(KERN_WARNING "svc: %s: ",
-		svc_print_addr(rqstp, buf, sizeof(buf)));
+	vaf.fmt = fmt;
+	vaf.va = &args;
 
-	va_start(args, fmt);
-	r = vprintk(fmt, args);
-	va_end(args);
+	net_warn_ratelimited("svc: %s: %pV",
+			     svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
 
-	return r;
+	va_end(args);
 }
 
 /*
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4bda09d..b98ee35 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -544,14 +544,11 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 		struct svc_xprt *xprt = NULL;
 		spin_lock_bh(&serv->sv_lock);
 		if (!list_empty(&serv->sv_tempsocks)) {
-			if (net_ratelimit()) {
-				/* Try to help the admin */
-				printk(KERN_NOTICE "%s: too many open  "
-				       "connections, consider increasing %s\n",
-				       serv->sv_name, serv->sv_maxconn ?
-				       "the max number of connections." :
-				       "the number of threads.");
-			}
+			/* Try to help the admin */
+			net_notice_ratelimited("%s: too many open connections, consider increasing the %s\n",
+					       serv->sv_name, serv->sv_maxconn ?
+					       "max number of connections" :
+					       "number of threads");
 			/*
 			 * Always select the oldest connection. It's not fair,
 			 * but so is life
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f0132b2..a6de09d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -617,11 +617,8 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_prot = IPPROTO_UDP;
 
 	if (!svc_udp_get_dest_address(rqstp, cmh)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING
-				"svc: received unknown control message %d/%d; "
-				"dropping RPC reply datagram\n",
-					cmh->cmsg_level, cmh->cmsg_type);
+		net_warn_ratelimited("svc: received unknown control message %d/%d; dropping RPC reply datagram\n",
+				     cmh->cmsg_level, cmh->cmsg_type);
 		skb_free_datagram_locked(svsk->sk_sk, skb);
 		return 0;
 	}
@@ -871,18 +868,17 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 		if (err == -ENOMEM)
 			printk(KERN_WARNING "%s: no more sockets!\n",
 			       serv->sv_name);
-		else if (err != -EAGAIN && net_ratelimit())
-			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
-				   serv->sv_name, -err);
+		else if (err != -EAGAIN)
+			net_warn_ratelimited("%s: accept failed (err %d)!\n",
+					     serv->sv_name, -err);
 		return NULL;
 	}
 	set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 
 	err = kernel_getpeername(newsock, sin, &slen);
 	if (err < 0) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "%s: peername failed (err %d)!\n",
-				   serv->sv_name, -err);
+		net_warn_ratelimited("%s: peername failed (err %d)!\n",
+				     serv->sv_name, -err);
 		goto failed;		/* aborted connection or whatever */
 	}
 
@@ -1012,19 +1008,15 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 			 *  bit set in the fragment length header.
 			 *  But apparently no known nfs clients send fragmented
 			 *  records. */
-			if (net_ratelimit())
-				printk(KERN_NOTICE "RPC: multiple fragments "
-					"per record not supported\n");
+			net_notice_ratelimited("RPC: multiple fragments per record not supported\n");
 			goto err_delete;
 		}
 
 		svsk->sk_reclen &= RPC_FRAGMENT_SIZE_MASK;
 		dprintk("svc: TCP record, %d bytes\n", svsk->sk_reclen);
 		if (svsk->sk_reclen > serv->sv_max_mesg) {
-			if (net_ratelimit())
-				printk(KERN_NOTICE "RPC: "
-					"fragment too large: 0x%08lx\n",
-					(unsigned long)svsk->sk_reclen);
+			net_notice_ratelimited("RPC: fragment too large: 0x%08lx\n",
+					       (unsigned long)svsk->sk_reclen);
 			goto err_delete;
 		}
 	}
diff --git a/net/wireless/lib80211_crypt_ccmp.c b/net/wireless/lib80211_crypt_ccmp.c
index 755738d..1526c21 100644
--- a/net/wireless/lib80211_crypt_ccmp.c
+++ b/net/wireless/lib80211_crypt_ccmp.c
@@ -304,10 +304,8 @@ static int lib80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos = skb->data + hdr_len;
 	keyidx = pos[3];
 	if (!(keyidx & (1 << 5))) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: received packet without ExtIV"
-			       " flag from %pM\n", hdr->addr2);
-		}
+		net_dbg_ratelimited("CCMP: received packet without ExtIV flag from %pM\n",
+				    hdr->addr2);
 		key->dot11RSNAStatsCCMPFormatErrors++;
 		return -2;
 	}
@@ -318,11 +316,8 @@ static int lib80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		return -6;
 	}
 	if (!key->key_set) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: received packet from %pM"
-			       " with keyid=%d that does not have a configured"
-			       " key\n", hdr->addr2, keyidx);
-		}
+		net_dbg_ratelimited("CCMP: received packet from %pM with keyid=%d that does not have a configured key\n",
+				    hdr->addr2, keyidx);
 		return -3;
 	}
 
@@ -336,15 +331,11 @@ static int lib80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 
 	if (ccmp_replay_check(pn, key->rx_pn)) {
 #ifdef CONFIG_LIB80211_DEBUG
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: replay detected: STA=%pM "
-				 "previous PN %02x%02x%02x%02x%02x%02x "
-				 "received PN %02x%02x%02x%02x%02x%02x\n",
-				 hdr->addr2,
-				 key->rx_pn[0], key->rx_pn[1], key->rx_pn[2],
-				 key->rx_pn[3], key->rx_pn[4], key->rx_pn[5],
-				 pn[0], pn[1], pn[2], pn[3], pn[4], pn[5]);
-		}
+		net_dbg_ratelimited("CCMP: replay detected: STA=%pM previous PN %02x%02x%02x%02x%02x%02x received PN %02x%02x%02x%02x%02x%02x\n",
+				    hdr->addr2,
+				    key->rx_pn[0], key->rx_pn[1], key->rx_pn[2],
+				    key->rx_pn[3], key->rx_pn[4], key->rx_pn[5],
+				    pn[0], pn[1], pn[2], pn[3], pn[4], pn[5]);
 #endif
 		key->dot11RSNAStatsCCMPReplays++;
 		return -4;
@@ -370,10 +361,8 @@ static int lib80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	}
 
 	if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: decrypt failed: STA="
-			       "%pM\n", hdr->addr2);
-		}
+		net_dbg_ratelimited("CCMP: decrypt failed: STA=%pM\n",
+				    hdr->addr2);
 		key->dot11RSNAStatsCCMPDecryptErrors++;
 		return -5;
 	}
diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211_crypt_tkip.c
index 3873484..d475cfc 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -360,12 +360,9 @@ static int lib80211_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	struct scatterlist sg;
 
 	if (tkey->flags & IEEE80211_CRYPTO_TKIP_COUNTERMEASURES) {
-		if (net_ratelimit()) {
-			struct ieee80211_hdr *hdr =
-			    (struct ieee80211_hdr *)skb->data;
-			printk(KERN_DEBUG ": TKIP countermeasures: dropped "
-			       "TX packet to %pM\n", hdr->addr1);
-		}
+		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+		net_dbg_ratelimited("TKIP countermeasures: dropped TX packet to %pM\n",
+				    hdr->addr1);
 		return -1;
 	}
 
@@ -420,10 +417,8 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	hdr = (struct ieee80211_hdr *)skb->data;
 
 	if (tkey->flags & IEEE80211_CRYPTO_TKIP_COUNTERMEASURES) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG ": TKIP countermeasures: dropped "
-			       "received packet from %pM\n", hdr->addr2);
-		}
+		net_dbg_ratelimited("TKIP countermeasures: dropped received packet from %pM\n",
+				    hdr->addr2);
 		return -1;
 	}
 
@@ -433,10 +428,8 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos = skb->data + hdr_len;
 	keyidx = pos[3];
 	if (!(keyidx & (1 << 5))) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: received packet without ExtIV"
-			       " flag from %pM\n", hdr->addr2);
-		}
+		net_dbg_ratelimited("TKIP: received packet without ExtIV flag from %pM\n",
+				    hdr->addr2);
 		return -2;
 	}
 	keyidx >>= 6;
@@ -446,11 +439,8 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 		return -6;
 	}
 	if (!tkey->key_set) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: received packet from %pM"
-			       " with keyid=%d that does not have a configured"
-			       " key\n", hdr->addr2, keyidx);
-		}
+		net_dbg_ratelimited("TKIP: received packet from %pM with keyid=%d that does not have a configured key\n",
+				    hdr->addr2, keyidx);
 		return -3;
 	}
 	iv16 = (pos[0] << 8) | pos[2];
@@ -459,12 +449,9 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 
 	if (tkip_replay_check(iv32, iv16, tkey->rx_iv32, tkey->rx_iv16)) {
 #ifdef CONFIG_LIB80211_DEBUG
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: replay detected: STA=%pM"
-			       " previous TSC %08x%04x received TSC "
-			       "%08x%04x\n", hdr->addr2,
-			       tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
-		}
+		net_dbg_ratelimited("TKIP: replay detected: STA=%pM previous TSC %08x%04x received TSC %08x%04x\n",
+				    hdr->addr2, tkey->rx_iv32, tkey->rx_iv16,
+				    iv32, iv16);
 #endif
 		tkey->dot11RSNAStatsTKIPReplays++;
 		return -4;
@@ -481,11 +468,8 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	crypto_blkcipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
 	sg_init_one(&sg, pos, plen + 4);
 	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG ": TKIP: failed to decrypt "
-			       "received packet from %pM\n",
-			       hdr->addr2);
-		}
+		net_dbg_ratelimited("TKIP: failed to decrypt received packet from %pM\n",
+				    hdr->addr2);
 		return -7;
 	}
 
@@ -501,10 +485,8 @@ static int lib80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 			tkey->rx_phase1_done = 0;
 		}
 #ifdef CONFIG_LIB80211_DEBUG
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: ICV error detected: STA="
-			       "%pM\n", hdr->addr2);
-		}
+		net_dbg_ratelimited("TKIP: ICV error detected: STA=%pM\n",
+				    hdr->addr2);
 #endif
 		tkey->dot11RSNAStatsTKIPICVErrors++;
 		return -5;
-- 
1.7.8.111.gad25c.dirty

