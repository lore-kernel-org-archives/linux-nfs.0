Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf1-f194.google.com ([209.85.210.194]:43528 "EHLO
        mail-pf1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388905AbeGXUhp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2018 16:37:45 -0400
Received: by mail-pf1-f194.google.com with SMTP id j26-v6so1079372pfi.10
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2018 12:29:49 -0700 (PDT)
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
Subject: [PATCH PATCH net-next 12/18] ax25: remove blank line at EOF
Date: Tue, 24 Jul 2018 12:29:12 -0700
Message-Id: <20180724192918.31165-13-sthemmin@microsoft.com>
In-Reply-To: <20180724192918.31165-1-sthemmin@microsoft.com>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ax25/ax25_addr.c    | 1 -
 net/ax25/ax25_ds_in.c   | 1 -
 net/ax25/ax25_ds_subr.c | 1 -
 net/ax25/ax25_ip.c      | 1 -
 net/ax25/ax25_out.c     | 1 -
 5 files changed, 5 deletions(-)

diff --git a/net/ax25/ax25_addr.c b/net/ax25/ax25_addr.c
index ac2542b7be88..a14cfa736b63 100644
--- a/net/ax25/ax25_addr.c
+++ b/net/ax25/ax25_addr.c
@@ -304,4 +304,3 @@ void ax25_digi_invert(const ax25_digi *in, ax25_digi *out)
 		}
 	}
 }
-
diff --git a/net/ax25/ax25_ds_in.c b/net/ax25/ax25_ds_in.c
index 891596e74278..488fc2d7085a 100644
--- a/net/ax25/ax25_ds_in.c
+++ b/net/ax25/ax25_ds_in.c
@@ -299,4 +299,3 @@ int ax25_ds_frame_in(ax25_cb *ax25, struct sk_buff *skb, int type)
 
 	return queued;
 }
-
diff --git a/net/ax25/ax25_ds_subr.c b/net/ax25/ax25_ds_subr.c
index 28827e81ba2b..bc0329f43013 100644
--- a/net/ax25/ax25_ds_subr.c
+++ b/net/ax25/ax25_ds_subr.c
@@ -205,4 +205,3 @@ void ax25_dama_off(ax25_cb *ax25)
 	ax25->condition &= ~AX25_COND_DAMA_MODE;
 	ax25_dev_dama_off(ax25->ax25_dev);
 }
-
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 183b1c583d56..70417e9b932d 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -249,4 +249,3 @@ const struct header_ops ax25_header_ops = {
 
 EXPORT_SYMBOL(ax25_header_ops);
 EXPORT_SYMBOL(ax25_ip_xmit);
-
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index b11a5f466fcc..3e5afc8dc93e 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -394,4 +394,3 @@ int ax25_check_iframes_acked(ax25_cb *ax25, unsigned short nr)
 	}
 	return 0;
 }
-
-- 
2.18.0

