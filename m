Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15816 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398Ab1GVNSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:18:04 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        "James E.J. Bottomley" <JBottomley@parallels.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
        devel@open-fcoe.org
Subject: [PATCH 10/13] net: add paged frag destructor to skb_fill_page_desc()
Date: Fri, 22 Jul 2011 14:17:30 +0100
Message-ID: <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: devel@open-fcoe.org
---
 drivers/block/aoe/aoecmd.c              |    6 ++++--
 drivers/infiniband/ulp/ipoib/ipoib_cm.c |    4 ++--
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    2 +-
 drivers/net/bnx2.c                      |    3 ++-
 drivers/net/bnx2x/bnx2x_cmn.c           |    2 +-
 drivers/net/cxgb3/sge.c                 |    4 ++--
 drivers/net/e1000/e1000_main.c          |   25 +++++++++++++++++--------
 drivers/net/e1000e/netdev.c             |   28 +++++++++++++++++++---------
 drivers/net/ftmac100.c                  |    2 +-
 drivers/net/igb/igb_main.c              |    5 ++---
 drivers/net/igbvf/netdev.c              |    5 ++---
 drivers/net/ixgbe/ixgbe_main.c          |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c      |    2 +-
 drivers/net/qlge/qlge_main.c            |   24 +++++++++++-------------
 drivers/net/sky2.c                      |    2 +-
 drivers/s390/net/qeth_core_main.c       |    7 ++++---
 drivers/scsi/cxgbi/libcxgbi.c           |    8 ++++----
 drivers/scsi/fcoe/fcoe_transport.c      |    2 +-
 drivers/scsi/libfc/fc_fcp.c             |    5 ++++-
 drivers/target/tcm_fc/tfc_io.c          |    5 ++++-
 include/linux/skbuff.h                  |   12 ++++++++----
 net/core/skbuff.c                       |    4 ++--
 net/core/sock.c                         |    2 +-
 net/ipv4/ip_output.c                    |    7 ++++---
 net/ipv4/tcp.c                          |    7 ++++---
 net/ipv6/ip6_output.c                   |    7 +++++--
 net/packet/af_packet.c                  |    2 +-
 27 files changed, 109 insertions(+), 75 deletions(-)

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index de0435e..05c13a0 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -252,7 +252,8 @@ aoecmd_ata_rw(struct aoedev *d)
 		ah->lba3 |= 0xe0;	/* LBA bit + obsolete 0xa0 */
 	}
 	if (bio_data_dir(buf->bio) == WRITE) {
-		skb_fill_page_desc(skb, 0, bv->bv_page, buf->bv_off, bcnt);
+		skb_fill_page_desc(skb, 0, bv->bv_page, NULL, buf->bv_off,
+				   bcnt);
 		ah->aflags |= AOEAFL_WRITE;
 		skb->len += bcnt;
 		skb->data_len = bcnt;
@@ -369,7 +370,8 @@ resend(struct aoedev *d, struct aoetgt *t, struct frame *f)
 		ah->scnt = n >> 9;
 		if (ah->aflags & AOEAFL_WRITE) {
 			skb_fill_page_desc(skb, 0, virt_to_page(f->bufaddr),
-				offset_in_page(f->bufaddr), n);
+					   NULL, offset_in_page(f->bufaddr),
+					   n);
 			skb->len = sizeof *h + sizeof *ah + n;
 			skb->data_len = n;
 		}
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 1f20e40..0d12366 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -167,7 +167,7 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 
 		if (!page)
 			goto partial_error;
