Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23859 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346Ab1GVNRs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:17:48 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 04/13] net: convert core to skb paged frag APIs
Date: Fri, 22 Jul 2011 14:17:24 +0100
Message-ID: <1311340653-19336-4-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Michał Mirosław" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |    4 ++--
 net/core/datagram.c    |   20 ++++++++------------
 net/core/dev.c         |    7 +++----
 net/core/kmap_skb.h    |    2 +-
 net/core/pktgen.c      |    3 +--
 net/core/skbuff.c      |   31 +++++++++++++++++--------------
 net/core/sock.c        |   12 +++++-------
 net/core/user_dma.c    |    2 +-
 8 files changed, 38 insertions(+), 43 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f4034af..bc6bd24 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1906,12 +1906,12 @@ static inline int skb_add_data(struct sk_buff *skb,
 }
 
 static inline int skb_can_coalesce(struct sk_buff *skb, int i,
-				   struct page *page, int off)
+				   const struct page *page, int off)
 {
 	if (i) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
 
-		return page == frag->page &&
+		return page == skb_frag_page(frag) &&
 		       off == frag->page_offset + frag->size;
 	}
 	return 0;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 18ac112..f0dcaa2 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -332,14 +332,13 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			struct page *page = frag->page;
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap(page);
+			vaddr = skb_frag_kmap(frag);
 			err = memcpy_toiovec(to, vaddr + frag->page_offset +
 					     offset - start, copy);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 			if (!(len -= copy))
@@ -418,14 +417,13 @@ int skb_copy_datagram_const_iovec(const struct sk_buff *skb, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			struct page *page = frag->page;
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap(page);
+			vaddr = skb_frag_kmap(frag);
 			err = memcpy_toiovecend(to, vaddr + frag->page_offset +
 						offset - start, to_offset, copy);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 			if (!(len -= copy))
@@ -508,15 +506,14 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			struct page *page = frag->page;
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap(page);
+			vaddr = skb_frag_kmap(frag);
 			err = memcpy_fromiovecend(vaddr + frag->page_offset +
 						  offset - start,
 						  from, from_offset, copy);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 
@@ -594,16 +591,15 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 			int err = 0;
 			u8  *vaddr;
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			struct page *page = frag->page;
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap(page);
+			vaddr = skb_frag_kmap(frag);
 			csum2 = csum_and_copy_to_user(vaddr +
 							frag->page_offset +
 							offset - start,
 						      to, copy, 0, &err);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 			*csump = csum_block_add(*csump, csum2, pos);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9c58c1e..9ab39c0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3414,7 +3414,7 @@ pull:
 		skb_shinfo(skb)->frags[0].size -= grow;
 
 		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
-			put_page(skb_shinfo(skb)->frags[0].page);
+			skb_frag_unref(skb, 0);
 			memmove(skb_shinfo(skb)->frags,
 				skb_shinfo(skb)->frags + 1,
 				--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
@@ -3478,10 +3478,9 @@ void skb_gro_reset_offset(struct sk_buff *skb)
 	NAPI_GRO_CB(skb)->frag0_len = 0;
 
 	if (skb->mac_header == skb->tail &&
-	    !PageHighMem(skb_shinfo(skb)->frags[0].page)) {
+	    !PageHighMem(skb_frag_page(&skb_shinfo(skb)->frags[0]))) {
 		NAPI_GRO_CB(skb)->frag0 =
-			page_address(skb_shinfo(skb)->frags[0].page) +
-			skb_shinfo(skb)->frags[0].page_offset;
+			skb_frag_address(&skb_shinfo(skb)->frags[0]);
 		NAPI_GRO_CB(skb)->frag0_len = skb_shinfo(skb)->frags[0].size;
 	}
 }
diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
index 283c2b9..b1e9711 100644
--- a/net/core/kmap_skb.h
+++ b/net/core/kmap_skb.h
@@ -7,7 +7,7 @@ static inline void *kmap_skb_frag(const skb_frag_t *frag)
 
 	local_bh_disable();
 #endif
-	return kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ);
+	return kmap_atomic(__skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
 }
 
 static inline void kunmap_skb_frag(void *vaddr)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f76079c..989b2b6 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2600,8 +2600,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 				if (!pkt_dev->page)
 					break;
 			}
-			skb_shinfo(skb)->frags[i].page = pkt_dev->page;
-			get_page(pkt_dev->page);
+			skb_frag_set_page(skb, i, pkt_dev->page);
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			/*last fragment, fill rest of data*/
 			if (i == (frags - 1))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..2133600 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -326,7 +326,7 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+				skb_frag_unref(skb, i);
 		}
 
 		if (skb_has_frag_list(skb))
