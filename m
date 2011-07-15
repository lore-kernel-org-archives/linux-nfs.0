Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32675 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab1GOLQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 07:16:51 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
CC: linux-nfs@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 07/10] net: add support for per-paged-fragment destructors
Date: Fri, 15 Jul 2011 12:07:08 +0100
Message-ID: <1310728031-19569-7-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Entities which care about the complete lifecycle of pages which they inject
into the network stack via an skb paged fragment can choose to set this
destructor in order to receive a callback when the stack is really finished
with a page (including all clones, retransmits, pull-ups etc etc).

This destructor will always be propagated alongside the struct page when
copying skb_frag_t->page. This is the reason I chose to embed the destructor in
a "struct { } page" within the skb_frag_t, rather than as a separate field,
since it allows existing code which propagates ->frags[N].page to Just
Work(tm).

When the destructor is present the page reference counting is done slightly
differently. No references are held by the network stack on the struct page (it
is up to the caller to manage this as necessary) instead the network stack will
track references via the count embedded in the destructor structure. When this
reference count reaches zero then the destructor will be called and the caller
can take the necesary steps to release the page (i.e. release the struct page
reference itself).

The intention is that callers can use this callback to delay completion to
_their_ callers until the network stack has completely released the page, in
order to prevent use-after-free or modification of data pages which are still
in use by the stack.

It is allowable (indeed expected) for a caller to share a single destructor
instance between multiple pages injected into the stack e.g. a group of pages
included in a single higher level operation might share a destructor which is
used to complete that higher level operation.

NB: a small number of drivers use skb_frag_t independently of struct sk_buff so
this patch is slightly larger than necessary. I did consider leaving skb_frag_t
alone and defining a new (but similar) structure to be used in the struct
sk_buff itself. This would also have the advantage of more clearly separating
the two uses, which is useful since there are now special reference counting
accessors for skb_frag_t within a struct sk_buff but not (necessarily) for
those used outside of an skb.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/cxgb4/sge.c       |   14 +++++++-------
 drivers/net/cxgb4vf/sge.c     |   18 +++++++++---------
 drivers/net/mlx4/en_rx.c      |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c |    2 +-
 include/linux/skbuff.h        |   31 ++++++++++++++++++++++++++-----
 net/core/skbuff.c             |   17 +++++++++++++++++
 6 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index f1813b5..3e7c4b3 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1416,7 +1416,7 @@ static inline void copy_frags(struct sk_buff *skb,
 	unsigned int n;
 
 	/* usually there's just one frag */
-	skb_frag_set_page(skb, 0, gl->frags[0].page);
+	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
 	ssi->frags[0].page_offset = gl->frags[0].page_offset + offset;
 	ssi->frags[0].size = gl->frags[0].size - offset;
 	ssi->nr_frags = gl->nfrags;
@@ -1425,7 +1425,7 @@ static inline void copy_frags(struct sk_buff *skb,
 		memcpy(&ssi->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
 
 	/* get a reference to the last page, we don't own it */
-	get_page(gl->frags[n].page);
+	get_page(gl->frags[n].page.p);	/* XXX */
 }
 
 /**
@@ -1482,7 +1482,7 @@ static void t4_pktgl_free(const struct pkt_gl *gl)
 	const skb_frag_t *p;
 
 	for (p = gl->frags, n = gl->nfrags - 1; n--; p++)
-		put_page(p->page);
+		put_page(p->page.p); /* XXX */
 }
 
 /*
@@ -1635,7 +1635,7 @@ static void restore_rx_bufs(const struct pkt_gl *si, struct sge_fl *q,
 		else
 			q->cidx--;
 		d = &q->sdesc[q->cidx];
-		d->page = si->frags[frags].page;
+		d->page = si->frags[frags].page.p; /* XXX */
 		d->dma_addr |= RX_UNMAPPED_BUF;
 		q->avail++;
 	}
