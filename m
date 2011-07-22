Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:1493 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329Ab1GVNRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:17:46 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 03/13] net: add APIs for manipulating skb page fragments.
Date: Fri, 22 Jul 2011 14:17:23 +0100
Message-ID: <1311340653-19336-3-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The primary aim is to add skb_frag_(ref|unref) in order to remove the use of
bare get/put_page on SKB pages fragments and to isolate users from subsequent
changes to the skb_frag_t data structure.

The API also includes an accessor for the struct page itself. The default
variant of this returns a *const* struct page in an attempt to catch bare uses
of get/put_page (which take a non-const struct page).

Also included are helper APIs for passing a paged fragment to kmap and
dma_map_page since I was seeing the same pattern a lot. A helper for
pci_map_page is ommitted due to Michał Mirosław's recommendation that users
should transition to pci_map_page instead.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Michał Mirosław" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |  204 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 202 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c0a4f3a..f4034af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,8 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/highmem.h>
+#include <linux/pci.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1109,14 +1111,47 @@ static inline int skb_pagelen(const struct sk_buff *skb)
 	return len + skb_headlen(skb);
 }
 
-static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
-				      struct page *page, int off, int size)
+/**
+ * __skb_fill_page_desc - initialise a paged fragment in an skb
+ * @skb: buffer containing fragment to be initialised
+ * @i: paged fragment index to initialise
+ * @page: the page to use for this fragment
+ * @off: the offset to the data with @page
+ * @size: the length of the data
+ *
+ * Initialises the @i'th fragment of @skb to point to &size bytes at
+ * offset @off within @page.
+ *
+ * Does not take any additional reference on the fragment.
+ */
+static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
+					struct page *page, int off, int size)
 {
 	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 	frag->page		  = page;
 	frag->page_offset	  = off;
 	frag->size		  = size;
+}
+
+/**
+ * skb_fill_page_desc - initialise a paged fragment in an skb
+ * @skb: buffer containing fragment to be initialised
+ * @i: paged fragment index to initialise
+ * @page: the page to use for this fragment
+ * @off: the offset to the data with @page
+ * @size: the length of the data
+ *
+ * As per __skb_fill_page_desc() -- initialises the @i'th fragment of
+ * @skb to point to &size bytes at offset @off within @page. In
+ * addition updates @skb such that @i is the last fragment.
+ *
+ * Does not take any additional reference on the fragment.
+ */
+static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
+				      struct page *page, int off, int size)
+{
+	__skb_fill_page_desc(skb, i, page, off, size);
 	skb_shinfo(skb)->nr_frags = i + 1;
 }
 
