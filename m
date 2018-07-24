Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f196.google.com ([209.85.215.196]:39964 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388867AbeGXUhk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:40 -0400
Received: by mail-pg1-f196.google.com with SMTP id x5-v6so3576472pgp.7
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:43 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 09/18] ila: remove blank lines at EOF
Date: Tue, 24 Jul 2018 12:29:09 -0700
Message-Id: <20180724192918.31165-10-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv6/ila/ila_common.c | 1 -
 net/ipv6/ila/ila_xlat.c   | 1 -
 2 files changed, 2 deletions(-)

diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index 579310466eac..95e9146918cc 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -153,4 +153,3 @@ void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p,
 	/* Now change destination address */
 	iaddr->loc = p->locator;
 }
-
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 51a15ce50a64..17c455ff69ff 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -663,4 +663,3 @@ static int ila_xlat_addr(struct sk_buff *skb, bool sir2ila)
 
 	return 0;
 }
-
-- 
2.18.0

