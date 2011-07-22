Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23028 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349Ab1GVNSF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 09:18:05 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 11/13] net: only allow paged fragments with the same destructor to be coalesced.
Date: Fri, 22 Jul 2011 14:17:31 +0100
Message-ID: <1311340653-19336-11-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Michał Mirosław" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |    7 +++++--
 net/core/skbuff.c      |    1 +
 net/ipv4/ip_output.c   |    2 +-
 net/ipv4/tcp.c         |    2 +-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index faee8d3..fb64a0e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1931,13 +1931,16 @@ static inline int skb_add_data(struct sk_buff *skb,
 }
 
 static inline int skb_can_coalesce(struct sk_buff *skb, int i,
-				   const struct page *page, int off)
+				   const struct page *page,
+				   const struct skb_frag_destructor *destroy,
+				   int off)
 {
 	if (i) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i - 1];
 
 		return page == skb_frag_page(frag) &&
-		       off == frag->page_offset + frag->size;
+		       off == frag->page_offset + frag->size &&
+		       frag->page.destructor == destroy;
 	}
 	return 0;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 101c9cc..3d89b1a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2152,6 +2152,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 	 */
 	if (!to ||
 	    !skb_can_coalesce(tgt, to, skb_frag_page(fragfrom),
+			      fragfrom->page.destructor,
 			      fragfrom->page_offset)) {
 		merge = -1;
 	} else {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 5946de2..c4326fb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1224,7 +1224,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		i = skb_shinfo(skb)->nr_frags;
 		if (len > size)
 			len = size;
-		if (skb_can_coalesce(skb, i, page, offset)) {
+		if (skb_can_coalesce(skb, i, page, NULL, offset)) {
 			skb_shinfo(skb)->frags[i-1].size += len;
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2f0e985..a1a0ccd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1008,7 +1008,7 @@ new_segment:
 				struct page *page = TCP_PAGE(sk);
 				int off = TCP_OFF(sk);
 
-				if (skb_can_coalesce(skb, i, page, off) &&
+				if (skb_can_coalesce(skb, i, page, NULL, off) &&
 				    off != PAGE_SIZE) {
 					/* We can extend the last page
 					 * fragment. */
-- 
1.7.2.5

