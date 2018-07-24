Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f196.google.com ([209.85.215.196]:42113 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388566AbeGXUhX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:23 -0400
Received: by mail-pg1-f196.google.com with SMTP id y4-v6so3567179pgp.9
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:26 -0700 (PDT)
From: Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net, ericvh@gmail.com, rminnich@sandia.gov,
        lucho@ionkov.net, ralf@linux-mips.org, jreuter@yaina.de,
        pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        alex.aring@gmail.com, stefan@datenfreihafen.org,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        johannes@sipsolutions.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, vyasevich@gmail.com,
        nhorman@tuxdriver.com, marcelo.leitner@gmail.com,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au
Cc: netdev@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-hams@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
Subject: [PATCH PATCH net-next 00/18] net whitespace cleanups
Date: Tue, 24 Jul 2018 12:29:00 -0700
Message-Id: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ran script that I use to check for trailing whitespace and
blank lines at end of files across all files in net/ directory.
These are errors that checkpatch reports and git flags.

These are the resulting fixes broken up mostly by subsystem.

Stephen Hemminger (18):
  sched: fix trailing whitespace
  wimax: remove blank lines at EOF
  rds: remove trailing whitespace and blank lines
  llc: fix whitespace issues
  mpls: remove trailing whitepace
  xfrm: remove blank lines at EOF
  ceph: fix whitespace
  sctp: whitespace fixes
  ila: remove blank lines at EOF
  9p: fix whitespace issues
  atm: remove blank lines at EOF
  ax25: remove blank line at EOF
  x25: remove blank lines at EOF
  decnet: whitespace fixes
  sunrpc: whitespace fixes
  bpfilter: remove trailing newline
  l2tp: remove trailing newline
  net: remove blank lines at end of file

 net/8021q/Makefile                      | 1 -
 net/9p/client.c                         | 4 ++--
 net/9p/trans_virtio.c                   | 2 +-
 net/9p/util.c                           | 1 -
 net/Kconfig                             | 2 +-
 net/atm/mpoa_proc.c                     | 6 ------
 net/ax25/ax25_addr.c                    | 1 -
 net/ax25/ax25_ds_in.c                   | 1 -
 net/ax25/ax25_ds_subr.c                 | 1 -
 net/ax25/ax25_ip.c                      | 1 -
 net/ax25/ax25_out.c                     | 1 -
 net/bpfilter/Kconfig                    | 1 -
 net/ceph/Kconfig                        | 1 -
 net/ceph/Makefile                       | 1 -
 net/ceph/auth_none.c                    | 1 -
 net/ceph/auth_none.h                    | 1 -
 net/ceph/auth_x.c                       | 2 --
 net/ceph/auth_x.h                       | 1 -
 net/ceph/mon_client.c                   | 2 +-
 net/ceph/pagevec.c                      | 1 -
 net/core/neighbour.c                    | 1 -
 net/decnet/Kconfig                      | 1 -
 net/decnet/Makefile                     | 1 -
 net/decnet/TODO                         | 5 ++---
 net/decnet/dn_fib.c                     | 2 --
 net/decnet/dn_nsp_in.c                  | 1 -
 net/decnet/dn_nsp_out.c                 | 1 -
 net/decnet/dn_route.c                   | 1 -
 net/decnet/dn_rules.c                   | 2 --
 net/decnet/netfilter/Makefile           | 1 -
 net/decnet/netfilter/dn_rtmsg.c         | 1 -
 net/dns_resolver/dns_key.c              | 1 -
 net/ieee802154/core.c                   | 1 -
 net/ieee802154/nl_policy.c              | 1 -
 net/ipv4/Kconfig                        | 4 ++--
 net/ipv4/Makefile                       | 2 +-
 net/ipv4/bpfilter/Makefile              | 1 -
 net/ipv6/Kconfig                        | 2 +-
 net/ipv6/ila/ila_common.c               | 1 -
 net/ipv6/ila/ila_xlat.c                 | 1 -
 net/iucv/af_iucv.c                      | 1 -
 net/kcm/Kconfig                         | 1 -
 net/kcm/kcmsock.c                       | 1 -
 net/l2tp/l2tp_core.c                    | 1 -
 net/llc/Kconfig                         | 2 +-
 net/llc/Makefile                        | 2 +-
 net/llc/llc_if.c                        | 1 -
 net/mac80211/rc80211_minstrel.c         | 1 -
 net/mpls/mpls_iptunnel.c                | 2 +-
 net/rds/Kconfig                         | 1 -
 net/rds/Makefile                        | 1 -
 net/rds/ib.c                            | 1 -
 net/rds/message.c                       | 1 -
 net/rds/rdma_transport.c                | 1 -
 net/rds/tcp.c                           | 1 -
 net/rds/transport.c                     | 1 -
 net/sched/Kconfig                       | 4 ++--
 net/sched/Makefile                      | 2 +-
 net/sched/act_connmark.c                | 1 -
 net/sched/act_pedit.c                   | 1 -
 net/sched/cls_basic.c                   | 1 -
 net/sctp/Kconfig                        | 4 ++--
 net/sctp/sm_sideeffect.c                | 1 -
 net/sunrpc/auth_gss/auth_gss.c          | 2 +-
 net/sunrpc/auth_gss/gss_generic_token.c | 1 -
 net/sunrpc/auth_gss/gss_krb5_crypto.c   | 1 -
 net/sunrpc/auth_gss/gss_krb5_keys.c     | 1 -
 net/sunrpc/auth_gss/gss_krb5_seal.c     | 1 -
 net/sunrpc/auth_gss/gss_krb5_unseal.c   | 1 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c     | 1 -
 net/sunrpc/auth_gss/svcauth_gss.c       | 2 +-
 net/sunrpc/backchannel_rqst.c           | 1 -
 net/sunrpc/clnt.c                       | 2 +-
 net/sunrpc/rpcb_clnt.c                  | 2 +-
 net/sunrpc/stats.c                      | 1 -
 net/sunrpc/sunrpc.h                     | 1 -
 net/sunrpc/xprt.c                       | 2 +-
 net/sunrpc/xprtsock.c                   | 1 -
 net/wimax/Makefile                      | 2 --
 net/wimax/debugfs.c                     | 2 --
 net/wimax/op-msg.c                      | 1 -
 net/wimax/stack.c                       | 1 -
 net/x25/Kconfig                         | 2 --
 net/x25/x25_subr.c                      | 1 -
 net/xfrm/Kconfig                        | 1 -
 net/xfrm/xfrm_user.c                    | 1 -
 86 files changed, 24 insertions(+), 103 deletions(-)

-- 
2.18.0

