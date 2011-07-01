From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/12] net switch/case reformatting
Date: Fri,  1 Jul 2011 12:43:01 -0700
Message-ID: <cover.1309549243.git.joe__6441.93685516274$1309549422$gmane$org@perches.com>
Cc: linux-kernel@vger.kernel.org
To: linux-decnet-user@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-x25@vger.kernel.org, linux-h
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3427 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab1GATnc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 15:43:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just whitespace cleanups with a couple trivial corrections

Joe Perches (12):
  appletalk: Reduce switch/case indent
  decnet: Reduce switch/case indent
  econet: Reduce switch/case indent
  ipconfig: Reduce switch/case indent
  netfilter: Reduce switch/case indent
  ipv4: Reduce switch/case indent
  ipv6: Reduce switch/case indent
  lapb: Reduce switch/case indent
  netrom:  Reduce switch/case indent
  sctp: Reduce switch/case indent
  sunrpc: Reduce switch/case indent
  x25: Reduce switch/case indent

 net/appletalk/aarp.c                   |  138 +++---
 net/appletalk/ddp.c                    |  398 +++++++-------
 net/decnet/af_decnet.c                 |  697 +++++++++++++-------------
 net/decnet/dn_dev.c                    |   70 ++--
 net/decnet/dn_fib.c                    |   77 ++--
 net/decnet/dn_neigh.c                  |   14 +-
 net/decnet/dn_nsp_in.c                 |  182 ++++----
 net/decnet/dn_route.c                  |  102 ++--
 net/decnet/dn_table.c                  |   23 +-
 net/decnet/netfilter/dn_rtmsg.c        |   18 +-
 net/decnet/sysctl_net_decnet.c         |   17 +-
 net/econet/af_econet.c                 |   23 +-
 net/ipv4/ipconfig.c                    |   73 ++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c     |   26 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c |  210 ++++----
 net/ipv4/raw.c                         |   36 +-
 net/ipv4/route.c                       |   28 +-
 net/ipv6/raw.c                         |  145 +++---
 net/lapb/lapb_iface.c                  |   30 +-
 net/lapb/lapb_in.c                     |  881 ++++++++++++++++----------------
 net/netfilter/xt_HL.c                  |   64 ++--
 net/netfilter/xt_hl.c                  |   32 +-
 net/netrom/nr_route.c                  |   22 +-
 net/sctp/sm_statefuns.c                |   51 +-
 net/sctp/socket.c                      |   10 +-
 net/sunrpc/auth_gss/auth_gss.c         |   46 +-
 net/sunrpc/clnt.c                      |   25 +-
 net/sunrpc/rpc_pipe.c                  |   14 +-
 net/x25/af_x25.c                       |  473 +++++++++---------
 net/x25/x25_dev.c                      |   44 +-
 net/x25/x25_in.c                       |  118 +++---
 net/x25/x25_link.c                     |   87 ++--
 net/x25/x25_subr.c                     |   78 ++--
 33 files changed, 2111 insertions(+), 2141 deletions(-)

-- 
1.7.6.rc1

