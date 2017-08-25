Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35127 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdHYOWk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 10:22:40 -0400
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
Subject: [PATCH 2/7] bridge: make ebt_table const
Date: Fri, 25 Aug 2017 19:51:42 +0530
Message-Id: <1503670907-23221-3-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make this const as it is only passed to a const argument of the function
ebt_register_table.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/bridge/netfilter/ebtable_nat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 4ecf506..57cd5bb 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -48,7 +48,7 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table frame_nat = {
+static const struct ebt_table frame_nat = {
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-- 
1.9.1

