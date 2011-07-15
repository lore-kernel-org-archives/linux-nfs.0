Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32675 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab1GOLQt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 07:16:49 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
CC: linux-nfs@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 05/10] net: convert protocols to SKB frag APIs
Date: Fri, 15 Jul 2011 12:07:06 +0100
Message-ID: <1310728031-19569-5-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NB: should likely be split into per-protocol patches.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 net/ipv4/inet_lro.c    |    2 +-
 net/ipv4/ip_output.c   |    8 +++++---
 net/ipv4/tcp.c         |    3 ++-
 net/ipv4/tcp_output.c  |    2 +-
 net/ipv6/ip6_output.c  |    8 +++++---
 net/xfrm/xfrm_ipcomp.c |   11 +++++++----
 6 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 85a0f75..63f3def 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -449,7 +449,7 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 	if (!lro_mgr->get_frag_header ||
 	    lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
 				     (void *)&tcph, &flags, priv)) {
-		mac_hdr = page_address(frags->page) + frags->page_offset;
+		mac_hdr = skb_frag_address(frags);
 		goto out1;
 	}
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a8024ea..29941ec 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -985,14 +985,14 @@ alloc_new_skb:
 			if (page && (left = PAGE_SIZE - off) > 0) {
 				if (copy >= left)
 					copy = left;
-				if (page != frag->page) {
+				if (page != skb_frag_page(frag)) {
 					if (i == MAX_SKB_FRAGS) {
 						err = -EMSGSIZE;
 						goto error;
 					}
-					get_page(page);
 					skb_fill_page_desc(skb, i, page, off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
+					__skb_frag_ref(frag);
 				}
 			} else if (i < MAX_SKB_FRAGS) {
 				if (copy > PAGE_SIZE)
@@ -1005,13 +1005,15 @@ alloc_new_skb:
 				cork->page = page;
 				cork->off = 0;
 
+				/* XXX no ref ? */
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
 			} else {
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from, skb_frag_address(frag)+frag->size,
+				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 054a59d..3a3703c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3035,7 +3035,8 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 
 	for (i = 0; i < shi->nr_frags; ++i) {
 		const struct skb_frag_struct *f = &shi->frags[i];
-		sg_set_page(&sg, f->page, f->size, f->page_offset);
+		struct page *page = __skb_frag_page(f); /* XXX */
+		sg_set_page(&sg, page, f->size, f->page_offset);
 		if (crypto_hash_update(desc, &sg, f->size))
 			return 1;
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 882e0b0..0377c06 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1095,7 +1095,7 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
 	k = 0;
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <= eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_unref(skb, i);
 			eat -= skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9d4b165..fdd4f61 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1441,14 +1441,14 @@ alloc_new_skb:
 			if (page && (left = PAGE_SIZE - off) > 0) {
 				if (copy >= left)
 					copy = left;
-				if (page != frag->page) {
+				if (page != skb_frag_page(frag)) {
 					if (i == MAX_SKB_FRAGS) {
 						err = -EMSGSIZE;
 						goto error;
 					}
-					get_page(page);
 					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
 					frag = &skb_shinfo(skb)->frags[i];
+					__skb_frag_ref(frag);
 				}
 			} else if(i < MAX_SKB_FRAGS) {
 				if (copy > PAGE_SIZE)
@@ -1461,13 +1461,15 @@ alloc_new_skb:
 				sk->sk_sndmsg_page = page;
 				sk->sk_sndmsg_off = 0;
 
+				/* XXX no ref ? */
 				skb_fill_page_desc(skb, i, page, 0, 0);
 				frag = &skb_shinfo(skb)->frags[i];
 			} else {
 				err = -EMSGSIZE;
 				goto error;
 			}
-			if (getfrag(from, page_address(frag->page)+frag->page_offset+frag->size, offset, copy, skb->len, skb) < 0) {
+			if (getfrag(from, skb_frag_address(frag)+frag->size,
+				    offset, copy, skb->len, skb) < 0) {
 				err = -EFAULT;
 				goto error;
 			}
diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index fc91ad7..f781b9a 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -70,26 +70,29 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 
 	while ((scratch += len, dlen -= len) > 0) {
 		skb_frag_t *frag;
+		struct page *page;
 
 		err = -EMSGSIZE;
 		if (WARN_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS))
 			goto out;
 
 		frag = skb_shinfo(skb)->frags + skb_shinfo(skb)->nr_frags;
-		frag->page = alloc_page(GFP_ATOMIC);
+		page = alloc_page(GFP_ATOMIC);
 
 		err = -ENOMEM;
-		if (!frag->page)
+		if (!page)
 			goto out;
 
+		__skb_frag_set_page(frag, page);
+
 		len = PAGE_SIZE;
 		if (dlen < len)
 			len = dlen;
 
-		memcpy(page_address(frag->page), scratch, len);
-
 		frag->page_offset = 0;
 		frag->size = len;
+		memcpy(skb_frag_address(frag), scratch, len);
+
 		skb->truesize += len;
 		skb->data_len += len;
 		skb->len += len;
-- 
1.7.2.5

