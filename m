Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37719 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdHYOXq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 10:23:46 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com, davem@davemloft.net, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, stephen@networkplumber.org,
        alex.aring@gmail.com, stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, santosh.shilimkar@oracle.com,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, bridge@lists.linux-foundation.org,
        linux-wpan@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 6/7] netfilter: nat: make rhashtable_params const
Date: Fri, 25 Aug 2017 19:51:46 +0530
Message-Id: <1503670907-23221-7-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make this const as it is either used during a copy operation or passed
to a const argument of the function rhltable_init.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index b1d3740..df983ea 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -198,7 +198,7 @@ static int nf_nat_bysource_cmp(struct rhashtable_compare_arg *arg,
 	return 0;
 }
 
-static struct rhashtable_params nf_nat_bysource_params = {
+static const struct rhashtable_params nf_nat_bysource_params = {
 	.head_offset = offsetof(struct nf_conn, nat_bysource),
 	.obj_hashfn = nf_nat_bysource_hash,
 	.obj_cmpfn = nf_nat_bysource_cmp,
-- 
1.9.1

