From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 13/30] net: packet split receive api
Date: Tue, 13 Jul 2010 06:19:17 -0400
Message-ID: <20100713101917.2835.76645.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 8d908090b5314bed0c3318d82891b8c3bbf27815 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:03:55 +0800
Subject: [PATCH 13/30] net: packet split receive api

Add some packet-split receive hooks.

For one this allows to do NUMA node affine page allocs. Later on these hooks
will be extended to do emergency reserve allocations for fragments.

Thanks to Jiri Bohac for fixing a bug in bnx2.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 drivers/net/bnx2.c             |    9 +++------
 drivers/net/e1000e/netdev.c    |    7 ++-----
 drivers/net/igb/igb_main.c     |    6 +-----
 drivers/net/ixgbe/ixgbe_main.c |   14 ++++++--------
 drivers/net/sky2.c             |   16 ++++++----------
 5 files changed, 18 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a5dd81f..f6f83d0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2670,7 +2670,7 @@ bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	struct sw_pg *rx_pg = &rxr->rx_pg_ring[index];
 	struct rx_bd *rxbd =
 		&rxr->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
-	struct page *page = alloc_page(GFP_ATOMIC);
+	struct page *page = netdev_alloc_page(bp->dev);
 
 	if (!page)
 		return -ENOMEM;
@@ -2700,7 +2700,7 @@ bnx2_free_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	pci_unmap_page(bp->pdev, dma_unmap_addr(rx_pg, mapping), PAGE_SIZE,
 		       PCI_DMA_FROMDEVICE);
 
-	__free_page(page);
+	netdev_free_page(bp->dev, page);
 	rx_pg->page = NULL;
 }
 
@@ -3035,7 +3035,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 			if (i == pages - 1)
 				frag_len -= 4;
 
-			skb_fill_page_desc(skb, i, rx_pg->page, 0, frag_len);
+			skb_add_rx_frag(skb, i, rx_pg->page, 0, frag_len);
 			rx_pg->page = NULL;
 
 			err = bnx2_alloc_rx_page(bp, rxr,
@@ -3052,9 +3052,6 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
 
 			frag_size -= frag_len;
-			skb->data_len += frag_len;
-			skb->truesize += frag_len;
-			skb->len += frag_len;
 
 			pg_prod = NEXT_RX_BD(pg_prod);
 			pg_cons = RX_PG_RING_IDX(NEXT_RX_BD(pg_cons));
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 20c5ecf..a381e18 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -604,7 +604,7 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 				continue;
 			}
 			if (!ps_page->page) {
-				ps_page->page = alloc_page(GFP_ATOMIC);
+				ps_page->page = netdev_alloc_page(netdev);
 				if (!ps_page->page) {
 					adapter->alloc_rx_buff_failed++;
 					goto no_buffers;
@@ -1185,11 +1185,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			dma_unmap_page(&pdev->dev, ps_page->dma, PAGE_SIZE,
 				       DMA_FROM_DEVICE);
 			ps_page->dma = 0;
-			skb_fill_page_desc(skb, j, ps_page->page, 0, length);
+			skb_add_rx_frag(skb, j, ps_page->page, 0, length);
 			ps_page->page = NULL;
-			skb->len += length;
-			skb->data_len += length;
-			skb->truesize += length;
 		}
 
 		/* strip the ethernet crc, problem is we're using pages now so
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3881918..7361864 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5574,7 +5574,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
 			buffer_info->page_dma = 0;
 
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
 						buffer_info->page,
 						buffer_info->page_offset,
 						length);
@@ -5584,10 +5584,6 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 				buffer_info->page = NULL;
 			else
 				get_page(buffer_info->page);
-
-			skb->len += length;
-			skb->data_len += length;
-			skb->truesize += length;
 		}
 
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dd46345..60d789c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1037,6 +1037,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
                                    int cleaned_count)
 {
 	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *netdev = adapter->netdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
@@ -1050,7 +1051,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		if (!bi->page_dma &&
 		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC);
+				bi->page = netdev_alloc_page(netdev);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
@@ -1242,10 +1243,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			dma_unmap_page(&pdev->dev, rx_buffer_info->page_dma,
 				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-			                   rx_buffer_info->page,
-			                   rx_buffer_info->page_offset,
-			                   upper_len);
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+					rx_buffer_info->page,
+					rx_buffer_info->page_offset,
+					upper_len);
 
 			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
 			    (page_count(rx_buffer_info->page) != 1))
@@ -1253,9 +1254,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			else
 				get_page(rx_buffer_info->page);
 
-			skb->len += upper_len;
-			skb->data_len += upper_len;
-			skb->truesize += upper_len;
 		}
 
 		i++;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index c762c6a..5753b8b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1394,7 +1394,7 @@ static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 		skb_reserve(skb, NET_IP_ALIGN);
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
-		struct page *page = alloc_page(GFP_ATOMIC);
+		struct page *page = netdev_alloc_page(sky2->netdev);
 
 		if (!page)
 			goto free_partial;
@@ -2353,8 +2353,8 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 }
 
 /* Adjust length of skb with fragments to match received data */
-static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
-			  unsigned int length)
+static void skb_put_frags(struct sky2_port *sky2, struct sk_buff *skb,
+			  unsigned int hdr_space, unsigned int length)
 {
 	int i, num_frags;
 	unsigned int size;
@@ -2371,15 +2371,11 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 
 		if (length == 0) {
 			/* don't need this page */
-			__free_page(frag->page);
+			netdev_free_page(sky2->netdev, frag->page);
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size = min(length, (unsigned) PAGE_SIZE);
-
-			frag->size = size;
-			skb->data_len += size;
-			skb->truesize += size;
-			skb->len += size;
+			skb_add_rx_frag(skb, i, frag->page, 0, size);
 			length -= size;
 		}
 	}
@@ -2407,7 +2403,7 @@ static struct sk_buff *receive_new(struct sky2_port *sky2,
 	*re = nre;
 
 	if (skb_shinfo(skb)->nr_frags)
-		skb_put_frags(skb, hdr_space, length);
+		skb_put_frags(sky2, skb, hdr_space, length);
 	else
 		skb_put(skb, length);
 	return skb;
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
