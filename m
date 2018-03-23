Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0045.hostedemail.com ([216.40.44.45]:55065 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751899AbeCWWzt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2018 18:55:49 -0400
From: Joe Perches <joe@perches.com>
To: Joerg Reuter <jreuter@yaina.de>,
        Ralf Baechle <ralf@linux-mips.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Ilya Dryomov <idryomov@gmail.com>,
        "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
        James Chapman <jchapman@katalix.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        David Howells <dhowells@redhat.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Andrew Hendry <andrew.hendry@gmail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Cc: Marcel Holtmann <marcel@holtmann.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        bridge@lists.linux-foundation.org, linux-can@vger.kernel.org,
        ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-arm-kernel@lists.infradead.org,
        linux-wireless@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org
Subject: [PATCH 3/4] net: Use octal not symbolic permissions
Date: Fri, 23 Mar 2018 15:54:38 -0700
Message-Id: <738a74ff57f993d6b8f249425673413672d3fe70.1521845242.git.joe@perches.com>
In-Reply-To: <cover.1521845235.git.joe@perches.com>
References: <cover.1521845235.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prefer the direct use of octal for permissions.

Done with checkpatch -f --types=SYMBOLIC_PERMS --fix-inplace
and some typing.

Miscellanea:

o Whitespace neatening around these conversions.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlanproc.c                       |  6 ++---
 net/appletalk/atalk_proc.c                 |  8 +++---
 net/atm/atm_sysfs.c                        | 12 ++++-----
 net/atm/clip.c                             |  2 +-
 net/atm/lec.c                              |  2 +-
 net/atm/proc.c                             |  2 +-
 net/ax25/af_ax25.c                         |  6 ++---
 net/bluetooth/rfcomm/tty.c                 |  4 +--
 net/bridge/br_sysfs_br.c                   |  2 +-
 net/bridge/br_sysfs_if.c                   | 36 ++++++++++++-------------
 net/can/af_can.c                           |  2 +-
 net/can/gw.c                               |  2 +-
 net/ceph/ceph_common.c                     |  2 +-
 net/core/net-procfs.c                      |  6 ++---
 net/core/net-sysfs.c                       | 12 ++++-----
 net/core/sock.c                            |  2 +-
 net/decnet/af_decnet.c                     |  2 +-
 net/decnet/dn_dev.c                        |  2 +-
 net/decnet/dn_neigh.c                      |  2 +-
 net/decnet/dn_route.c                      |  2 +-
 net/dns_resolver/dns_key.c                 |  2 +-
 net/ipv4/arp.c                             |  2 +-
 net/ipv4/fib_trie.c                        |  6 ++---
 net/ipv4/igmp.c                            |  4 +--
 net/ipv4/ipconfig.c                        |  2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c         |  2 +-
 net/ipv4/ping.c                            |  2 +-
 net/ipv4/proc.c                            |  6 ++---
 net/ipv4/raw.c                             |  2 +-
 net/ipv4/route.c                           |  4 +--
 net/ipv4/tcp_ipv4.c                        |  2 +-
 net/ipv4/udp.c                             |  2 +-
 net/ipv6/addrconf.c                        |  2 +-
 net/ipv6/anycast.c                         |  2 +-
 net/ipv6/ip6_flowlabel.c                   |  2 +-
 net/ipv6/mcast.c                           |  4 +--
 net/ipv6/proc.c                            |  6 ++---
 net/ipv6/raw.c                             |  2 +-
 net/ipv6/route.c                           |  2 +-
 net/kcm/kcmproc.c                          |  4 +--
 net/l2tp/l2tp_ppp.c                        |  2 +-
 net/llc/llc_proc.c                         |  4 +--
 net/mac80211/rc80211_minstrel.c            |  2 +-
 net/mac80211/rc80211_minstrel_debugfs.c    |  8 +++---
 net/mac80211/rc80211_minstrel_ht_debugfs.c |  8 +++---
 net/netfilter/nf_conntrack_netbios_ns.c    |  2 +-
 net/netfilter/nf_conntrack_snmp.c          |  2 +-
 net/netfilter/nf_conntrack_standalone.c    |  2 +-
 net/netfilter/nf_log.c                     |  2 +-
 net/netfilter/nf_synproxy_core.c           |  2 +-
 net/netfilter/xt_IDLETIMER.c               |  2 +-
 net/netfilter/xt_recent.c                  |  4 +--
 net/netrom/af_netrom.c                     |  6 ++---
 net/rose/af_rose.c                         |  8 +++---
 net/rxrpc/af_rxrpc.c                       |  2 +-
 net/sctp/proc.c                            | 16 ++++++------
 net/sunrpc/auth_gss/svcauth_gss.c          |  2 +-
 net/sunrpc/cache.c                         | 10 +++----
 net/sunrpc/debugfs.c                       |  6 ++---
 net/sunrpc/rpc_pipe.c                      | 42 +++++++++++++++---------------
 net/wireless/wext-proc.c                   |  2 +-
 net/x25/x25_proc.c                         | 12 ++++-----
 net/xfrm/xfrm_proc.c                       |  2 +-
 63 files changed, 161 insertions(+), 161 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index a662ccc166df..a627a5db2125 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -148,8 +148,8 @@ int __net_init vlan_proc_init(struct net *net)
 	if (!vn->proc_vlan_dir)
 		goto err;
 
-	vn->proc_vlan_conf = proc_create(name_conf, S_IFREG|S_IRUSR|S_IWUSR,
-				     vn->proc_vlan_dir, &vlan_fops);
+	vn->proc_vlan_conf = proc_create(name_conf, S_IFREG | 0600,
+					 vn->proc_vlan_dir, &vlan_fops);
 	if (!vn->proc_vlan_conf)
 		goto err;
 	return 0;
@@ -172,7 +172,7 @@ int vlan_proc_add_dev(struct net_device *vlandev)
 	if (!strcmp(vlandev->name, name_conf))
 		return -EINVAL;
 	vlan->dent =
-		proc_create_data(vlandev->name, S_IFREG|S_IRUSR|S_IWUSR,
+		proc_create_data(vlandev->name, S_IFREG | 0600,
 				 vn->proc_vlan_dir, &vlandev_fops, vlandev);
 	if (!vlan->dent)
 		return -ENOBUFS;
diff --git a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
index a3bf9d519193..7214aea14cb3 100644
--- a/net/appletalk/atalk_proc.c
+++ b/net/appletalk/atalk_proc.c
@@ -257,22 +257,22 @@ int __init atalk_proc_init(void)
 	if (!atalk_proc_dir)
 		goto out;
 
-	p = proc_create("interface", S_IRUGO, atalk_proc_dir,
+	p = proc_create("interface", 0444, atalk_proc_dir,
 			&atalk_seq_interface_fops);
 	if (!p)
 		goto out_interface;
 
-	p = proc_create("route", S_IRUGO, atalk_proc_dir,
+	p = proc_create("route", 0444, atalk_proc_dir,
 			&atalk_seq_route_fops);
 	if (!p)
 		goto out_route;
 
-	p = proc_create("socket", S_IRUGO, atalk_proc_dir,
+	p = proc_create("socket", 0444, atalk_proc_dir,
 			&atalk_seq_socket_fops);
 	if (!p)
 		goto out_socket;
 
-	p = proc_create("arp", S_IRUGO, atalk_proc_dir, &atalk_seq_arp_fops);
+	p = proc_create("arp", 0444, atalk_proc_dir, &atalk_seq_arp_fops);
 	if (!p)
 		goto out_arp;
 
diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index 5d2fed9f5710..39b94ca5f65d 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -96,12 +96,12 @@ static ssize_t show_link_rate(struct device *cdev,
 	return scnprintf(buf, PAGE_SIZE, "%d\n", link_rate);
 }
 
-static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
-static DEVICE_ATTR(atmaddress, S_IRUGO, show_atmaddress, NULL);
-static DEVICE_ATTR(atmindex, S_IRUGO, show_atmindex, NULL);
-static DEVICE_ATTR(carrier, S_IRUGO, show_carrier, NULL);
-static DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
-static DEVICE_ATTR(link_rate, S_IRUGO, show_link_rate, NULL);
+static DEVICE_ATTR(address, 0444, show_address, NULL);
+static DEVICE_ATTR(atmaddress, 0444, show_atmaddress, NULL);
+static DEVICE_ATTR(atmindex, 0444, show_atmindex, NULL);
+static DEVICE_ATTR(carrier, 0444, show_carrier, NULL);
+static DEVICE_ATTR(type, 0444, show_type, NULL);
+static DEVICE_ATTR(link_rate, 0444, show_link_rate, NULL);
 
 static struct device_attribute *atm_attrs[] = {
 	&dev_attr_atmaddress,
diff --git a/net/atm/clip.c b/net/atm/clip.c
index d4f6029d5109..f07dbc632222 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -893,7 +893,7 @@ static int __init atm_clip_init(void)
 	{
 		struct proc_dir_entry *p;
 
-		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
+		p = proc_create("arp", 0444, atm_proc_root, &arp_seq_fops);
 		if (!p) {
 			pr_err("Unable to initialize /proc/net/atm/arp\n");
 			atm_clip_exit_noproc();
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 09a1f056712a..01d5d20a6eb1 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1042,7 +1042,7 @@ static int __init lane_module_init(void)
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
 
-	p = proc_create("lec", S_IRUGO, atm_proc_root, &lec_seq_fops);
+	p = proc_create("lec", 0444, atm_proc_root, &lec_seq_fops);
 	if (!p) {
 		pr_err("Unable to initialize /proc/net/atm/lec\n");
 		return -ENOMEM;
diff --git a/net/atm/proc.c b/net/atm/proc.c
index edc48edc95c1..55410c00c7e2 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -474,7 +474,7 @@ int __init atm_proc_init(void)
 	for (e = atm_proc_ents; e->name; e++) {
 		struct proc_dir_entry *dirent;
 
-		dirent = proc_create(e->name, S_IRUGO,
+		dirent = proc_create(e->name, 0444,
 				     atm_proc_root, e->proc_fops);
 		if (!dirent)
 			goto err_out_remove;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index c8319ed48485..2b41366fcad2 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1989,10 +1989,10 @@ static int __init ax25_init(void)
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
 
-	proc_create("ax25_route", S_IRUGO, init_net.proc_net,
+	proc_create("ax25_route", 0444, init_net.proc_net,
 		    &ax25_route_fops);
-	proc_create("ax25", S_IRUGO, init_net.proc_net, &ax25_info_fops);
-	proc_create("ax25_calls", S_IRUGO, init_net.proc_net, &ax25_uid_fops);
+	proc_create("ax25", 0444, init_net.proc_net, &ax25_info_fops);
+	proc_create("ax25_calls", 0444, init_net.proc_net, &ax25_uid_fops);
 out:
 	return rc;
 }
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 5f3074cb6b4d..5e44d842cc5d 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -210,8 +210,8 @@ static ssize_t show_channel(struct device *tty_dev, struct device_attribute *att
 	return sprintf(buf, "%d\n", dev->channel);
 }
 
-static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
-static DEVICE_ATTR(channel, S_IRUGO, show_channel, NULL);
+static DEVICE_ATTR(address, 0444, show_address, NULL);
+static DEVICE_ATTR(channel, 0444, show_channel, NULL);
 
 static struct rfcomm_dev *__rfcomm_dev_add(struct rfcomm_dev_req *req,
 					   struct rfcomm_dlc *dlc)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index b1be0dcfba6b..0318a69888d4 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -893,7 +893,7 @@ static ssize_t brforward_read(struct file *filp, struct kobject *kobj,
 
 static struct bin_attribute bridge_forward = {
 	.attr = { .name = SYSFS_BRIDGE_FDB,
-		  .mode = S_IRUGO, },
+		  .mode = 0444, },
 	.read = brforward_read,
 };
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 126a8ea73c96..fd31ad83ec7b 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -44,7 +44,7 @@ static int store_##_name(struct net_bridge_port *p, unsigned long v) \
 {								\
 	return store_flag(p, v, _mask);				\
 }								\
-static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
+static BRPORT_ATTR(_name, 0644,					\
 		   show_##_name, store_##_name)
 
 static int store_flag(struct net_bridge_port *p, unsigned long v,
@@ -71,7 +71,7 @@ static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
 	return sprintf(buf, "%d\n", p->path_cost);
 }
 
-static BRPORT_ATTR(path_cost, S_IRUGO | S_IWUSR,
+static BRPORT_ATTR(path_cost, 0644,
 		   show_path_cost, br_stp_set_path_cost);
 
 static ssize_t show_priority(struct net_bridge_port *p, char *buf)
@@ -79,91 +79,91 @@ static ssize_t show_priority(struct net_bridge_port *p, char *buf)
 	return sprintf(buf, "%d\n", p->priority);
 }
 
-static BRPORT_ATTR(priority, S_IRUGO | S_IWUSR,
+static BRPORT_ATTR(priority, 0644,
 			 show_priority, br_stp_set_port_priority);
 
 static ssize_t show_designated_root(struct net_bridge_port *p, char *buf)
 {
 	return br_show_bridge_id(buf, &p->designated_root);
 }
-static BRPORT_ATTR(designated_root, S_IRUGO, show_designated_root, NULL);
+static BRPORT_ATTR(designated_root, 0444, show_designated_root, NULL);
 
 static ssize_t show_designated_bridge(struct net_bridge_port *p, char *buf)
 {
 	return br_show_bridge_id(buf, &p->designated_bridge);
 }
-static BRPORT_ATTR(designated_bridge, S_IRUGO, show_designated_bridge, NULL);
+static BRPORT_ATTR(designated_bridge, 0444, show_designated_bridge, NULL);
 
 static ssize_t show_designated_port(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->designated_port);
 }
-static BRPORT_ATTR(designated_port, S_IRUGO, show_designated_port, NULL);
+static BRPORT_ATTR(designated_port, 0444, show_designated_port, NULL);
 
 static ssize_t show_designated_cost(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->designated_cost);
 }
-static BRPORT_ATTR(designated_cost, S_IRUGO, show_designated_cost, NULL);
+static BRPORT_ATTR(designated_cost, 0444, show_designated_cost, NULL);
 
 static ssize_t show_port_id(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "0x%x\n", p->port_id);
 }
-static BRPORT_ATTR(port_id, S_IRUGO, show_port_id, NULL);
+static BRPORT_ATTR(port_id, 0444, show_port_id, NULL);
 
 static ssize_t show_port_no(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "0x%x\n", p->port_no);
 }
 
-static BRPORT_ATTR(port_no, S_IRUGO, show_port_no, NULL);
+static BRPORT_ATTR(port_no, 0444, show_port_no, NULL);
 
 static ssize_t show_change_ack(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->topology_change_ack);
 }
-static BRPORT_ATTR(change_ack, S_IRUGO, show_change_ack, NULL);
+static BRPORT_ATTR(change_ack, 0444, show_change_ack, NULL);
 
 static ssize_t show_config_pending(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->config_pending);
 }
-static BRPORT_ATTR(config_pending, S_IRUGO, show_config_pending, NULL);
+static BRPORT_ATTR(config_pending, 0444, show_config_pending, NULL);
 
 static ssize_t show_port_state(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->state);
 }
-static BRPORT_ATTR(state, S_IRUGO, show_port_state, NULL);
+static BRPORT_ATTR(state, 0444, show_port_state, NULL);
 
 static ssize_t show_message_age_timer(struct net_bridge_port *p,
 					    char *buf)
 {
 	return sprintf(buf, "%ld\n", br_timer_value(&p->message_age_timer));
 }
-static BRPORT_ATTR(message_age_timer, S_IRUGO, show_message_age_timer, NULL);
+static BRPORT_ATTR(message_age_timer, 0444, show_message_age_timer, NULL);
 
 static ssize_t show_forward_delay_timer(struct net_bridge_port *p,
 					    char *buf)
 {
 	return sprintf(buf, "%ld\n", br_timer_value(&p->forward_delay_timer));
 }
-static BRPORT_ATTR(forward_delay_timer, S_IRUGO, show_forward_delay_timer, NULL);
+static BRPORT_ATTR(forward_delay_timer, 0444, show_forward_delay_timer, NULL);
 
 static ssize_t show_hold_timer(struct net_bridge_port *p,
 					    char *buf)
 {
 	return sprintf(buf, "%ld\n", br_timer_value(&p->hold_timer));
 }
-static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
+static BRPORT_ATTR(hold_timer, 0444, show_hold_timer, NULL);
 
 static int store_flush(struct net_bridge_port *p, unsigned long v)
 {
 	br_fdb_delete_by_port(p->br, p, 0, 0); // Don't delete local entry
 	return 0;
 }
-static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
+static BRPORT_ATTR(flush, 0200, NULL, store_flush);
 
 static ssize_t show_group_fwd_mask(struct net_bridge_port *p, char *buf)
 {
@@ -179,7 +179,7 @@ static int store_group_fwd_mask(struct net_bridge_port *p,
 
 	return 0;
 }
-static BRPORT_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_mask,
+static BRPORT_ATTR(group_fwd_mask, 0644, show_group_fwd_mask,
 		   store_group_fwd_mask);
 
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
@@ -204,7 +204,7 @@ static int store_multicast_router(struct net_bridge_port *p,
 {
 	return br_multicast_set_port_router(p, v);
 }
-static BRPORT_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
+static BRPORT_ATTR(multicast_router, 0644, show_multicast_router,
 		   store_multicast_router);
 
 BRPORT_ATTR_FLAG(multicast_fast_leave, BR_MULTICAST_FAST_LEAVE);
diff --git a/net/can/af_can.c b/net/can/af_can.c
index e899970398a1..2f0d0a72e4b5 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -72,7 +72,7 @@ MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>, "
 MODULE_ALIAS_NETPROTO(PF_CAN);
 
 static int stats_timer __read_mostly = 1;
-module_param(stats_timer, int, S_IRUGO);
+module_param(stats_timer, int, 0444);
 MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
 
 static struct kmem_cache *rcv_cache __read_mostly;
diff --git a/net/can/gw.c b/net/can/gw.c
index 08e97668d5cf..8d71e199d5b3 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -72,7 +72,7 @@ MODULE_ALIAS(CAN_GW_NAME);
 #define CGW_DEFAULT_HOPS 1
 
 static unsigned int max_hops __read_mostly = CGW_DEFAULT_HOPS;
-module_param(max_hops, uint, S_IRUGO);
+module_param(max_hops, uint, 0444);
 MODULE_PARM_DESC(max_hops,
 		 "maximum " CAN_GW_NAME " routing hops for CAN frames "
 		 "(valid values: " __stringify(CGW_MIN_HOPS) "-"
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index 4d4c82229e9e..4adf07826f4a 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -54,7 +54,7 @@ static const struct kernel_param_ops param_ops_supported_features = {
 	.get = param_get_supported_features,
 };
 module_param_cb(supported_features, &param_ops_supported_features, NULL,
-		S_IRUGO);
+		0444);
 
 const char *ceph_msg_type_name(int type)
 {
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 65b51e778782..dd6ae431d038 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -315,12 +315,12 @@ static int __net_init dev_proc_net_init(struct net *net)
 {
 	int rc = -ENOMEM;
 
-	if (!proc_create("dev", S_IRUGO, net->proc_net, &dev_seq_fops))
+	if (!proc_create("dev", 0444, net->proc_net, &dev_seq_fops))
 		goto out;
-	if (!proc_create("softnet_stat", S_IRUGO, net->proc_net,
+	if (!proc_create("softnet_stat", 0444, net->proc_net,
 			 &softnet_seq_fops))
 		goto out_dev;
-	if (!proc_create("ptype", S_IRUGO, net->proc_net, &ptype_seq_fops))
+	if (!proc_create("ptype", 0444, net->proc_net, &ptype_seq_fops))
 		goto out_softnet;
 
 	if (wext_proc_init(net))
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 60a5ad2c33ee..c476f0794132 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -431,7 +431,7 @@ static ssize_t group_store(struct device *dev, struct device_attribute *attr,
 	return netdev_store(dev, attr, buf, len, change_group);
 }
 NETDEVICE_SHOW(group, fmt_dec);
-static DEVICE_ATTR(netdev_group, S_IRUGO | S_IWUSR, group_show, group_store);
+static DEVICE_ATTR(netdev_group, 0644, group_show, group_store);
 
 static int change_proto_down(struct net_device *dev, unsigned long proto_down)
 {
@@ -854,10 +854,10 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 }
 
 static struct rx_queue_attribute rps_cpus_attribute __ro_after_init
-	= __ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
+	= __ATTR(rps_cpus, 0644, show_rps_map, store_rps_map);
 
 static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute __ro_after_init
-	= __ATTR(rps_flow_cnt, S_IRUGO | S_IWUSR,
+	= __ATTR(rps_flow_cnt, 0644,
 		 show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
 #endif /* CONFIG_RPS */
 
@@ -1154,7 +1154,7 @@ static ssize_t bql_set_hold_time(struct netdev_queue *queue,
 }
 
 static struct netdev_queue_attribute bql_hold_time_attribute __ro_after_init
-	= __ATTR(hold_time, S_IRUGO | S_IWUSR,
+	= __ATTR(hold_time, 0644,
 		 bql_show_hold_time, bql_set_hold_time);
 
 static ssize_t bql_show_inflight(struct netdev_queue *queue,
@@ -1166,7 +1166,7 @@ static ssize_t bql_show_inflight(struct netdev_queue *queue,
 }
 
 static struct netdev_queue_attribute bql_inflight_attribute __ro_after_init =
-	__ATTR(inflight, S_IRUGO, bql_show_inflight, NULL);
+	__ATTR(inflight, 0444, bql_show_inflight, NULL);
 
 #define BQL_ATTR(NAME, FIELD)						\
 static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\
@@ -1182,7 +1182,7 @@ static ssize_t bql_set_ ## NAME(struct netdev_queue *queue,		\
 }									\
 									\
 static struct netdev_queue_attribute bql_ ## NAME ## _attribute __ro_after_init \
-	= __ATTR(NAME, S_IRUGO | S_IWUSR,				\
+	= __ATTR(NAME, 0644,				\
 		 bql_show_ ## NAME, bql_set_ ## NAME)
 
 BQL_ATTR(limit, limit);
diff --git a/net/core/sock.c b/net/core/sock.c
index e689496dfd8a..8cee2920a47f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3455,7 +3455,7 @@ static const struct file_operations proto_seq_fops = {
 
 static __net_init int proto_init_net(struct net *net)
 {
-	if (!proc_create("protocols", S_IRUGO, net->proc_net, &proto_seq_fops))
+	if (!proc_create("protocols", 0444, net->proc_net, &proto_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2ee8306c23e3..32751602767f 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2383,7 +2383,7 @@ static int __init decnet_init(void)
 	dev_add_pack(&dn_dix_packet_type);
 	register_netdevice_notifier(&dn_dev_notifier);
 
-	proc_create("decnet", S_IRUGO, init_net.proc_net, &dn_socket_seq_fops);
+	proc_create("decnet", 0444, init_net.proc_net, &dn_socket_seq_fops);
 	dn_register_sysctl();
 out:
 	return rc;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index c9f5e1ebb9c8..c03b046478c3 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1424,7 +1424,7 @@ void __init dn_dev_init(void)
 	rtnl_register_module(THIS_MODULE, PF_DECnet, RTM_GETADDR,
 			     NULL, dn_nl_dump_ifaddr, 0);
 
-	proc_create("decnet_dev", S_IRUGO, init_net.proc_net, &dn_dev_seq_fops);
+	proc_create("decnet_dev", 0444, init_net.proc_net, &dn_dev_seq_fops);
 
 #ifdef CONFIG_SYSCTL
 	{
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 6e37d9e6345e..13156165afa3 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -608,7 +608,7 @@ static const struct file_operations dn_neigh_seq_fops = {
 void __init dn_neigh_init(void)
 {
 	neigh_table_init(NEIGH_DN_TABLE, &dn_neigh_table);
-	proc_create("decnet_neigh", S_IRUGO, init_net.proc_net,
+	proc_create("decnet_neigh", 0444, init_net.proc_net,
 		    &dn_neigh_seq_fops);
 }
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index ef20b8e31669..eca0cc6b761f 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1918,7 +1918,7 @@ void __init dn_route_init(void)
 
 	dn_dst_ops.gc_thresh = (dn_rt_hash_mask + 1);
 
-	proc_create("decnet_cache", S_IRUGO, init_net.proc_net,
+	proc_create("decnet_cache", 0444, init_net.proc_net,
 		    &dn_rt_cache_seq_fops);
 
 #ifdef CONFIG_DECNET_ROUTER
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index e1d4d898a007..8396705deffc 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -38,7 +38,7 @@ MODULE_AUTHOR("Wang Lei");
 MODULE_LICENSE("GPL");
 
 unsigned int dns_resolver_debug;
-module_param_named(debug, dns_resolver_debug, uint, S_IWUSR | S_IRUGO);
+module_param_named(debug, dns_resolver_debug, uint, 0644);
 MODULE_PARM_DESC(debug, "DNS Resolver debugging mask");
 
 const struct cred *dns_resolver_cache;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7dc9de8444a9..4c6ba0fb2630 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1434,7 +1434,7 @@ static const struct file_operations arp_seq_fops = {
 
 static int __net_init arp_net_init(struct net *net)
 {
-	if (!proc_create("arp", S_IRUGO, net->proc_net, &arp_seq_fops))
+	if (!proc_create("arp", 0444, net->proc_net, &arp_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 62243a8abf92..fac0b73e24d1 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2722,14 +2722,14 @@ static const struct file_operations fib_route_fops = {
 
 int __net_init fib_proc_init(struct net *net)
 {
-	if (!proc_create("fib_trie", S_IRUGO, net->proc_net, &fib_trie_fops))
+	if (!proc_create("fib_trie", 0444, net->proc_net, &fib_trie_fops))
 		goto out1;
 
-	if (!proc_create("fib_triestat", S_IRUGO, net->proc_net,
+	if (!proc_create("fib_triestat", 0444, net->proc_net,
 			 &fib_triestat_fops))
 		goto out2;
 
-	if (!proc_create("route", S_IRUGO, net->proc_net, &fib_route_fops))
+	if (!proc_create("route", 0444, net->proc_net, &fib_route_fops))
 		goto out3;
 
 	return 0;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c2743763777e..f17cd83ba164 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2993,10 +2993,10 @@ static int __net_init igmp_net_init(struct net *net)
 	struct proc_dir_entry *pde;
 	int err;
 
-	pde = proc_create("igmp", S_IRUGO, net->proc_net, &igmp_mc_seq_fops);
+	pde = proc_create("igmp", 0444, net->proc_net, &igmp_mc_seq_fops);
 	if (!pde)
 		goto out_igmp;
-	pde = proc_create("mcfilter", S_IRUGO, net->proc_net,
+	pde = proc_create("mcfilter", 0444, net->proc_net,
 			  &igmp_mcf_seq_fops);
 	if (!pde)
 		goto out_mcfilter;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f75802ad960f..43f620feb1c4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1369,7 +1369,7 @@ static int __init ip_auto_config(void)
 	unsigned int i;
 
 #ifdef CONFIG_PROC_FS
-	proc_create("pnp", S_IRUGO, init_net.proc_net, &pnp_seq_fops);
+	proc_create("pnp", 0444, init_net.proc_net, &pnp_seq_fops);
 #endif /* CONFIG_PROC_FS */
 
 	if (!ic_enable)
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 0fc88fa7a4dc..31b4cca588d0 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -250,7 +250,7 @@ clusterip_config_init(struct net *net, const struct ipt_clusterip_tgt_info *i,
 
 		/* create proc dir entry */
 		sprintf(buffer, "%pI4", &ip);
-		c->pde = proc_create_data(buffer, S_IWUSR|S_IRUSR,
+		c->pde = proc_create_data(buffer, 0600,
 					  cn->procdir,
 					  &clusterip_proc_fops, c);
 		if (!c->pde) {
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 0164def9c808..1f24bc8273a0 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1177,7 +1177,7 @@ static struct ping_seq_afinfo ping_v4_seq_afinfo = {
 int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo)
 {
 	struct proc_dir_entry *p;
-	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
+	p = proc_create_data(afinfo->name, 0444, net->proc_net,
 			     afinfo->seq_fops, afinfo);
 	if (!p)
 		return -ENOMEM;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 4e1959c859ce..c676c4a8cdfb 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -521,12 +521,12 @@ static const struct file_operations netstat_seq_fops = {
 
 static __net_init int ip_proc_init_net(struct net *net)
 {
-	if (!proc_create("sockstat", S_IRUGO, net->proc_net,
+	if (!proc_create("sockstat", 0444, net->proc_net,
 			 &sockstat_seq_fops))
 		goto out_sockstat;
-	if (!proc_create("netstat", S_IRUGO, net->proc_net, &netstat_seq_fops))
+	if (!proc_create("netstat", 0444, net->proc_net, &netstat_seq_fops))
 		goto out_netstat;
-	if (!proc_create("snmp", S_IRUGO, net->proc_net, &snmp_seq_fops))
+	if (!proc_create("snmp", 0444, net->proc_net, &snmp_seq_fops))
 		goto out_snmp;
 
 	return 0;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 720bef7da2f6..0ee2501a9027 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -1140,7 +1140,7 @@ static const struct file_operations raw_seq_fops = {
 
 static __net_init int raw_init_net(struct net *net)
 {
-	if (!proc_create("raw", S_IRUGO, net->proc_net, &raw_seq_fops))
+	if (!proc_create("raw", 0444, net->proc_net, &raw_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e54163e8f1b0..7c5b753b00b9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -378,12 +378,12 @@ static int __net_init ip_rt_do_proc_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_create("rt_cache", S_IRUGO, net->proc_net,
+	pde = proc_create("rt_cache", 0444, net->proc_net,
 			  &rt_cache_seq_fops);
 	if (!pde)
 		goto err1;
 
-	pde = proc_create("rt_cache", S_IRUGO,
+	pde = proc_create("rt_cache", 0444,
 			  net->proc_net_stat, &rt_cpu_seq_fops);
 	if (!pde)
 		goto err2;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2c6aec2643e8..fec8b1fd7b63 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2215,7 +2215,7 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	afinfo->seq_ops.next		= tcp_seq_next;
 	afinfo->seq_ops.stop		= tcp_seq_stop;
 
-	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
+	p = proc_create_data(afinfo->name, 0444, net->proc_net,
 			     afinfo->seq_fops, afinfo);
 	if (!p)
 		rc = -ENOMEM;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 908fc02fb4f8..e55b3177d4b1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2673,7 +2673,7 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	afinfo->seq_ops.next		= udp_seq_next;
 	afinfo->seq_ops.stop		= udp_seq_stop;
 
-	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
+	p = proc_create_data(afinfo->name, 0444, net->proc_net,
 			     afinfo->seq_fops, afinfo);
 	if (!p)
 		rc = -ENOMEM;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6fd4bbdc444f..9ca90cd9fba4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4281,7 +4281,7 @@ static const struct file_operations if6_fops = {
 
 static int __net_init if6_proc_net_init(struct net *net)
 {
-	if (!proc_create("if_inet6", S_IRUGO, net->proc_net, &if6_fops))
+	if (!proc_create("if_inet6", 0444, net->proc_net, &if6_fops))
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index d580d4d456a5..bbcabbba9bd8 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -544,7 +544,7 @@ static const struct file_operations ac6_seq_fops = {
 
 int __net_init ac6_proc_init(struct net *net)
 {
-	if (!proc_create("anycast6", S_IRUGO, net->proc_net, &ac6_seq_fops))
+	if (!proc_create("anycast6", 0444, net->proc_net, &ac6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 6ddf52282894..f75b06ba8325 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -844,7 +844,7 @@ static const struct file_operations ip6fl_seq_fops = {
 
 static int __net_init ip6_flowlabel_proc_init(struct net *net)
 {
-	if (!proc_create("ip6_flowlabel", S_IRUGO, net->proc_net,
+	if (!proc_create("ip6_flowlabel", 0444, net->proc_net,
 			 &ip6fl_seq_fops))
 		return -ENOMEM;
 	return 0;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d1a0cefac273..1e4c2b6ebd78 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2921,9 +2921,9 @@ static int __net_init igmp6_proc_init(struct net *net)
 	int err;
 
 	err = -ENOMEM;
-	if (!proc_create("igmp6", S_IRUGO, net->proc_net, &igmp6_mc_seq_fops))
+	if (!proc_create("igmp6", 0444, net->proc_net, &igmp6_mc_seq_fops))
 		goto out;
-	if (!proc_create("mcfilter6", S_IRUGO, net->proc_net,
+	if (!proc_create("mcfilter6", 0444, net->proc_net,
 			 &igmp6_mcf_seq_fops))
 		goto out_proc_net_igmp6;
 
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 3031bcf4a719..405274beaa86 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -288,7 +288,7 @@ int snmp6_register_dev(struct inet6_dev *idev)
 	if (!net->mib.proc_net_devsnmp6)
 		return -ENOENT;
 
-	p = proc_create_data(idev->dev->name, S_IRUGO,
+	p = proc_create_data(idev->dev->name, 0444,
 			     net->mib.proc_net_devsnmp6,
 			     &snmp6_dev_seq_fops, idev);
 	if (!p)
@@ -312,11 +312,11 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
 
 static int __net_init ipv6_proc_init_net(struct net *net)
 {
-	if (!proc_create("sockstat6", S_IRUGO, net->proc_net,
+	if (!proc_create("sockstat6", 0444, net->proc_net,
 			 &sockstat6_seq_fops))
 		return -ENOMEM;
 
-	if (!proc_create("snmp6", S_IRUGO, net->proc_net, &snmp6_seq_fops))
+	if (!proc_create("snmp6", 0444, net->proc_net, &snmp6_seq_fops))
 		goto proc_snmp6_fail;
 
 	net->mib.proc_net_devsnmp6 = proc_mkdir("dev_snmp6", net->proc_net);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 10a4ac4933b7..b5e5de732494 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1318,7 +1318,7 @@ static const struct file_operations raw6_seq_fops = {
 
 static int __net_init raw6_init_net(struct net *net)
 {
-	if (!proc_create("raw6", S_IRUGO, net->proc_net, &raw6_seq_fops))
+	if (!proc_create("raw6", 0444, net->proc_net, &raw6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a2ed9fdd58d4..1d0eaa69874d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -5067,7 +5067,7 @@ static int __net_init ip6_route_net_init_late(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	proc_create("ipv6_route", 0, net->proc_net, &ipv6_route_proc_fops);
-	proc_create("rt6_stats", S_IRUGO, net->proc_net, &rt6_stats_seq_fops);
+	proc_create("rt6_stats", 0444, net->proc_net, &rt6_stats_seq_fops);
 #endif
 	return 0;
 }
diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index 2c1c8b3e4452..4c2e9907f254 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -269,7 +269,7 @@ static int kcm_proc_register(struct net *net, struct kcm_seq_muxinfo *muxinfo)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	p = proc_create_data(muxinfo->name, S_IRUGO, net->proc_net,
+	p = proc_create_data(muxinfo->name, 0444, net->proc_net,
 			     muxinfo->seq_fops, muxinfo);
 	if (!p)
 		rc = -ENOMEM;
@@ -406,7 +406,7 @@ static int kcm_proc_init_net(struct net *net)
 {
 	int err;
 
-	if (!proc_create("kcm_stats", S_IRUGO, net->proc_net,
+	if (!proc_create("kcm_stats", 0444, net->proc_net,
 			 &kcm_stats_seq_fops)) {
 		err = -ENOMEM;
 		goto out_kcm_stats;
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 977bca659787..f24504efe729 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1742,7 +1742,7 @@ static __net_init int pppol2tp_init_net(struct net *net)
 	struct proc_dir_entry *pde;
 	int err = 0;
 
-	pde = proc_create("pppol2tp", S_IRUGO, net->proc_net,
+	pde = proc_create("pppol2tp", 0444, net->proc_net,
 			  &pppol2tp_proc_fops);
 	if (!pde) {
 		err = -ENOMEM;
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 66821e8a2b7a..62ea0aed94b4 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -249,11 +249,11 @@ int __init llc_proc_init(void)
 	if (!llc_proc_dir)
 		goto out;
 
-	p = proc_create("socket", S_IRUGO, llc_proc_dir, &llc_seq_socket_fops);
+	p = proc_create("socket", 0444, llc_proc_dir, &llc_seq_socket_fops);
 	if (!p)
 		goto out_socket;
 
-	p = proc_create("core", S_IRUGO, llc_proc_dir, &llc_seq_core_fops);
+	p = proc_create("core", 0444, llc_proc_dir, &llc_seq_core_fops);
 	if (!p)
 		goto out_core;
 
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 9766c1cc4b0a..8221bc5582ab 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -690,7 +690,7 @@ minstrel_alloc(struct ieee80211_hw *hw, struct dentry *debugfsdir)
 #ifdef CONFIG_MAC80211_DEBUGFS
 	mp->fixed_rate_idx = (u32) -1;
 	mp->dbg_fixed_rate = debugfs_create_u32("fixed_rate_idx",
-			S_IRUGO | S_IWUGO, debugfsdir, &mp->fixed_rate_idx);
+			0666, debugfsdir, &mp->fixed_rate_idx);
 #endif
 
 	minstrel_init_cck_rates(mp);
diff --git a/net/mac80211/rc80211_minstrel_debugfs.c b/net/mac80211/rc80211_minstrel_debugfs.c
index 36fc971deb86..9ad7d63d3e5b 100644
--- a/net/mac80211/rc80211_minstrel_debugfs.c
+++ b/net/mac80211/rc80211_minstrel_debugfs.c
@@ -214,11 +214,11 @@ minstrel_add_sta_debugfs(void *priv, void *priv_sta, struct dentry *dir)
 {
 	struct minstrel_sta_info *mi = priv_sta;
 
-	mi->dbg_stats = debugfs_create_file("rc_stats", S_IRUGO, dir, mi,
-			&minstrel_stat_fops);
+	mi->dbg_stats = debugfs_create_file("rc_stats", 0444, dir, mi,
+					    &minstrel_stat_fops);
 
-	mi->dbg_stats_csv = debugfs_create_file("rc_stats_csv", S_IRUGO, dir,
-			mi, &minstrel_stat_csv_fops);
+	mi->dbg_stats_csv = debugfs_create_file("rc_stats_csv", 0444, dir, mi,
+						&minstrel_stat_csv_fops);
 }
 
 void
diff --git a/net/mac80211/rc80211_minstrel_ht_debugfs.c b/net/mac80211/rc80211_minstrel_ht_debugfs.c
index 7d969e300fb3..bfcc03152dc6 100644
--- a/net/mac80211/rc80211_minstrel_ht_debugfs.c
+++ b/net/mac80211/rc80211_minstrel_ht_debugfs.c
@@ -303,10 +303,10 @@ minstrel_ht_add_sta_debugfs(void *priv, void *priv_sta, struct dentry *dir)
 {
 	struct minstrel_ht_sta_priv *msp = priv_sta;
 
-	msp->dbg_stats = debugfs_create_file("rc_stats", S_IRUGO, dir, msp,
-			&minstrel_ht_stat_fops);
-	msp->dbg_stats_csv = debugfs_create_file("rc_stats_csv", S_IRUGO,
-			     dir, msp, &minstrel_ht_stat_csv_fops);
+	msp->dbg_stats = debugfs_create_file("rc_stats", 0444, dir, msp,
+					     &minstrel_ht_stat_fops);
+	msp->dbg_stats_csv = debugfs_create_file("rc_stats_csv", 0444, dir, msp,
+						 &minstrel_ht_stat_csv_fops);
 }
 
 void
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index a4a59dc7cf17..bac5848f1c8e 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -33,7 +33,7 @@ MODULE_ALIAS("ip_conntrack_netbios_ns");
 MODULE_ALIAS_NFCT_HELPER("netbios_ns");
 
 static unsigned int timeout __read_mostly = 3;
-module_param(timeout, uint, S_IRUSR);
+module_param(timeout, uint, 0400);
 MODULE_PARM_DESC(timeout, "timeout for master connection/replies in seconds");
 
 static struct nf_conntrack_expect_policy exp_policy = {
diff --git a/net/netfilter/nf_conntrack_snmp.c b/net/netfilter/nf_conntrack_snmp.c
index 2d0f8e010821..b8e0a22ca1a9 100644
--- a/net/netfilter/nf_conntrack_snmp.c
+++ b/net/netfilter/nf_conntrack_snmp.c
@@ -26,7 +26,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_NFCT_HELPER("snmp");
 
 static unsigned int timeout __read_mostly = 30;
-module_param(timeout, uint, S_IRUSR);
+module_param(timeout, uint, 0400);
 MODULE_PARM_DESC(timeout, "timeout for master connection/replies in seconds");
 
 int (*nf_nat_snmp_hook)(struct sk_buff *skb,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 3cdce391362e..98844c87d01e 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -495,7 +495,7 @@ static int nf_conntrack_standalone_init_proc(struct net *net)
 	if (uid_valid(root_uid) && gid_valid(root_gid))
 		proc_set_user(pde, root_uid, root_gid);
 
-	pde = proc_create("nf_conntrack", S_IRUGO, net->proc_net_stat,
+	pde = proc_create("nf_conntrack", 0444, net->proc_net_stat,
 			  &ct_cpu_seq_fops);
 	if (!pde)
 		goto out_stat_nf_conntrack;
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 1ba3da51050d..a964e4d356cc 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -549,7 +549,7 @@ static int __net_init nf_log_net_init(struct net *net)
 	int ret = -ENOMEM;
 
 #ifdef CONFIG_PROC_FS
-	if (!proc_create("nf_log", S_IRUGO,
+	if (!proc_create("nf_log", 0444,
 			 net->nf.proc_netfilter, &nflog_file_ops))
 		return ret;
 #endif
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 64b875e452ca..8f16fd27132d 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -325,7 +325,7 @@ static const struct file_operations synproxy_cpu_seq_fops = {
 
 static int __net_init synproxy_proc_init(struct net *net)
 {
-	if (!proc_create("synproxy", S_IRUGO, net->proc_net_stat,
+	if (!proc_create("synproxy", 0444, net->proc_net_stat,
 			 &synproxy_cpu_seq_fops))
 		return -ENOMEM;
 	return 0;
diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index 1ac6600bfafd..5ee859193783 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -132,7 +132,7 @@ static int idletimer_tg_create(struct idletimer_tg_info *info)
 		ret = -ENOMEM;
 		goto out_free_timer;
 	}
-	info->timer->attr.attr.mode = S_IRUGO;
+	info->timer->attr.attr.mode = 0444;
 	info->timer->attr.show = idletimer_tg_show;
 
 	ret = sysfs_create_file(idletimer_tg_kobj, &info->timer->attr.attr);
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 486dd24da78b..434e35ce940b 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -51,8 +51,8 @@ static unsigned int ip_list_gid __read_mostly;
 module_param(ip_list_tot, uint, 0400);
 module_param(ip_list_hash_size, uint, 0400);
 module_param(ip_list_perms, uint, 0400);
-module_param(ip_list_uid, uint, S_IRUGO | S_IWUSR);
-module_param(ip_list_gid, uint, S_IRUGO | S_IWUSR);
+module_param(ip_list_uid, uint, 0644);
+module_param(ip_list_gid, uint, 0644);
 MODULE_PARM_DESC(ip_list_tot, "number of IPs to remember per list");
 MODULE_PARM_DESC(ip_list_hash_size, "size of hash table used to look up IPs");
 MODULE_PARM_DESC(ip_list_perms, "permissions on /proc/net/xt_recent/* files");
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 35bb6807927f..4221d98a314b 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1450,9 +1450,9 @@ static int __init nr_proto_init(void)
 
 	nr_loopback_init();
 
-	proc_create("nr", S_IRUGO, init_net.proc_net, &nr_info_fops);
-	proc_create("nr_neigh", S_IRUGO, init_net.proc_net, &nr_neigh_fops);
-	proc_create("nr_nodes", S_IRUGO, init_net.proc_net, &nr_nodes_fops);
+	proc_create("nr", 0444, init_net.proc_net, &nr_info_fops);
+	proc_create("nr_neigh", 0444, init_net.proc_net, &nr_neigh_fops);
+	proc_create("nr_nodes", 0444, init_net.proc_net, &nr_nodes_fops);
 out:
 	return rc;
 fail:
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 5170373b797c..9ff5e0a76593 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1567,12 +1567,12 @@ static int __init rose_proto_init(void)
 
 	rose_add_loopback_neigh();
 
-	proc_create("rose", S_IRUGO, init_net.proc_net, &rose_info_fops);
-	proc_create("rose_neigh", S_IRUGO, init_net.proc_net,
+	proc_create("rose", 0444, init_net.proc_net, &rose_info_fops);
+	proc_create("rose_neigh", 0444, init_net.proc_net,
 		    &rose_neigh_fops);
-	proc_create("rose_nodes", S_IRUGO, init_net.proc_net,
+	proc_create("rose_nodes", 0444, init_net.proc_net,
 		    &rose_nodes_fops);
-	proc_create("rose_routes", S_IRUGO, init_net.proc_net,
+	proc_create("rose_routes", 0444, init_net.proc_net,
 		    &rose_routes_fops);
 out:
 	return rc;
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 0c9c18aa7c77..9e1c2c6b6a67 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -32,7 +32,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETPROTO(PF_RXRPC);
 
 unsigned int rxrpc_debug; // = RXRPC_DEBUG_KPROTO;
-module_param_named(debug, rxrpc_debug, uint, S_IWUSR | S_IRUGO);
+module_param_named(debug, rxrpc_debug, uint, 0644);
 MODULE_PARM_DESC(debug, "RxRPC debugging mask");
 
 static struct proto rxrpc_proto;
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 17d0155d9de3..1d9ccc6dab2b 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -450,17 +450,17 @@ int __net_init sctp_proc_init(struct net *net)
 	net->sctp.proc_net_sctp = proc_net_mkdir(net, "sctp", net->proc_net);
 	if (!net->sctp.proc_net_sctp)
 		return -ENOMEM;
-	if (!proc_create("snmp", S_IRUGO, net->sctp.proc_net_sctp,
-			&sctp_snmp_seq_fops))
+	if (!proc_create("snmp", 0444, net->sctp.proc_net_sctp,
+			 &sctp_snmp_seq_fops))
 		goto cleanup;
-	if (!proc_create("eps", S_IRUGO, net->sctp.proc_net_sctp,
-			&sctp_eps_seq_fops))
+	if (!proc_create("eps", 0444, net->sctp.proc_net_sctp,
+			 &sctp_eps_seq_fops))
 		goto cleanup;
-	if (!proc_create("assocs", S_IRUGO, net->sctp.proc_net_sctp,
-			&sctp_assocs_seq_fops))
+	if (!proc_create("assocs", 0444, net->sctp.proc_net_sctp,
+			 &sctp_assocs_seq_fops))
 		goto cleanup;
-	if (!proc_create("remaddr", S_IRUGO, net->sctp.proc_net_sctp,
-			&sctp_remaddr_seq_fops))
+	if (!proc_create("remaddr", 0444, net->sctp.proc_net_sctp,
+			 &sctp_remaddr_seq_fops))
 		goto cleanup;
 	return 0;
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 26531193fce4..5089dbb96d58 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1375,7 +1375,7 @@ static int create_use_gss_proxy_proc_entry(struct net *net)
 	struct proc_dir_entry **p = &sn->use_gssp_proc;
 
 	sn->use_gss_proxy = -1;
-	*p = proc_create_data("use-gss-proxy", S_IFREG|S_IRUSR|S_IWUSR,
+	*p = proc_create_data("use-gss-proxy", S_IFREG | 0600,
 			      sn->proc_net_rpc,
 			      &use_gss_proxy_ops, net);
 	if (!*p)
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 26582e27be6a..cdda4744c9b1 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1621,20 +1621,20 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 	if (cd->procfs == NULL)
 		goto out_nomem;
 
-	p = proc_create_data("flush", S_IFREG|S_IRUSR|S_IWUSR,
+	p = proc_create_data("flush", S_IFREG | 0600,
 			     cd->procfs, &cache_flush_operations_procfs, cd);
 	if (p == NULL)
 		goto out_nomem;
 
 	if (cd->cache_request || cd->cache_parse) {
-		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
-				cd->procfs, &cache_file_operations_procfs, cd);
+		p = proc_create_data("channel", S_IFREG | 0600, cd->procfs,
+				     &cache_file_operations_procfs, cd);
 		if (p == NULL)
 			goto out_nomem;
 	}
 	if (cd->cache_show) {
-		p = proc_create_data("content", S_IFREG|S_IRUSR,
-				cd->procfs, &content_file_operations_procfs, cd);
+		p = proc_create_data("content", S_IFREG | 0400, cd->procfs,
+				     &content_file_operations_procfs, cd);
 		if (p == NULL)
 			goto out_nomem;
 	}
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index e980d2a493de..45a033329cd4 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -139,7 +139,7 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 		return;
 
 	/* make tasks file */
-	if (!debugfs_create_file("tasks", S_IFREG | S_IRUSR, clnt->cl_debugfs,
+	if (!debugfs_create_file("tasks", S_IFREG | 0400, clnt->cl_debugfs,
 				 clnt, &tasks_fops))
 		goto out_err;
 
@@ -241,7 +241,7 @@ rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 		return;
 
 	/* make tasks file */
-	if (!debugfs_create_file("info", S_IFREG | S_IRUSR, xprt->debugfs,
+	if (!debugfs_create_file("info", S_IFREG | 0400, xprt->debugfs,
 				 xprt, &xprt_info_fops)) {
 		debugfs_remove_recursive(xprt->debugfs);
 		xprt->debugfs = NULL;
@@ -317,7 +317,7 @@ inject_fault_dir(struct dentry *topdir)
 	if (!faultdir)
 		return NULL;
 
-	if (!debugfs_create_file("disconnect", S_IFREG | S_IRUSR, faultdir,
+	if (!debugfs_create_file("disconnect", S_IFREG | 0400, faultdir,
 				 NULL, &fault_disconnect_fops))
 		return NULL;
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index fc97fc3ed637..0f08934b2cea 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -820,13 +820,13 @@ struct dentry *rpc_mkpipe_dentry(struct dentry *parent, const char *name,
 {
 	struct dentry *dentry;
 	struct inode *dir = d_inode(parent);
-	umode_t umode = S_IFIFO | S_IRUSR | S_IWUSR;
+	umode_t umode = S_IFIFO | 0600;
 	int err;
 
 	if (pipe->ops->upcall == NULL)
-		umode &= ~S_IRUGO;
+		umode &= ~0444;
 	if (pipe->ops->downcall == NULL)
-		umode &= ~S_IWUGO;
+		umode &= ~0222;
 
 	inode_lock_nested(dir, I_MUTEX_PARENT);
 	dentry = __rpc_lookup_create_exclusive(parent, name);
@@ -1035,7 +1035,7 @@ static const struct rpc_filelist authfiles[] = {
 	[RPCAUTH_info] = {
 		.name = "info",
 		.i_fop = &rpc_info_operations,
-		.mode = S_IFREG | S_IRUSR,
+		.mode = S_IFREG | 0400,
 	},
 };
 
@@ -1068,8 +1068,8 @@ struct dentry *rpc_create_client_dir(struct dentry *dentry,
 {
 	struct dentry *ret;
 
-	ret = rpc_mkdir_populate(dentry, name, S_IRUGO | S_IXUGO, NULL,
-			rpc_clntdir_populate, rpc_client);
+	ret = rpc_mkdir_populate(dentry, name, 0555, NULL,
+				 rpc_clntdir_populate, rpc_client);
 	if (!IS_ERR(ret)) {
 		rpc_client->cl_pipedir_objects.pdh_dentry = ret;
 		rpc_create_pipe_dir_objects(&rpc_client->cl_pipedir_objects);
@@ -1096,17 +1096,17 @@ static const struct rpc_filelist cache_pipefs_files[3] = {
 	[0] = {
 		.name = "channel",
 		.i_fop = &cache_file_operations_pipefs,
-		.mode = S_IFREG|S_IRUSR|S_IWUSR,
+		.mode = S_IFREG | 0600,
 	},
 	[1] = {
 		.name = "content",
 		.i_fop = &content_file_operations_pipefs,
-		.mode = S_IFREG|S_IRUSR,
+		.mode = S_IFREG | 0400,
 	},
 	[2] = {
 		.name = "flush",
 		.i_fop = &cache_flush_operations_pipefs,
-		.mode = S_IFREG|S_IRUSR|S_IWUSR,
+		.mode = S_IFREG | 0600,
 	},
 };
 
@@ -1164,39 +1164,39 @@ enum {
 static const struct rpc_filelist files[] = {
 	[RPCAUTH_lockd] = {
 		.name = "lockd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_mount] = {
 		.name = "mount",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_nfs] = {
 		.name = "nfs",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_portmap] = {
 		.name = "portmap",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_statd] = {
 		.name = "statd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_nfsd4_cb] = {
 		.name = "nfsd4_cb",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_cache] = {
 		.name = "cache",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_nfsd] = {
 		.name = "nfsd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 	[RPCAUTH_gssd] = {
 		.name = "gssd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 };
 
@@ -1261,7 +1261,7 @@ EXPORT_SYMBOL_GPL(rpc_put_sb_net);
 static const struct rpc_filelist gssd_dummy_clnt_dir[] = {
 	[0] = {
 		.name = "clntXX",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+		.mode = S_IFDIR | 0555,
 	},
 };
 
@@ -1310,7 +1310,7 @@ static const struct rpc_filelist gssd_dummy_info_file[] = {
 	[0] = {
 		.name = "info",
 		.i_fop = &rpc_dummy_info_operations,
-		.mode = S_IFREG | S_IRUSR,
+		.mode = S_IFREG | 0400,
 	},
 };
 
@@ -1397,7 +1397,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_d_op = &simple_dentry_operations;
 	sb->s_time_gran = 1;
 
-	inode = rpc_get_inode(sb, S_IFDIR | S_IRUGO | S_IXUGO);
+	inode = rpc_get_inode(sb, S_IFDIR | 0555);
 	sb->s_root = root = d_make_root(inode);
 	if (!root)
 		return -ENOMEM;
diff --git a/net/wireless/wext-proc.c b/net/wireless/wext-proc.c
index 5511f989ef47..b4c464594a5e 100644
--- a/net/wireless/wext-proc.c
+++ b/net/wireless/wext-proc.c
@@ -142,7 +142,7 @@ static const struct file_operations wireless_seq_fops = {
 int __net_init wext_proc_init(struct net *net)
 {
 	/* Create /proc/net/wireless entry */
-	if (!proc_create("wireless", S_IRUGO, net->proc_net,
+	if (!proc_create("wireless", 0444, net->proc_net,
 			 &wireless_seq_fops))
 		return -ENOMEM;
 
diff --git a/net/x25/x25_proc.c b/net/x25/x25_proc.c
index 0917f047f2cf..64b415e93f6a 100644
--- a/net/x25/x25_proc.c
+++ b/net/x25/x25_proc.c
@@ -212,16 +212,16 @@ int __init x25_proc_init(void)
 	if (!proc_mkdir("x25", init_net.proc_net))
 		return -ENOMEM;
 
-	if (!proc_create("x25/route", S_IRUGO, init_net.proc_net,
-			&x25_seq_route_fops))
+	if (!proc_create("x25/route", 0444, init_net.proc_net,
+			 &x25_seq_route_fops))
 		goto out;
 
-	if (!proc_create("x25/socket", S_IRUGO, init_net.proc_net,
-			&x25_seq_socket_fops))
+	if (!proc_create("x25/socket", 0444, init_net.proc_net,
+			 &x25_seq_socket_fops))
 		goto out;
 
-	if (!proc_create("x25/forward", S_IRUGO, init_net.proc_net,
-			&x25_seq_forward_fops))
+	if (!proc_create("x25/forward", 0444, init_net.proc_net,
+			 &x25_seq_forward_fops))
 		goto out;
 	return 0;
 
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 6d5f85f4e672..ed06903cd84d 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -79,7 +79,7 @@ static const struct file_operations xfrm_statistics_seq_fops = {
 
 int __net_init xfrm_proc_init(struct net *net)
 {
-	if (!proc_create("xfrm_stat", S_IRUGO, net->proc_net,
+	if (!proc_create("xfrm_stat", 0444, net->proc_net,
 			 &xfrm_statistics_seq_fops))
 		return -ENOMEM;
 	return 0;
-- 
2.15.0

