Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53032 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab1HPL0E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 07:26:04 -0400
Subject: [PATCH 5/6] Fix possible Null pointer dereference in
	ipoib_start_xmit()
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Date: Tue, 16 Aug 2011 13:26:02 +0200
Message-ID: <20110816112602.1808464.35621.stgit@fsdevel3>
In-Reply-To: <20110816112536.1808464.7174.stgit@fsdevel3>
References: <20110816112536.1808464.7174.stgit@fsdevel3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This will fix https://bugzilla.kernel.org/show_bug.cgi?id=41212

fslab2 login: [  114.392408] EXT4-fs (sdc): barriers disabled
[  114.449737] EXT4-fs (sdc): mounted filesystem with writeback data mode.
Opts: journal_async_commit,barrier=0,data=writeback
[  240.944030] BUG: unable to handle kernel NULL pointer dereference at
0000000000000040
[  240.948007] IP: [<ffffffffa0366ce9>] ipoib_start_xmit+0x39/0x280 [ib_ipoib]
[...]
[  240.948007] Call Trace:
[  240.948007]  <IRQ>
[  240.948007]  [<ffffffff812cd5e0>] dev_hard_start_xmit+0x2a0/0x590
[  240.948007]  [<ffffffff8131f680>] ? arp_create+0x70/0x200
[  240.948007]  [<ffffffff812e8e1f>] sch_direct_xmit+0xef/0x1c0

Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 43f89ba..fe89c46 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -717,11 +717,13 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
-	struct neighbour *n;
+	struct neighbour *n = NULL;
 	unsigned long flags;
 
-	n = dst_get_neighbour(skb_dst(skb));
-	if (likely(skb_dst(skb) && n)) {
+	if (likely(skb_dst(skb)))
+		n = dst_get_neighbour(skb_dst(skb));
+
+	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
 			ipoib_path_lookup(skb, dev);
 			return NETDEV_TX_OK;

