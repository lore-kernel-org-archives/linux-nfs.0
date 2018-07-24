Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f195.google.com ([209.85.215.195]:44309 "EHLO
        mail-pg1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388831AbeGXUhe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:34 -0400
Received: by mail-pg1-f195.google.com with SMTP id r1-v6so3567489pgp.11
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:38 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 06/18] xfrm: remove blank lines at EOF
Date: Tue, 24 Jul 2018 12:29:06 -0700
Message-Id: <20180724192918.31165-7-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/xfrm/Kconfig     | 1 -
 net/xfrm/xfrm_user.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 286ed25c1a69..eab952cca7d0 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -87,4 +87,3 @@ config NET_KEY_MIGRATE
 	  <draft-sugimoto-mip6-pfkey-migrate>.
 
 	  If unsure, say N.
-
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 080035f056d9..09cceab450b8 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -3280,4 +3280,3 @@ module_init(xfrm_user_init);
 module_exit(xfrm_user_exit);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_XFRM);
-
-- 
2.18.0

