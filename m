From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 17/30] netvm: hook skb allocation to reserves
Date: Tue, 13 Jul 2010 06:20:03 -0400
Message-ID: <20100713102003.2835.88018.sendpatchset@danny.redhat>
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

>From 3e824860934af5aa0150608314693c5e0e3608b6 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:30:27 +0800
Subject: [PATCH 17/30] netvm: hook skb allocation to reserves

Change the skb allocation api to indicate RX usage and use this to fall back to
the reserve when needed. SKBs allocated from the reserve are tagged in
skb->emergency.

Teach all other skb ops about emergency skbs and the reserve accounting.

Use the (new) packet split API to allocate and track fragment pages from the
emergency reserve. Do this using an atomic counter in page->index. This is
needed because the fragments have a different sharing semantic than that
indicated by skb_shinfo()->dataref.

Note that the decision to distinguish between regular and emergency SKBs allows
the accounting overhead to be limited to the later kind.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 include/linux/mm_types.h |    1 +
 include/linux/skbuff.h   |   27 +++++++--
 net/core/skbuff.c        |  137 +++++++++++++++++++++++++++++++++++++---------
 3 files changed, 133 insertions(+), 32 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index a95a202..73e0526 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -72,6 +72,7 @@ struct page {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
 		int reserve;		/* page_alloc: page is a reserve page */
+		atomic_t frag_count;	/* skb fragment use count */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 988a4dc..4ac45ad 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -385,9 +385,12 @@ struct sk_buff {
 #else
 	__u8			deliver_no_wcard:1;
 #endif
+#ifdef CONFIG_NETVM
+	__u8                    emergency:1;
+#endif
 	kmemcheck_bitfield_end(flags2);
 
-	/* 0/14 bit hole */
+	/* 0/13/14 bit hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
@@ -429,6 +432,18 @@ struct sk_buff {
 #define SKB_DST_NOREF	1UL
 #define SKB_DST_PTRMASK	~(SKB_DST_NOREF)
 
+#define SKB_ALLOC_FCLONE       0x01
+#define SKB_ALLOC_RX           0x02
+
+static inline bool skb_emergency(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NETVM
+	return unlikely(skb->emergency);
+#else
+	return false;
+#endif
+}
+
 /**
  * skb_dst - returns skb dst_entry
  * @skb: buffer
@@ -491,7 +506,7 @@ extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int flags, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
@@ -501,7 +516,7 @@ static inline struct sk_buff *alloc_skb(unsigned int size,
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, -1);
 }
 
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
@@ -1516,7 +1531,8 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      gfp_t gfp_mask)
 {
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+	struct sk_buff *skb =
+		__alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, -1);
 	if (likely(skb))
 		skb_reserve(skb, NET_SKB_PAD);
 	return skb;
@@ -1557,6 +1573,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
 }
 
 extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask);
+extern void __netdev_free_page(struct net_device *dev, struct page *page);
 
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
@@ -1573,7 +1590,7 @@ static inline struct page *netdev_alloc_page(struct net_device *dev)
 
 static inline void netdev_free_page(struct net_device *dev, struct page *page)
 {
-	__free_page(page);
+	__netdev_free_page(dev, page);
 }
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 34432b4..9e36dc2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -168,14 +168,21 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone, int node)
+			    int flags, int node)
 {
 	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
+	int emergency = 0;
+	int memalloc = sk_memalloc_socks();
 
-	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+	size = SKB_DATA_ALIGN(size);
+	cache = (flags & SKB_ALLOC_FCLONE)
+		? skbuff_fclone_cache : skbuff_head_cache;
+
+	if (memalloc && (flags & SKB_ALLOC_RX))
+		gfp_mask |= __GFP_MEMALLOC;
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
@@ -183,9 +190,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 	prefetchw(skb);
 
-	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+	data = kmalloc_reserve(size + sizeof(struct skb_shared_info),
+			gfp_mask, node, &net_skb_reserve, &emergency);
 	if (!data)
 		goto nodata;
 	prefetchw(data + size);
@@ -196,6 +202,9 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
+#ifdef CONFIG_NETVM
+	skb->emergency = emergency;
+#endif
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -213,7 +222,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
 
-	if (fclone) {
+	if (flags & SKB_ALLOC_FCLONE) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
@@ -223,6 +232,9 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		atomic_set(fclone_ref, 1);
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
+#ifdef CONFIG_NETVM
+		child->emergency = skb->emergency;
+#endif
 	}
 out:
 	return skb;
@@ -252,7 +264,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, SKB_ALLOC_RX, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -266,11 +278,19 @@ struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mask)
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct page *page;
 
-	page = alloc_pages_node(node, gfp_mask, 0);
+	page = alloc_pages_reserve(node, gfp_mask | __GFP_MEMALLOC, 0,
+			&net_skb_reserve, NULL);
+
 	return page;
 }
 EXPORT_SYMBOL(__netdev_alloc_page);
 
+void __netdev_free_page(struct net_device *dev, struct page *page)
+{
+	free_pages_reserve(page, 0, &net_skb_reserve, page->reserve);
+}
+EXPORT_SYMBOL(__netdev_free_page);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 		int size)
 {
@@ -278,6 +298,27 @@ void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 	skb->len += size;
 	skb->data_len += size;
 	skb->truesize += size;
+
+#ifdef CONFIG_NETVM
+	/*
+	 * In the rare case that skb_emergency() != page->reserved we'll
+	 * skew the accounting slightly, but since its only a 'small' constant
+	 * shift its ok.
+	 */
+	if (skb_emergency(skb)) {
+		/*
+		 * We need to track fragment pages so that we properly
+		 * release their reserve in skb_put_page().
+		 */
+		atomic_set(&page->frag_count, 1);
+	} else if (unlikely(page->reserve)) {
+		/*
+		 * Release the reserve now, because normal skbs don't
+		 * do the emergency accounting.
+		 */
+		mem_reserve_pages_charge(&net_skb_reserve, -1);
+	}
+#endif
 }
 EXPORT_SYMBOL(skb_add_rx_frag);
 
@@ -329,21 +370,38 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 		skb_get(list);
 }
 
