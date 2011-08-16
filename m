Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53053 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab1HPL0K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 07:26:10 -0400
Subject: [PATCH 6/6] Rename 'n' into a longer variable name.
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: hch@infradead.org, yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org,
        tytso@mit.edu, adilger@whamcloud.com
Date: Tue, 16 Aug 2011 13:26:08 +0200
Message-ID: <20110816112607.1808464.44359.stgit@fsdevel3>
In-Reply-To: <20110816112536.1808464.7174.stgit@fsdevel3>
References: <20110816112536.1808464.7174.stgit@fsdevel3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When it comes to me variable names consisting of a single letter
should be forbidden by coding style guide lines, as it is rather
difficult to search for single letter, such as 'n'.

Rename struct neighbour *n to dst_neigh


Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index fe89c46..189d4cb 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -717,22 +717,22 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
-	struct neighbour *n = NULL;
+	struct neighbour *dst_neigh = NULL;
 	unsigned long flags;
 
 	if (likely(skb_dst(skb)))
-		n = dst_get_neighbour(skb_dst(skb));
+		dst_neigh = dst_get_neighbour(skb_dst(skb));
 
-	if (likely(n)) {
-		if (unlikely(!*to_ipoib_neigh(n))) {
+	if (likely(dst_neigh)) {
+		if (unlikely(!*to_ipoib_neigh(dst_neigh))) {
 			ipoib_path_lookup(skb, dev);
 			return NETDEV_TX_OK;
 		}
 
-		neigh = *to_ipoib_neigh(n);
+		neigh = *to_ipoib_neigh(dst_neigh);
 
 		if (unlikely((memcmp(&neigh->dgid.raw,
-				     n->ha + 4,
+				     dst_neigh->ha + 4,
 				     sizeof(union ib_gid))) ||
 			     (neigh->dev != dev))) {
 			spin_lock_irqsave(&priv->lock, flags);
@@ -758,7 +758,8 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				return NETDEV_TX_OK;
 			}
 		} else if (neigh->ah) {
-			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(n->ha));
+			ipoib_send(dev, skb, neigh->ah,
+				   IPOIB_QPN(dst_neigh->ha));
 			return NETDEV_TX_OK;
 		}
 

