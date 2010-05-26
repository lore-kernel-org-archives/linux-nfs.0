Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58839 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab0EZUtA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 16:49:00 -0400
Subject: RE: NULL Pointer Deference: NFS & Telnet
From: Eric Dumazet <eric.dumazet@gmail.com>
To: "Arce, Abraham" <x0066660@ti.com>
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        "tony@atomide.com" <tony@atomide.com>,
        "Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
        "Ha, Tristram" <Tristram.Ha@micrel.com>
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
	 <1274851741.25136.16.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 May 2010 22:48:53 +0200
Message-ID: <1274906933.2542.17.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le mercredi 26 mai 2010 à 15:19 -0500, Arce, Abraham a écrit :

> By increasing the allocation length of our rx skbuff the corruption issue is fixed... I have increased it by 2... Were we writing outside our boundaries of skb data?
> 
> Please let me know about this approach...
> 
> diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
> index b4fb07a..6da81e1 100644
> --- a/drivers/net/ks8851.c
> +++ b/drivers/net/ks8851.c
> @@ -504,7 +504,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
>                                ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);
> 
>                 if (rxlen > 0) {
> -                       skb = netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
> +                       skb = netdev_alloc_skb(ks->netdev, rxlen + 4 + 8);
>                         if (!skb) {
> 
> Best Regards
> Abraham
> 

Yes that makes sense, nr_frag is right after the packet (padded to L1
cache size)

But please do the correct allocation ?

Also, we dont need FCS ?

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b4fb07a..05bd312 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -503,8 +503,9 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 		ks8851_wrreg16(ks, KS_RXQCR,
 			       ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);
 
-		if (rxlen > 0) {
-			skb = netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
+		if (rxlen > 4) {
+			rxlen -= 4;
+			skb = netdev_alloc_skb(ks->netdev, 2 + 8 + ALIGN(rxlen, 4));
 			if (!skb) {
 				/* todo - dump frame and move on */
 			}
@@ -513,7 +514,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 			 * for the status header and 4 bytes of garbage */
 			skb_reserve(skb, 2 + 4 + 4);
 
-			rxpkt = skb_put(skb, rxlen - 4) - 8;
+			rxpkt = skb_put(skb, rxlen) - 8;
 
 			/* align the packet length to 4 bytes, and add 4 bytes
 			 * as we're getting the rx status header as well */
@@ -526,7 +527,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 			netif_rx(skb);
 
 			ks->netdev->stats.rx_packets++;
-			ks->netdev->stats.rx_bytes += rxlen - 4;
+			ks->netdev->stats.rx_bytes += rxlen;
 		}
 
 		ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);


