Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f65.google.com ([209.85.160.65]:36382 "EHLO
        mail-pl0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388771AbeGXUh2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:28 -0400
Received: by mail-pl0-f65.google.com with SMTP id e11-v6so2198881plb.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:32 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 03/18] rds: remove trailing whitespace and blank lines
Date: Tue, 24 Jul 2018 12:29:03 -0700
Message-Id: <20180724192918.31165-4-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/rds/Kconfig          | 1 -
 net/rds/Makefile         | 1 -
 net/rds/ib.c             | 1 -
 net/rds/message.c        | 1 -
 net/rds/rdma_transport.c | 1 -
 net/rds/tcp.c            | 1 -
 net/rds/transport.c      | 1 -
 7 files changed, 7 deletions(-)

diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index bffde4b46c5d..41f75563b54b 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -24,4 +24,3 @@ config RDS_DEBUG
         bool "RDS debugging messages"
 	depends on RDS
         default n
-
diff --git a/net/rds/Makefile b/net/rds/Makefile
index b5d568bd479c..e647f9de104a 100644
--- a/net/rds/Makefile
+++ b/net/rds/Makefile
@@ -15,4 +15,3 @@ rds_tcp-y :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
 			tcp_send.o tcp_stats.o
 
 ccflags-$(CONFIG_RDS_DEBUG)	:=	-DRDS_DEBUG
-
diff --git a/net/rds/ib.c b/net/rds/ib.c
index 63d95ea7cdff..a4245c42d43b 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -568,4 +568,3 @@ int rds_ib_init(void)
 }
 
 MODULE_LICENSE("GPL");
-
diff --git a/net/rds/message.c b/net/rds/message.c
index a35f76971984..4b00b1152a5f 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -514,4 +514,3 @@ void rds_message_unmapped(struct rds_message *rm)
 	wake_up_interruptible(&rm->m_flush_wait);
 }
 EXPORT_SYMBOL_GPL(rds_message_unmapped);
-
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index bd67e55354f4..ad78929036ef 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -281,4 +281,3 @@ module_exit(rds_rdma_exit);
 MODULE_AUTHOR("Oracle Corporation <rds-devel@oss.oracle.com>");
 MODULE_DESCRIPTION("RDS: IB transport");
 MODULE_LICENSE("Dual BSD/GPL");
-
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 7028d6e51947..f23925af0b8d 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -717,4 +717,3 @@ module_init(rds_tcp_init);
 MODULE_AUTHOR("Oracle Corporation <rds-devel@oss.oracle.com>");
 MODULE_DESCRIPTION("RDS: TCP transport");
 MODULE_LICENSE("Dual BSD/GPL");
-
diff --git a/net/rds/transport.c b/net/rds/transport.c
index c9788dbce441..46f709a4b577 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -159,4 +159,3 @@ unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
 
 	return total;
 }
-
-- 
2.18.0