@@ -1717,7 +1717,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 			for (frags = 0, fp = si.frags; ; frags++, fp++) {
 				rsd = &rxq->fl.sdesc[rxq->fl.cidx];
 				bufsz = get_buf_size(rsd);
-				fp->page = rsd->page;
+				fp->page.p = rsd->page; /* XXX */
 				fp->page_offset = q->offset;
 				fp->size = min(bufsz, len);
 				len -= fp->size;
@@ -1734,8 +1734,8 @@ static int process_responses(struct sge_rspq *q, int budget)
 						get_buf_addr(rsd),
 						fp->size, DMA_FROM_DEVICE);
 
-			si.va = page_address(si.frags[0].page) +
-				si.frags[0].page_offset;
+			si.va = page_address(si.frags[0].page.p) +
+				si.frags[0].page_offset; /* XXX */
 
 			prefetch(si.va);
 
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index f4c4480..0a0dda1 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1397,7 +1397,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
 
 		ssi = skb_shinfo(skb);
-		skb_frag_set_page(skb, 0, gl->frags[0].page);
+		skb_frag_set_page(skb, 0, gl->frags[0].page.p); /* XXX */
 		ssi->frags[0].page_offset = gl->frags[0].page_offset + pull_len;
 		ssi->frags[0].size = gl->frags[0].size - pull_len;
 		if (gl->nfrags > 1)
@@ -1410,7 +1410,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
 		skb->truesize += skb->data_len;
 
 		/* Get a reference for the last page, we don't own it */
-		get_page(gl->frags[gl->nfrags - 1].page);
+		get_page(gl->frags[gl->nfrags - 1].page.p); /* XXX */
 	}
 
 out:
@@ -1430,7 +1430,7 @@ void t4vf_pktgl_free(const struct pkt_gl *gl)
 
 	frag = gl->nfrags - 1;
 	while (frag--)
-		put_page(gl->frags[frag].page);
+		put_page(gl->frags[frag].page.p); /* XXX */
 }
 
 /**
@@ -1450,7 +1450,7 @@ static inline void copy_frags(struct sk_buff *skb,
 	unsigned int n;
 
 	/* usually there's just one frag */
-	skb_frag_set_page(skb, 0, gl->frags[0].page);
+	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
 	si->frags[0].page_offset = gl->frags[0].page_offset + offset;
 	si->frags[0].size = gl->frags[0].size - offset;
 	si->nr_frags = gl->nfrags;
@@ -1460,7 +1460,7 @@ static inline void copy_frags(struct sk_buff *skb,
 		memcpy(&si->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
 
 	/* get a reference to the last page, we don't own it */
-	get_page(gl->frags[n].page);
+	get_page(gl->frags[n].page.p); /* XXX */
 }
 
 /**
@@ -1633,7 +1633,7 @@ static void restore_rx_bufs(const struct pkt_gl *gl, struct sge_fl *fl,
 		else
 			fl->cidx--;
 		sdesc = &fl->sdesc[fl->cidx];
-		sdesc->page = gl->frags[frags].page;
+		sdesc->page = gl->frags[frags].page.p; /* XXX */
 		sdesc->dma_addr |= RX_UNMAPPED_BUF;
 		fl->avail++;
 	}
@@ -1721,7 +1721,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
 				BUG_ON(rxq->fl.avail == 0);
 				sdesc = &rxq->fl.sdesc[rxq->fl.cidx];
 				bufsz = get_buf_size(sdesc);
-				fp->page = sdesc->page;
+				fp->page.p = sdesc->page; /* XXX */
 				fp->page_offset = rspq->offset;
 				fp->size = min(bufsz, len);
 				len -= fp->size;
@@ -1739,8 +1739,8 @@ int process_responses(struct sge_rspq *rspq, int budget)
 			dma_sync_single_for_cpu(rspq->adapter->pdev_dev,
 						get_buf_addr(sdesc),
 						fp->size, DMA_FROM_DEVICE);
-			gl.va = (page_address(gl.frags[0].page) +
-				 gl.frags[0].page_offset);
+			gl.va = (page_address(gl.frags[0].page.p) +
+				 gl.frags[0].page_offset); /* XXX */
 			prefetch(gl.va);
 
 			/*
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 21a89e0..c5d01ce 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -418,7 +418,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 			break;
 
 		/* Save page reference in skb */