@@ -733,7 +733,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
-			get_page(skb_shinfo(n)->frags[i].page);
+			skb_frag_ref(skb, i);
 		}
 		skb_shinfo(n)->nr_frags = i;
 	}
@@ -820,7 +820,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		kfree(skb->head);
 	} else {
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-			get_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_ref(skb, i);
 
 		if (skb_has_frag_list(skb))
 			skb_clone_fraglist(skb);
@@ -1098,7 +1098,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_unref(skb, i);
 
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
@@ -1267,7 +1267,7 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_unref(skb, i);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -1512,7 +1512,9 @@ static int __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 	for (seg = 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
 		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
 
-		if (__splice_segment(f->page, f->page_offset, f->size,
+		/* XXX */
+		if (__splice_segment(__skb_frag_page(f),
+				     f->page_offset, f->size,
 				     offset, len, skb, spd, 0, sk, pipe))
 			return 1;
 	}
@@ -2057,7 +2059,7 @@ static inline void skb_split_no_header(struct sk_buff *skb,
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				skb_frag_ref(skb, i);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -2132,7 +2134,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 	 * commit all, so that we don't have to undo partial changes
 	 */
 	if (!to ||
-	    !skb_can_coalesce(tgt, to, fragfrom->page, fragfrom->page_offset)) {
+	    !skb_can_coalesce(tgt, to, skb_frag_page(fragfrom),
+			      fragfrom->page_offset)) {
 		merge = -1;
 	} else {
 		merge = to - 1;
@@ -2179,7 +2182,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 			to++;
 
 		} else {
-			get_page(fragfrom->page);
+			__skb_frag_ref(fragfrom);
 			fragto->page = fragfrom->page;
 			fragto->page_offset = fragfrom->page_offset;
 			fragto->size = todo;
@@ -2201,7 +2204,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 		fragto = &skb_shinfo(tgt)->frags[merge];
 
 		fragto->size += fragfrom->size;
-		put_page(fragfrom->page);
+		__skb_frag_unref(fragfrom);
 	}
 
 	/* Reposition in the original skb */
@@ -2446,8 +2449,7 @@ int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 		left = PAGE_SIZE - frag->page_offset;
 		copy = (length > left)? left : length;
 
-		ret = getfrag(from, (page_address(frag->page) +
-			    frag->page_offset + frag->size),
+		ret = getfrag(from, skb_frag_address(frag) + frag->size,
 			    offset, copy, 0, skb);
 		if (ret < 0)
 			return -EFAULT;
@@ -2599,7 +2601,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, u32 features)
 
 		while (pos < offset + len && i < nfrags) {
 			*frag = skb_shinfo(skb)->frags[i];
-			get_page(frag->page);
+			__skb_frag_ref(frag);
 			size = frag->size;
 
 			if (pos < offset) {
@@ -2822,7 +2824,8 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len)
 
 			if (copy > len)
 				copy = len;
-			sg_set_page(&sg[elt], frag->page, copy,
+			/* XXX */
+			sg_set_page(&sg[elt], __skb_frag_page(frag), copy,
 					frag->page_offset+offset-start);
 			elt++;
 			if (!(len -= copy))
diff --git a/net/core/sock.c b/net/core/sock.c
index 6e81978..0fb2160 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1530,7 +1530,6 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 				skb_shinfo(skb)->nr_frags = npages;
 				for (i = 0; i < npages; i++) {
 					struct page *page;
-					skb_frag_t *frag;
 
 					page = alloc_pages(sk->sk_allocation, 0);
 					if (!page) {
@@ -1540,12 +1539,11 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 						goto failure;
 					}
 
-					frag = &skb_shinfo(skb)->frags[i];
-					frag->page = page;
-					frag->page_offset = 0;
-					frag->size = (data_len >= PAGE_SIZE ?
-						      PAGE_SIZE :
-						      data_len);
+					__skb_fill_page_desc(skb, i,
+							page, 0,
+							(data_len >= PAGE_SIZE ?
+							 PAGE_SIZE :
+							 data_len));
 					data_len -= PAGE_SIZE;
 				}
 
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 25d717e..d22ec3e 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -78,7 +78,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,
 		copy = end - offset;
 		if (copy > 0) {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-			struct page *page = frag->page;
+			struct page *page = __skb_frag_page(frag); /* XXX */
 
 			if (copy > len)
 				copy = len;
-- 
1.7.2.5