-		skb_fill_page_desc(skb, i, page, 0, PAGE_SIZE);
+		skb_fill_page_desc(skb, i, page, NULL, 0, PAGE_SIZE);
 
 		mapping[i + 1] = ib_dma_map_page(priv->ca,
 						 __skb_frag_page(&skb_shinfo(skb)->frags[i]),
@@ -539,7 +539,7 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 		if (length == 0) {
 			/* don't need this page */
 			skb_fill_page_desc(toskb, i, __skb_frag_page(frag),
-					   0, PAGE_SIZE);/* XXX */
+					   NULL, 0, PAGE_SIZE);/* XXX */
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index f6ef6c2..96657c2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -180,7 +180,7 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 		struct page *page = alloc_page(GFP_ATOMIC);
 		if (!page)
 			goto partial_error;
-		skb_fill_page_desc(skb, 0, page, 0, PAGE_SIZE);
+		skb_fill_page_desc(skb, 0, page, NULL, 0, PAGE_SIZE);
 		mapping[1] =
 			ib_dma_map_page(priv->ca,
 					__skb_frag_page(&skb_shinfo(skb)->frags[0]),
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ff90b13..101bac8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3014,7 +3014,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 			if (i == pages - 1)
 				frag_len -= 4;
 
-			skb_fill_page_desc(skb, i, rx_pg->page, 0, frag_len);
+			skb_fill_page_desc(skb, i, rx_pg->page, NULL, 0,
+					   frag_len);
 			rx_pg->page = NULL;
 
 			err = bnx2_alloc_rx_page(bp, rxr,
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index dee09d7..5521077 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -394,7 +394,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
 
 		/* Add one frag and update the appropriate fields in the skb */
-		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
+		skb_fill_page_desc(skb, j, old_rx_pg.page, NULL, 0, frag_len);
 
 		skb->data_len += frag_len;
 		skb->truesize += frag_len;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3f73a5c..6e90ca6 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -889,7 +889,7 @@ recycle:
 	if (!skb) {
 		__skb_put(newskb, SGE_RX_PULL_LEN);
 		memcpy(newskb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
-		skb_fill_page_desc(newskb, 0, sd->pg_chunk.page,
+		skb_fill_page_desc(newskb, 0, sd->pg_chunk.page, NULL,
 				   sd->pg_chunk.offset + SGE_RX_PULL_LEN,
 				   len - SGE_RX_PULL_LEN);
 		newskb->len = len;
@@ -897,7 +897,7 @@ recycle:
 		newskb->truesize += newskb->data_len;
 	} else {
 		skb_fill_page_desc(newskb, skb_shinfo(newskb)->nr_frags,
-				   sd->pg_chunk.page,
+				   sd->pg_chunk.page, NULL,
 				   sd->pg_chunk.offset, len);
 		newskb->len += len;
 		newskb->data_len += len;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e902cd0..93a6898 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3808,13 +3808,17 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			if (!rxtop) {
 				/* this is the beginning of a chain */
 				rxtop = skb;
-				skb_fill_page_desc(rxtop, 0, buffer_info->page,
-				                   0, length);
+				skb_fill_page_desc(rxtop, 0,
+						   buffer_info->page, NULL,
+						   0, length);
 			} else {
 				/* this is the middle of a chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->page,
+						   NULL,
+						   0,
+						   length);
 				/* re-use the skb, only consumed the page */
 				buffer_info->skb = skb;
 			}
@@ -3824,8 +3828,11 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			if (rxtop) {
 				/* end of the chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->page,
+						   NULL,
+						   0,
+						   length);
 				/* re-use the current skb, we only consumed the
 				 * page */
 				buffer_info->skb = skb;
@@ -3848,8 +3855,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 					skb_put(skb, length);
 				} else {
 					skb_fill_page_desc(skb, 0,
-					                   buffer_info->page, 0,
-				                           length);
+							   buffer_info->page,
+							   NULL,
+							   0,
+							   length);
 					e1000_consume_page(buffer_info, skb,
 					                   length);
 				}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 30f8a5c..28da1a7 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1196,7 +1196,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			dma_unmap_page(&pdev->dev, ps_page->dma, PAGE_SIZE,
 				       DMA_FROM_DEVICE);
 			ps_page->dma = 0;
-			skb_fill_page_desc(skb, j, ps_page->page, 0, length);
+			skb_fill_page_desc(skb, j, ps_page->page, NULL, 0,
+					   length);
 			ps_page->page = NULL;
 			skb->len += length;
 			skb->data_len += length;
@@ -1336,13 +1337,17 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			if (!rxtop) {
 				/* this is the beginning of a chain */
 				rxtop = skb;
-				skb_fill_page_desc(rxtop, 0, buffer_info->page,
-				                   0, length);
+				skb_fill_page_desc(rxtop, 0,
+						   buffer_info->page, NULL,
+						   0, length);
 			} else {
 				/* this is the middle of a chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->page,
+						   NULL,
+						   0,
+						   length);
 				/* re-use the skb, only consumed the page */
 				buffer_info->skb = skb;
 			}
@@ -1352,8 +1357,11 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			if (rxtop) {
 				/* end of the chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->page,
+						   NULL,
+						   0,
+						   length);
 				/* re-use the current skb, we only consumed the
 				 * page */
 				buffer_info->skb = skb;
@@ -1377,8 +1385,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 					skb_put(skb, length);
 				} else {
 					skb_fill_page_desc(skb, 0,
-					                   buffer_info->page, 0,
-				                           length);
+							   buffer_info->page,
+							   NULL,
+							   0,
+							   length);
 					e1000_consume_page(buffer_info, skb,
 					                   length);
 				}
diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
index 9bd7746..d8497dd 100644
--- a/drivers/net/ftmac100.c
+++ b/drivers/net/ftmac100.c
@@ -436,7 +436,7 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 
 	length = ftmac100_rxdes_frame_length(rxdes);
 	page = ftmac100_rxdes_get_page(rxdes);
-	skb_fill_page_desc(skb, 0, page, 0, length);
+	skb_fill_page_desc(skb, 0, page, NULL, 0, length);
 	skb->len += length;
 	skb->data_len += length;
 	skb->truesize += length;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 17f94f4..ac48baf 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5835,9 +5835,8 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 			buffer_info->page_dma = 0;
 
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-						buffer_info->page,
-						buffer_info->page_offset,
-						length);
+					   buffer_info->page, NULL,
+					   buffer_info->page_offset, length);
 
 			if ((page_count(buffer_info->page) != 1) ||
 			    (page_to_nid(buffer_info->page) != current_node))
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 3f6655f..9360f0a 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -300,9 +300,8 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 			buffer_info->page_dma = 0;
 
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-			                   buffer_info->page,
-			                   buffer_info->page_offset,
-			                   length);
+					   buffer_info->page, NULL,
+					   buffer_info->page_offset, length);
 
 			if ((adapter->rx_buffer_len > (PAGE_SIZE / 2)) ||
 			    (page_count(buffer_info->page) != 1))
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 307cf06..d481bea 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1409,7 +1409,7 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				       DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-					   rx_buffer_info->page,
+					   rx_buffer_info->page, NULL,
 					   rx_buffer_info->page_offset,
 					   upper_len);
 
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index ad05ad9..347ae21 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -508,7 +508,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-					   rx_buffer_info->page,
+					   rx_buffer_info->page, NULL,
 					   rx_buffer_info->page_offset,
 					   upper_len);
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index cc04e5b..d2a420c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1558,9 +1558,9 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 	netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 		     "%d bytes of headers and data in large. Chain page to new skb and pull tail.\n",
 		     length);
