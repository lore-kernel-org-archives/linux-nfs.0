Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:36190 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab1GVNRx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 09:17:53 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Subject: [PATCH 06/13] net: ipv6: convert to SKB frag APIs
Date: Fri, 22 Jul 2011 14:17:26 +0100
Message-ID: <1311340653-19336-6-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
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
Cc: netdev@vger.kernel.org
---
 net/ipv6/ip6_output.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

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
-- 
1.7.2.5

