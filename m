Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23859 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368Ab1GVNRz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:17:55 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 07/13] net: xfrm: convert to SKB frag APIs
Date: Fri, 22 Jul 2011 14:17:27 +0100
Message-ID: <1311340653-19336-7-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/xfrm/xfrm_ipcomp.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

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