-	skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
-				lbq_desc->p.pg_chunk.offset+ETH_HLEN,
-				length-ETH_HLEN);
+	skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page, NULL,
+			   lbq_desc->p.pg_chunk.offset + ETH_HLEN,
+			   length - ETH_HLEN);
 	skb->len += length-ETH_HLEN;
 	skb->data_len += length-ETH_HLEN;
 	skb->truesize += length-ETH_HLEN;
@@ -1838,8 +1838,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 				     "Chaining page at offset = %d, for %d bytes  to skb.\n",
 				     lbq_desc->p.pg_chunk.offset, length);
 			skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
-						lbq_desc->p.pg_chunk.offset,
-						length);
+					   NULL, lbq_desc->p.pg_chunk.offset,
+					   length);
 			skb->len += length;
 			skb->data_len += length;
 			skb->truesize += length;
@@ -1865,10 +1865,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 				     "%d bytes of headers and data in large. Chain page to new skb and pull tail.\n",
 				     length);
-			skb_fill_page_desc(skb, 0,
-						lbq_desc->p.pg_chunk.page,
-						lbq_desc->p.pg_chunk.offset,
-						length);
+			skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
+					   NULL, lbq_desc->p.pg_chunk.offset,
+					   length);
 			skb->len += length;
 			skb->data_len += length;
 			skb->truesize += length;
@@ -1920,10 +1919,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 				     "Adding page %d to skb for %d bytes.\n",
 				     i, size);
-			skb_fill_page_desc(skb, i,
-						lbq_desc->p.pg_chunk.page,
-						lbq_desc->p.pg_chunk.offset,
-						size);
+			skb_fill_page_desc(skb, i, lbq_desc->p.pg_chunk.page,
+					   NULL, lbq_desc->p.pg_chunk.offset,
+					   size);
 			skb->len += size;
 			skb->data_len += size;
 			skb->truesize += size;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index e1cf142..80c88be 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1388,7 +1388,7 @@ static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 
 		if (!page)
 			goto free_partial;