-		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page);
+		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page.p); /* XXX */
 		skb_frags_rx[nr].size = skb_frags[nr].size;
 		skb_frags_rx[nr].page_offset = skb_frags[nr].page_offset;
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 949ee48..8d16a74 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1823,7 +1823,7 @@ static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
 				return -EINVAL;
 			}
 
-			frags[i].page = page;
+			frags[i].page.p = page;
 			frags[i].page_offset = sg->offset + sgoffset;
 			frags[i].size = copy;
 			i++;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 982c6a3..99b56e3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -135,8 +135,17 @@ struct sk_buff;
 
 typedef struct skb_frag_struct skb_frag_t;
 
+struct skb_frag_destructor {
+	atomic_t ref;
+	int (*destroy)(void *data);
+	void *data;
+};
+
 struct skb_frag_struct {
-	struct page *page;
+	struct {
+		struct page *p;
+		struct skb_frag_destructor *destructor;
+	} page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
 	__u32 page_offset;
 	__u32 size;
@@ -1129,7 +1138,8 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-	frag->page		  = page;
+	frag->page.p		  = page;
+	frag->page.destructor     = NULL;
 	frag->page_offset	  = off;
 	frag->size		  = size;
 }
@@ -1648,7 +1658,7 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
  */
 static inline struct page *__skb_frag_page(const skb_frag_t *frag)
 {
-	return frag->page;
+	return frag->page.p;
 }
 
 /**
@@ -1659,9 +1669,12 @@ static inline struct page *__skb_frag_page(const skb_frag_t *frag)
  */
 static inline const struct page *skb_frag_page(const skb_frag_t *frag)
 {
-	return frag->page;
+	return frag->page.p;
 }
 
+extern void skb_frag_destructor_ref(struct skb_frag_destructor *destroy);
+extern void skb_frag_destructor_unref(struct skb_frag_destructor *destroy);
+
 /**
  * __skb_frag_ref - take an addition reference on a paged fragment.
  * @frag: the paged fragment
@@ -1670,6 +1683,10 @@ static inline const struct page *skb_frag_page(const skb_frag_t *frag)
  */
 static inline void __skb_frag_ref(skb_frag_t *frag)
 {
+	if (unlikely(frag->page.destructor)) {
+		skb_frag_destructor_ref(frag->page.destructor);
+		return;
+	}
 	get_page(__skb_frag_page(frag));
 }
 
@@ -1693,6 +1710,10 @@ static inline void skb_frag_ref(struct sk_buff *skb, int f)
  */
 static inline void __skb_frag_unref(skb_frag_t *frag)
 {
+	if (unlikely(frag->page.destructor)) {
+		skb_frag_destructor_unref(frag->page.destructor);
+		return;
+	}
 	put_page(__skb_frag_page(frag));
 }
 
@@ -1745,7 +1766,7 @@ static inline void *skb_frag_address_safe(const skb_frag_t *frag)
  */
 static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *page)
 {
-	frag->page = page;
+	frag->page.p = page;
 	__skb_frag_ref(frag);
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2133600..bdc6f6e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -292,6 +292,23 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
 }
 EXPORT_SYMBOL(dev_alloc_skb);
 
+void skb_frag_destructor_ref(struct skb_frag_destructor *destroy)
+{
+	BUG_ON(destroy == NULL);
+	atomic_inc(&destroy->ref);
+}
+EXPORT_SYMBOL(skb_frag_destructor_ref);
+
+void skb_frag_destructor_unref(struct skb_frag_destructor *destroy)
+{
+	if (destroy == NULL)
+		return;
+
+	if (atomic_dec_and_test(&destroy->ref))
+		destroy->destroy(destroy->data);
+}
+EXPORT_SYMBOL(skb_frag_destructor_unref);
+
 static void skb_drop_list(struct sk_buff **listp)
 {
 	struct sk_buff *list = *listp;
-- 
1.7.2.5