+static void skb_get_page(struct sk_buff *skb, struct page *page)
+{
+	get_page(page);
+	if (skb_emergency(skb))
+		atomic_inc(&page->frag_count);
+}
+
+static void skb_put_page(struct sk_buff *skb, struct page *page)
+{
+	if (skb_emergency(skb) && atomic_dec_and_test(&page->frag_count))
+		mem_reserve_pages_charge(&net_skb_reserve, -1);
+	put_page(page);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+				skb_put_page(skb,
+					     skb_shinfo(skb)->frags[i].page);
+			}
 		}
 
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		kfree_reserve(skb->head, &net_skb_reserve, skb_emergency(skb));
 	}
 }
 
@@ -536,6 +594,9 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	= old->ipvs_property;
 #endif
+#ifdef CONFIG_NETVM
+	new->emergency		= old->emergency;
+#endif
 	new->protocol		= old->protocol;
 	new->mark		= old->mark;
 	new->skb_iif		= old->skb_iif;
@@ -630,6 +691,9 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
 	} else {
+		if (skb_emergency(skb))
+			gfp_mask |= __GFP_MEMALLOC;
+
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -666,6 +730,14 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
 }
 
+static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
+{
+	if (skb_emergency(skb))
+		return SKB_ALLOC_RX;
+
+	return 0;
+}
+
 /**
  *	skb_copy	-	create private copy of an sk_buff
  *	@skb: buffer to copy
@@ -686,15 +758,17 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int headerlen = skb->data - skb->head;
+	int size;
 	/*
 	 *	Allocate the copy buffer
 	 */
 	struct sk_buff *n;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end + skb->data_len, gfp_mask);