-		skb_fill_page_desc(skb, i, page, 0, PAGE_SIZE);
+		skb_fill_page_desc(skb, i, page, NULL, 0, PAGE_SIZE);
 	}
 
 	return skb;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index dd08f7b..c50a5b7 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4163,8 +4163,8 @@ static inline int qeth_create_skb_frag(struct qdio_buffer_element *element,
 		} else {
 			get_page(page);
 			memcpy(skb_put(*pskb, 64), element->addr + offset, 64);
-			skb_fill_page_desc(*pskb, *pfrag, page, offset + 64,
-				data_len - 64);
+			skb_fill_page_desc(*pskb, *pfrag, page, NULL,
+					   offset + 64, data_len - 64);
 			(*pskb)->data_len += data_len - 64;
 			(*pskb)->len      += data_len - 64;
 			(*pskb)->truesize += data_len - 64;
@@ -4172,7 +4172,8 @@ static inline int qeth_create_skb_frag(struct qdio_buffer_element *element,
 		}
 	} else {
 		get_page(page);
-		skb_fill_page_desc(*pskb, *pfrag, page, offset, data_len);
+		skb_fill_page_desc(*pskb, *pfrag, page, NULL, offset,
+				   data_len);
 		(*pskb)->data_len += data_len;
 		(*pskb)->len      += data_len;
 		(*pskb)->truesize += data_len;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 8d16a74..94185f9 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1977,8 +1977,8 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 		pg = virt_to_page(task->data);
 
 		get_page(pg);
-		skb_fill_page_desc(skb, 0, pg, offset_in_page(task->data),
-					count);
+		skb_fill_page_desc(skb, 0, pg, NULL,
+				   offset_in_page(task->data), count);
 		skb->len += count;
 		skb->data_len += count;
 		skb->truesize += count;
@@ -1987,8 +1987,8 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 	if (padlen) {
 		i = skb_shinfo(skb)->nr_frags;
 		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-				virt_to_page(padding), offset_in_page(padding),
-				padlen);
+				   virt_to_page(padding), NULL,
+				   offset_in_page(padding), padlen);
 
 		skb->data_len += padlen;
 		skb->truesize += padlen;
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index 40243ce..e957823 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -266,7 +266,7 @@ int fcoe_get_paged_crc_eof(struct sk_buff *skb, int tlen,
 	}
 
 	get_page(page);
-	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page,
+	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, NULL,
 			   fps->crc_eof_offset, tlen);
 	skb->len += tlen;
 	skb->data_len += tlen;
diff --git a/drivers/scsi/libfc/fc_fcp.c b/drivers/scsi/libfc/fc_fcp.c
index 9cd2149..6689515 100644
--- a/drivers/scsi/libfc/fc_fcp.c
+++ b/drivers/scsi/libfc/fc_fcp.c
@@ -640,7 +640,10 @@ static int fc_fcp_send_data(struct fc_fcp_pkt *fsp, struct fc_seq *seq,
 			get_page(page);
 			skb_fill_page_desc(fp_skb(fp),
 					   skb_shinfo(fp_skb(fp))->nr_frags,
-					   page, off & ~PAGE_MASK, sg_bytes);
+					   page,
+					   NULL,
+					   off & ~PAGE_MASK,
+					   sg_bytes);
 			fp_skb(fp)->data_len += sg_bytes;
 			fr_len(fp) += sg_bytes;
 			fp_skb(fp)->truesize += PAGE_SIZE;
diff --git a/drivers/target/tcm_fc/tfc_io.c b/drivers/target/tcm_fc/tfc_io.c
index 8c4a240..53dc0ff 100644
--- a/drivers/target/tcm_fc/tfc_io.c
+++ b/drivers/target/tcm_fc/tfc_io.c
@@ -164,7 +164,10 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
 			get_page(page);
 			skb_fill_page_desc(fp_skb(fp),
 					   skb_shinfo(fp_skb(fp))->nr_frags,
-					   page, off_in_page, tlen);
+					   page,
+					   NULL,
+					   off_in_page,
+					   tlen);
 			fr_len(fp) += tlen;
 			fp_skb(fp)->data_len += tlen;
 			fp_skb(fp)->truesize +=
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9818fe2..faee8d3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1134,12 +1134,14 @@ static inline int skb_pagelen(const struct sk_buff *skb)
  * Does not take any additional reference on the fragment.
  */
 static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
-					struct page *page, int off, int size)
+					struct page *page,
+					struct skb_frag_destructor *destroy,
+					int off, int size)
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 	frag->page.p		  = page;
-	frag->page.destructor     = NULL;
+	frag->page.destructor     = destroy;
 	frag->page_offset	  = off;
 	frag->size		  = size;
 }
@@ -1159,9 +1161,11 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
  * Does not take any additional reference on the fragment.
  */
 static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