@@ -1605,6 +1640,171 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
 }
 
 /**
+ * __skb_frag_page - retrieve the page refered to by a paged fragment
+ * @frag: the paged fragment
+ *
+ * Returns the &struct page associated with @frag. Where possible you
+ * should use skb_frag_page() which returns a const &struct page.
+ */
+static inline struct page *__skb_frag_page(const skb_frag_t *frag)
+{
+	return frag->page;
+}
+
+/**
+ * __skb_frag_page - retrieve the page refered to by a paged fragment
+ * @frag: the paged fragment
+ *
+ * Returns the &struct page associated with @frag as a const.
+ */
+static inline const struct page *skb_frag_page(const skb_frag_t *frag)
+{
+	return frag->page;
+}
+
+/**
+ * __skb_frag_ref - take an addition reference on a paged fragment.
+ * @frag: the paged fragment
+ *
+ * Takes an additional reference on the paged fragment @frag.
+ */
+static inline void __skb_frag_ref(skb_frag_t *frag)
+{
+	get_page(__skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_ref - take an addition reference on a paged fragment of an skb.
+ * @skb: the buffer
+ * @f: the fragment offset.
+ *
+ * Takes an additional reference on the @f'th paged fragment of @skb.
+ */
+static inline void skb_frag_ref(struct sk_buff *skb, int f)
+{
+	__skb_frag_ref(&skb_shinfo(skb)->frags[f]);
+}
+
+/**
+ * __skb_frag_unref - release a reference on a paged fragment.
+ * @frag: the paged fragment
+ *
+ * Releases a reference on the paged fragment @frag.
+ */
+static inline void __skb_frag_unref(skb_frag_t *frag)
+{
+	put_page(__skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_unref - release a reference on a paged fragment of an skb.
+ * @skb: the buffer
+ * @f: the fragment offset
+ *
+ * Releases a reference on the @f'th paged fragment of @skb.
+ */
+static inline void skb_frag_unref(struct sk_buff *skb, int f)
+{
+	__skb_frag_unref(&skb_shinfo(skb)->frags[f]);
+}
+
+/**
+ * skb_frag_address - gets the address of the data contained in a paged fragment
+ * @frag: the paged fragment buffer
+ *
+ * Returns the address of the data within @frag. The page must already
+ * be mapped.
+ */
+static inline void *skb_frag_address(const skb_frag_t *frag)
+{
+	return page_address(skb_frag_page(frag)) + frag->page_offset;
+}
+
+/**
+ * skb_frag_address_safe - gets the address of the data contained in a paged fragment
+ * @frag: the paged fragment buffer
+ *
+ * Returns the address of the data within @frag. Checks that the page
+ * is mapped and returns %NULL otherwise.
+ */
+static inline void *skb_frag_address_safe(const skb_frag_t *frag)
+{
+	void *ptr = page_address(skb_frag_page(frag));
+	if (unlikely(!ptr))
+		return NULL;
+
+	return ptr + frag->page_offset;
+}
+
+/**
+ * __skb_frag_set_page - sets the page contained in a paged fragment
+ * @frag: the paged fragment
+ * @page: the page to set
+ *
+ * Sets the fragment @frag to contain @page.
+ */
+static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *page)
+{
+	frag->page = page;
+	__skb_frag_ref(frag);
+}
+
+/**
+ * skb_frag_set_page - sets the page contained in a paged fragment of an skb
+ * @skb: the buffer
+ * @f: the fragment offset
+ * @page: the page to set
+ *
+ * Sets the @f'th fragment of @skb to contain @page.
+ */
+static inline void skb_frag_set_page(struct sk_buff *skb, int f,
+				     struct page *page)
+{
+	__skb_frag_set_page(&skb_shinfo(skb)->frags[f], page);
+}
+
+/**
+ * skb_frag_kmap - kmaps a paged fragment
+ * @frag: the paged fragment
+ *
+ * kmap()s the paged fragment @frag and returns the virtual address.
+ */
+static inline void *skb_frag_kmap(skb_frag_t *frag)
+{
+	return kmap(__skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_kmap - kunmaps a paged fragment
+ * @frag: the paged fragment
+ *
+ * kunmap()s the paged fragment @frag.
+ */
+static inline void skb_frag_kunmap(skb_frag_t *frag)
+{
+	kunmap(__skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_dma_map - maps a paged fragment via the DMA API
+ * @device: the device to map the fragment to
+ * @frag: the paged fragment to map
+ * @offset: the offset within the fragment (starting at the fragments own offset)
+ * @size: the number of bytes to map
+ * @direction: the direction of the mapping (%PCI_DMA_*)
+ *
+ * Maps the page associated with @frag to @device.
+ */
+static inline dma_addr_t skb_frag_dma_map(struct device *dev,
+					  const skb_frag_t *frag,
+					  size_t offset, size_t size,
+					  enum dma_data_direction dir)
+{
+	return dma_map_page(dev, __skb_frag_page(frag),
+			    frag->page_offset + offset, size, dir);
+}
+
+/**
  *	skb_clone_writable - is the header of a clone writable
  *	@skb: buffer to check
  *	@len: length up to which to write
-- 
1.7.2.5

