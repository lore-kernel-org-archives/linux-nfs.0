Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35307 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754724Ab1H2VSX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 17:18:23 -0400
From: Joe Perches <joe@perches.com>
To: linux-hams@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-decnet-user@lists.sourceforge.net,
        linux-s390@vger.kernel.org, linux-wireless@vger.kernel.org,
        lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
Subject: [PATCH 00/24] net: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:19 -0700
Message-Id: <cover.1314650069.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove all the site-specific OOM messages because they duplicate
the MM subsystem generic OOM message.

Saves ~.2% (~2.5kb) of code/text in an x86 defconfig

$ size net/built-in.o*defconfig
   text	   data	    bss	    dec	    hex	filename
1506772	  58652	  34928	1600352	 186b60	net/built-in.o.new.defconfig
1509144	  58652	  34928	1602724	 1874a4	net/built-in.o.old.defconfig

$ size net/built-in.o*allyesconfig
   text	   data	    bss	    dec	    hex	filename
7655361	 275361	2062352	 9993074 987b72	net/built-in.o.new.allyesconfig
7667400	 275649	2064024	10007073 98b221	net/built-in.o.old.allyesconfig

Joe Perches (24):
  802: Remove unnecessary OOM logging messages
  9p: Remove unnecessary OOM logging messages
  atm: Remove unnecessary OOM logging messages
  ax25: Remove unnecessary OOM logging messages
  batman-adv: Remove unnecessary OOM logging messages
  netfilter: Remove unnecessary OOM logging messages
  net: Remove unnecessary OOM logging messages
  ceph: Remove unnecessary OOM logging messages
  decnet: Remove unnecessary OOM logging messages
  econet: Remove unnecessary OOM logging messages
  iucv: Remove unnecessary OOM logging messages
  mac80211: Remove unnecessary OOM logging messages
  netrom: Remove unnecessary OOM logging messages
  rds: Remove unnecessary OOM logging messages
  rfkill: Remove unnecessary OOM logging messages
  rose: Remove unnecessary OOM logging messages
  sched: Remove unnecessary OOM logging messages
  sctp: Remove unnecessary OOM logging messages
  sunrpc: Remove unnecessary OOM logging messages
  tipc: Remove unnecessary OOM logging messages
  wanrouter: Remove unnecessary OOM logging messages
  wireless: Remove unnecessary OOM logging messages
  x25: Remove unnecessary OOM logging messages
  net: Remove unnecessary OOM logging messages

 net/802/tr.c                            |    1 -
 net/9p/client.c                         |    7 +----
 net/9p/trans_virtio.c                   |    6 +----
 net/atm/lec.c                           |    4 +--
 net/atm/mpc.c                           |   17 ++++----------
 net/atm/mpoa_caches.c                   |    8 +-----
 net/ax25/ax25_dev.c                     |    5 +--
 net/ax25/ax25_out.c                     |    8 +++---
 net/ax25/ax25_route.c                   |    5 +--
 net/batman-adv/hard-interface.c         |    5 +---
 net/batman-adv/main.c                   |    2 -
 net/batman-adv/originator.c             |   16 +++----------
 net/batman-adv/soft-interface.c         |    4 +--
 net/batman-adv/vis.c                    |    4 +--
 net/bridge/netfilter/ebt_ulog.c         |    7 ++---
 net/can/af_can.c                        |    6 +---
 net/ceph/messenger.c                    |    5 +---
 net/ceph/msgpool.c                      |    6 +----
 net/core/dev.c                          |   25 ++++++----------------
 net/core/flow.c                         |    4 +--
 net/core/pktgen.c                       |    5 +---
 net/decnet/dn_neigh.c                   |    6 -----
 net/econet/af_econet.c                  |    4 +--
 net/ipv4/netfilter/ipt_CLUSTERIP.c      |    1 -
 net/ipv4/netfilter/ipt_ULOG.c           |    4 +--
 net/ipv4/netfilter/nf_nat_snmp_basic.c  |   22 +-----------------
 net/ipv6/netfilter/nf_conntrack_reasm.c |    7 ++---
 net/iucv/iucv.c                         |    5 +--
 net/mac80211/agg-rx.c                   |   19 +---------------
 net/mac80211/agg-tx.c                   |   35 +++++++-----------------------
 net/mac80211/debugfs.c                  |    3 ++
 net/mac80211/ht.c                       |    6 +----
 net/mac80211/mesh.c                     |    5 +--
 net/mac80211/mlme.c                     |   17 ++++----------
 net/mac80211/spectmgmt.c                |    6 +----
 net/mac80211/tx.c                       |   17 ++++----------
 net/mac80211/util.c                     |   11 ++-------
 net/mac80211/work.c                     |    6 +---
 net/netfilter/ipset/ip_set_core.c       |    4 +--
 net/netfilter/ipvs/ip_vs_core.c         |    5 +--
 net/netfilter/ipvs/ip_vs_ctl.c          |   18 +++++----------
 net/netfilter/ipvs/ip_vs_dh.c           |    5 +--
 net/netfilter/ipvs/ip_vs_lblc.c         |    9 ++-----
 net/netfilter/ipvs/ip_vs_lblcr.c        |   13 +++--------
 net/netfilter/ipvs/ip_vs_proto.c        |    5 +--
 net/netfilter/ipvs/ip_vs_sh.c           |    5 +--
 net/netfilter/ipvs/ip_vs_wrr.c          |    5 +--
 net/netfilter/nf_conntrack_core.c       |    5 +---
 net/netfilter/nfnetlink_log.c           |    7 +----
 net/netfilter/xt_IDLETIMER.c            |    2 -
 net/netfilter/xt_hashlimit.c            |    5 +---
 net/netrom/af_netrom.c                  |    8 +-----
 net/rds/ib_rdma.c                       |    1 -
 net/rds/iw_rdma.c                       |    8 +------
 net/rds/iw_send.c                       |    8 +-----
 net/rfkill/rfkill-regulator.c           |    1 -
 net/rose/af_rose.c                      |    1 -
 net/sched/act_api.c                     |    6 +---
 net/sched/sch_atm.c                     |    1 -
 net/sctp/protocol.c                     |    3 --
 net/socket.c                            |    5 +---
 net/sunrpc/auth_gss/gss_krb5_crypto.c   |   10 +-------
 net/sunrpc/auth_gss/gss_krb5_mech.c     |    2 -
 net/sunrpc/backchannel_rqst.c           |    9 ++-----
 net/sunrpc/clnt.c                       |    3 --
 net/sunrpc/rpc_pipe.c                   |    3 +-
 net/sunrpc/rpcb_clnt.c                  |    2 -
 net/sunrpc/xprtrdma/svc_rdma.c          |    8 +-----
 net/sunrpc/xprtrdma/transport.c         |    5 +---
 net/sunrpc/xprtrdma/verbs.c             |   14 ------------
 net/sunrpc/xprtsock.c                   |    5 +---
 net/tipc/link.c                         |    4 +--
 net/wanrouter/wanmain.c                 |    8 +------
 net/wireless/lib80211_crypt_ccmp.c      |    2 -
 net/wireless/lib80211_crypt_tkip.c      |    4 ---
 net/wireless/lib80211_crypt_wep.c       |    4 ---
 net/wireless/util.c                     |    5 +--
 net/x25/x25_dev.c                       |   10 +++-----
 78 files changed, 137 insertions(+), 415 deletions(-)

-- 
1.7.6.405.gc1be0