-				      struct page *page, int off, int size)
+				      struct page *page,
+				      struct skb_frag_destructor *destroy,
+				      int off, int size)
 {
-	__skb_fill_page_desc(skb, i, page, off, size);
+	__skb_fill_page_desc(skb, i, page, destroy, off, size);
 	skb_shinfo(skb)->nr_frags = i + 1;
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bdc6f6e..101c9cc 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -263,7 +263,7 @@ EXPORT_SYMBOL(__netdev_alloc_skb);
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
-	skb_fill_page_desc(skb, i, page, off, size);
+	skb_fill_page_desc(skb, i, page, NULL, off, size);
 	skb->len += size;
 	skb->data_len += size;
 	skb->truesize += size;
@@ -2454,7 +2454,7 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			return -ENOMEM;
 
 		/* initialize the next frag */
-		skb_fill_page_desc(skb, frg_cnt, page, 0, 0);
+		skb_fill_page_desc(skb, frg_cnt, page, NULL, 0, 0);
 		skb->truesize += PAGE_SIZE;
 		atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 0fb2160..be55676 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1540,7 +1540,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 					}
 
 					__skb_fill_page_desc(skb, i,
-							page, 0,
+							 page, NULL, 0,
 							(data_len >= PAGE_SIZE ?
 							 PAGE_SIZE :
 							 data_len));
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3aa3c91..5946de2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -987,7 +987,8 @@ alloc_new_skb:
 						err = -EMSGSIZE;
 						goto error;
 					}
-					skb_fill_page_desc(skb, i, page, off, 0);
+					skb_fill_page_desc(skb, i, page,
+							   NULL, off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
 					__skb_frag_ref(frag);
 				}
@@ -1003,7 +1004,7 @@ alloc_new_skb:
 				cork->off = 0;
 
 				/* XXX no ref ? */
-				skb_fill_page_desc(skb, i, page, 0, 0);
+				skb_fill_page_desc(skb, i, page, NULL, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
 			} else {
 				err = -EMSGSIZE;
@@ -1227,7 +1228,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 			skb_shinfo(skb)->frags[i-1].size += len;
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
-			skb_fill_page_desc(skb, i, page, offset, len);
+			skb_fill_page_desc(skb, i, page, NULL, offset, len);
 		} else {
 			err = -EMSGSIZE;
 			goto error;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ac47ab3..2f0e985 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -804,7 +804,7 @@ new_segment:
 			copy = size;
 
 		i = skb_shinfo(skb)->nr_frags;
-		can_coalesce = skb_can_coalesce(skb, i, page, offset);
+		can_coalesce = skb_can_coalesce(skb, i, page, NULL, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
@@ -816,7 +816,7 @@ new_segment:
 			skb_shinfo(skb)->frags[i - 1].size += copy;
 		} else {
 			get_page(page);
-			skb_fill_page_desc(skb, i, page, offset, copy);
+			skb_fill_page_desc(skb, i, page, NULL, offset, copy);
 		}
 
 		skb->len += copy;
@@ -1061,7 +1061,8 @@ new_segment:
 					skb_shinfo(skb)->frags[i - 1].size +=
 									copy;
 				} else {
-					skb_fill_page_desc(skb, i, page, off, copy);
+					skb_fill_page_desc(skb, i, page,
+							   NULL, off, copy);
 					if (TCP_PAGE(sk)) {
 						get_page(page);
 					} else if (off + copy < PAGE_SIZE) {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index fdd4f61..c019865 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1446,7 +1446,10 @@ alloc_new_skb:
 						err = -EMSGSIZE;
 						goto error;
 					}
-					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
+					skb_fill_page_desc(skb, i, page,
+							   NULL,
+							   sk->sk_sndmsg_off,
+							   0);
 					frag = &skb_shinfo(skb)->frags[i];
 					__skb_frag_ref(frag);
 				}
@@ -1462,7 +1465,7 @@ alloc_new_skb:
 				sk->sk_sndmsg_off = 0;
 
 				/* XXX no ref ? */
-				skb_fill_page_desc(skb, i, page, 0, 0);
+				skb_fill_page_desc(skb, i, page, NULL, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
 			} else {
 				err = -EMSGSIZE;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c0c3cda..1053c28 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -960,7 +960,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		data += len;
 		flush_dcache_page(page);
 		get_page(page);
-		skb_fill_page_desc(skb, nr_frags, page, offset, len);
+		skb_fill_page_desc(skb, nr_frags, page, NULL, offset, len);
 		to_write -= len;
 		offset = 0;
 		len_max = PAGE_SIZE;
-- 
1.7.2.5

