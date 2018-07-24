Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f65.google.com ([209.85.160.65]:41062 "EHLO
        mail-pl0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388938AbeGXUht (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:49 -0400
Received: by mail-pl0-f65.google.com with SMTP id w8-v6so2191995ply.8
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:52 -0700 (PDT)
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
        Stephen Hemminger <sthemmin@microsoft.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH PATCH net-next 14/18] decnet: whitespace fixes
Date: Tue, 24 Jul 2018 12:29:14 -0700
Message-Id: <20180724192918.31165-15-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove trailing whitespace and extra lines at EOF

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/decnet/Kconfig              | 1 -
 net/decnet/Makefile             | 1 -
 net/decnet/TODO                 | 5 ++---
 net/decnet/dn_fib.c             | 2 --
 net/decnet/dn_nsp_in.c          | 1 -
 net/decnet/dn_nsp_out.c         | 1 -
 net/decnet/dn_route.c           | 1 -
 net/decnet/dn_rules.c           | 2 --
 net/decnet/netfilter/Makefile   | 1 -
 net/decnet/netfilter/dn_rtmsg.c | 1 -
 10 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/net/decnet/Kconfig b/net/decnet/Kconfig
index f3393e154f0f..dcc74956badd 100644
--- a/net/decnet/Kconfig
+++ b/net/decnet/Kconfig
@@ -40,4 +40,3 @@ config DECNET_ROUTER
 	  to work.
 
 	  See <file:Documentation/networking/decnet.txt> for more information.
-
diff --git a/net/decnet/Makefile b/net/decnet/Makefile
index 9e38122d942b..07b38e441b2d 100644
--- a/net/decnet/Makefile
+++ b/net/decnet/Makefile
@@ -8,4 +8,3 @@ decnet-$(CONFIG_DECNET_ROUTER) += dn_fib.o dn_rules.o dn_table.o
 decnet-y += sysctl_net_decnet.o
 
 obj-$(CONFIG_NETFILTER) += netfilter/
-
diff --git a/net/decnet/TODO b/net/decnet/TODO
index ebb5ac69d128..358e9eb49016 100644
--- a/net/decnet/TODO
+++ b/net/decnet/TODO
@@ -16,14 +16,14 @@ Steve's quick list of things that need finishing off:
 
  o Verify errors etc. against POSIX 1003.1g (draft)
 
- o Using send/recvmsg() to get at connect/disconnect data (POSIX 1003.1g) 
+ o Using send/recvmsg() to get at connect/disconnect data (POSIX 1003.1g)
    [maybe this should be done at socket level... the control data in the
     send/recvmsg() calls should simply be a vector of set/getsockopt()
     calls]
 
  o check MSG_CTRUNC is set where it should be.
 
- o Find all the commonality between DECnet and IPv4 routing code and extract 
+ o Find all the commonality between DECnet and IPv4 routing code and extract
    it into a small library of routines. [probably a project for 2.7.xx]
 
  o Add perfect socket hashing - an idea suggested by Paul Koning. Currently
@@ -38,4 +38,3 @@ Steve's quick list of things that need finishing off:
  o DECnet sendpages() function
 
  o AIO for DECnet
-
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index fce94cbd4378..f78fe58eafc8 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -797,5 +797,3 @@ void __init dn_fib_init(void)
 	rtnl_register_module(THIS_MODULE, PF_DECnet, RTM_DELROUTE,
 			     dn_fib_rtm_delroute, NULL, 0);
 }
-
-
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 34aba55ed573..2fb5e055ba25 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -912,4 +912,3 @@ int dn_nsp_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 
 	return NET_RX_SUCCESS;
 }
-
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 56a52a004c56..a1779de6bd9c 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -701,4 +701,3 @@ void dn_nsp_send_conninit(struct sock *sk, unsigned char msgflg)
 
 	dn_nsp_send(skb);
 }
-
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index e74765024d88..3107a2e24e6b 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1925,4 +1925,3 @@ void __exit dn_route_cleanup(void)
 	remove_proc_entry("decnet_cache", init_net.proc_net);
 	dst_entries_destroy(&dn_dst_ops);
 }
-
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 72236695db3d..4a4e3c17740c 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -256,5 +256,3 @@ void __exit dn_fib_rules_cleanup(void)
 	rtnl_unlock();
 	rcu_barrier();
 }
-
-
diff --git a/net/decnet/netfilter/Makefile b/net/decnet/netfilter/Makefile
index 255c1ae9daeb..b579e52130aa 100644
--- a/net/decnet/netfilter/Makefile
+++ b/net/decnet/netfilter/Makefile
@@ -3,4 +3,3 @@
 #
 
 obj-$(CONFIG_DECNET_NF_GRABULATOR) += dn_rtmsg.o
-
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index ab395e55cd78..a4faacadd8a8 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -158,4 +158,3 @@ MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_DNRTMSG);
 
 module_init(dn_rtmsg_init);
 module_exit(dn_rtmsg_fini);
-
-- 
2.18.0

