Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33442 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdHYOWZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 10:22:25 -0400
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
Subject: [PATCH 1/7] Bluetooth: 6lowpan: make header_ops const
Date: Fri, 25 Aug 2017 19:51:41 +0530
Message-Id: <1503670907-23221-2-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make this const as it is only stored as a reference in a const field of
a net_device structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/bluetooth/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 4e2576f..50fcdd1 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -581,7 +581,7 @@ static int bt_dev_init(struct net_device *dev)
 	.ndo_start_xmit		= bt_xmit,
 };
 
-static struct header_ops header_ops = {
+static const struct header_ops header_ops = {
 	.create	= header_create,
 };
 
-- 
1.9.1

