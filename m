Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f67.google.com ([209.85.160.67]:36380 "EHLO
        mail-pl0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388476AbeGXUhZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:25 -0400
Received: by mail-pl0-f67.google.com with SMTP id e11-v6so2198827plb.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:29 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 01/18] sched: fix trailing whitespace
Date: Tue, 24 Jul 2018 12:29:01 -0700
Message-Id: <20180724192918.31165-2-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove trailing whitespace and blank lines at EOF

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/Kconfig        | 4 ++--
 net/sched/Makefile       | 2 +-
 net/sched/act_connmark.c | 1 -
 net/sched/act_pedit.c    | 1 -
 net/sched/cls_basic.c    | 1 -
 5 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 7af246764a35..bba71225adbd 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -1,6 +1,6 @@
 #
 # Traffic control configuration.
-# 
+#
 
 menuconfig NET_SCHED
 	bool "QoS and/or fair queueing"
@@ -706,7 +706,7 @@ config NET_CLS_ACT
 
 config NET_ACT_POLICE
 	tristate "Traffic Policing"
-        depends on NET_CLS_ACT 
+        depends on NET_CLS_ACT
         ---help---
 	  Say Y here if you want to do traffic policing, i.e. strict
 	  bandwidth limiting. This action replaces the existing policing
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 673ee7d26ff2..910ec7463a36 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -33,7 +33,7 @@ obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
 obj-$(CONFIG_NET_SCH_HFSC)	+= sch_hfsc.o
 obj-$(CONFIG_NET_SCH_RED)	+= sch_red.o
 obj-$(CONFIG_NET_SCH_GRED)	+= sch_gred.o
-obj-$(CONFIG_NET_SCH_INGRESS)	+= sch_ingress.o 
+obj-$(CONFIG_NET_SCH_INGRESS)	+= sch_ingress.o
 obj-$(CONFIG_NET_SCH_DSMARK)	+= sch_dsmark.o
 obj-$(CONFIG_NET_SCH_SFB)	+= sch_sfb.o
 obj-$(CONFIG_NET_SCH_SFQ)	+= sch_sfq.o
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 1e31f0e448e2..2f9bc833d046 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -252,4 +252,3 @@ module_exit(connmark_cleanup_module);
 MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
 MODULE_DESCRIPTION("Connection tracking mark restoring");
 MODULE_LICENSE("GPL");
-
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index cc8ffcd1ddb5..9ab5d81aff1a 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -516,4 +516,3 @@ static void __exit pedit_cleanup_module(void)
 
 module_init(pedit_init_module);
 module_exit(pedit_cleanup_module);
-
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 95367f37098d..6a5dce8baf19 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -324,4 +324,3 @@ static void __exit exit_basic(void)
 module_init(init_basic)
 module_exit(exit_basic)
 MODULE_LICENSE("GPL");
-
-- 
2.18.0

