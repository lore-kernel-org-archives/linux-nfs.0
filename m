Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f68.google.com ([209.85.160.68]:44127 "EHLO
        mail-pl0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388762AbeGXUh1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:27 -0400
Received: by mail-pl0-f68.google.com with SMTP id m16-v6so2193921pls.11
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:30 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 02/18] wimax: remove blank lines at EOF
Date: Tue, 24 Jul 2018 12:29:02 -0700
Message-Id: <20180724192918.31165-3-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/wimax/Makefile  | 2 --
 net/wimax/debugfs.c | 2 --
 net/wimax/op-msg.c  | 1 -
 net/wimax/stack.c   | 1 -
 4 files changed, 6 deletions(-)

diff --git a/net/wimax/Makefile b/net/wimax/Makefile
index eb2db0d3b880..c2a71ae487ac 100644
--- a/net/wimax/Makefile
+++ b/net/wimax/Makefile
@@ -11,5 +11,3 @@ wimax-y :=		\
 	stack.o
 
 wimax-$(CONFIG_DEBUG_FS) += debugfs.o
-
-
diff --git a/net/wimax/debugfs.c b/net/wimax/debugfs.c
index 6c9bedb7431e..24514840746e 100644
--- a/net/wimax/debugfs.c
+++ b/net/wimax/debugfs.c
@@ -76,5 +76,3 @@ void wimax_debugfs_rm(struct wimax_dev *wimax_dev)
 {
 	debugfs_remove_recursive(wimax_dev->debugfs_dentry);
 }
-
-
diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index 54aa146930bd..101b2fa3f32e 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -404,4 +404,3 @@ int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info)
 	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
 	return result;
 }
-
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 73dba9c077bb..a6307813b6d5 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -630,4 +630,3 @@ module_exit(wimax_subsys_exit);
 MODULE_AUTHOR("Intel Corporation <linux-wimax@intel.com>");
 MODULE_DESCRIPTION("Linux WiMAX stack");
 MODULE_LICENSE("GPL");
-
-- 
2.18.0

