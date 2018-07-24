Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f65.google.com ([209.85.160.65]:46074 "EHLO
        mail-pl0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388966AbeGXUhx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:53 -0400
Received: by mail-pl0-f65.google.com with SMTP id j8-v6so2131167pll.12
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:56 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 16/18] bpfilter: remove trailing newline
Date: Tue, 24 Jul 2018 12:29:16 -0700
Message-Id: <20180724192918.31165-17-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/bpfilter/Kconfig       | 1 -
 net/ipv4/bpfilter/Makefile | 1 -
 2 files changed, 2 deletions(-)

diff --git a/net/bpfilter/Kconfig b/net/bpfilter/Kconfig
index 76deb6615883..e558b46596c4 100644
--- a/net/bpfilter/Kconfig
+++ b/net/bpfilter/Kconfig
@@ -13,4 +13,3 @@ config BPFILTER_UMH
 	help
 	  This builds bpfilter kernel module with embedded user mode helper
 endif
-
diff --git a/net/ipv4/bpfilter/Makefile b/net/ipv4/bpfilter/Makefile
index ce262d76cc48..e9e42f99725e 100644
--- a/net/ipv4/bpfilter/Makefile
+++ b/net/ipv4/bpfilter/Makefile
@@ -1,2 +1 @@
 obj-$(CONFIG_BPFILTER) += sockopt.o
-
-- 
2.18.0