+	size = skb->end + skb->data_len;
 #else
-	n = alloc_skb(skb->end - skb->head + skb->data_len, gfp_mask);
+	size = skb->end - skb->head + skb->data_len;
 #endif
+	n = __alloc_skb(size, gfp_mask, skb_alloc_rx_flag(skb), -1);
 	if (!n)
 		return NULL;
 
@@ -729,12 +803,14 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 	/*
 	 *	Allocate the copy buffer
 	 */
+	int size;
 	struct sk_buff *n;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end, gfp_mask);
+	size = skb->end;
 #else
-	n = alloc_skb(skb->end - skb->head, gfp_mask);
+	size = skb->end - skb->head;
 #endif
+	n = __alloc_skb(size, gfp_mask, skb_alloc_rx_flag(skb), -1);
 	if (!n)
 		goto out;
 
@@ -753,8 +829,9 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 		int i;
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
-			get_page(skb_shinfo(n)->frags[i].page);
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			skb_shinfo(n)->frags[i] = *frag;
+			skb_get_page(n, frag->page);
 		}
 		skb_shinfo(n)->nr_frags = i;
 	}
@@ -805,7 +882,11 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	size = SKB_DATA_ALIGN(size);
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (skb_emergency(skb))
+		gfp_mask |= __GFP_MEMALLOC;
+
+	data = kmalloc_reserve(size + sizeof(struct skb_shared_info),
+			gfp_mask, -1, &net_skb_reserve, NULL);
 	if (!data)
 		goto nodata;
 
@@ -820,7 +901,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	       sizeof(struct skb_shared_info));
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+		skb_get_page(skb, skb_shinfo(skb)->frags[i].page);
 
 	if (skb_has_frags(skb))
 		skb_clone_fraglist(skb);
@@ -901,8 +982,8 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	/*
 	 *	Allocate the copy buffer
 	 */
-	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
-				      gfp_mask);
+	struct sk_buff *n = __alloc_skb(newheadroom + skb->len + newtailroom,
+					gfp_mask, skb_alloc_rx_flag(skb), -1);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
 	int off;
@@ -1094,7 +1175,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags = i;
 
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 
 		if (skb_has_frags(skb))
 			skb_drop_fraglist(skb);
@@ -1263,7 +1344,7 @@ pull_pages:
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_put_page(skb, skb_shinfo(skb)->frags[i].page);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
@@ -2045,6 +2126,7 @@ static inline void skb_split_no_header(struct sk_buff *skb,
 			skb_shinfo(skb1)->frags[k] = skb_shinfo(skb)->frags[i];
 
 			if (pos < len) {
+				struct page *page = skb_shinfo(skb)->frags[i].page;
 				/* Split frag.
 				 * We have two variants in this case:
 				 * 1. Move all the frag to the second
@@ -2053,7 +2135,7 @@ static inline void skb_split_no_header(struct sk_buff *skb,
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				skb_get_page(skb1, page);
 				skb_shinfo(skb1)->frags[0].page_offset += len - pos;
 				skb_shinfo(skb1)->frags[0].size -= len - pos;
 				skb_shinfo(skb)->frags[i].size	= len - pos;
@@ -2552,8 +2634,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 			skb_release_head_state(nskb);
 			__skb_push(nskb, doffset);
 		} else {
-			nskb = alloc_skb(hsize + doffset + headroom,
-					 GFP_ATOMIC);
+			nskb = __alloc_skb(hsize + doffset + headroom,
+					 GFP_ATOMIC, skb_alloc_rx_flag(skb),
+					 -1);
 
 			if (unlikely(!nskb))
 				goto err;
@@ -2595,7 +2678,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 
 		while (pos < offset + len && i < nfrags) {
 			*frag = skb_shinfo(skb)->frags[i];
-			get_page(frag->page);
+			skb_get_page(nskb, frag->page);
 			size = frag->size;
 
 			if (pos < offset) {
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
