Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:55589 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754170Ab2ENH5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 03:57:08 -0400
From: Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org, linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, linux-wireless@vger.kernel.org,
        dev@openvswitch.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Subject: [RFC net-next 0/2] net: Use net_<level>_ratelimit
Date: Mon, 14 May 2012 00:56:24 -0700
Message-Id: <cover.1336981915.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

net_ratelimit() like __ratelimit() is too easy to misuse.

Add simplifying macros similar to pr_<level>_ratelimited
that combines the test of net_ratelimit and logging.

Joe Perches (2):
  net: Add net_ratelimited_function and net_<level>_ratelimited macros
  net: Convert net_ratelimit uses to net_<level>_ratelimited

 include/linux/net.h                            |   23 +++++++++++
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
 77 files changed, 329 insertions(+), 490 deletions(-)

-- 
1.7.8.111.gad25c.dirty

