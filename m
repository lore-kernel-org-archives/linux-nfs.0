From: "Arce, Abraham" <x0066660@ti.com>
Subject: RE: NULL Pointer Deference: NFS & Telnet
Date: Wed, 26 May 2010 15:19:07 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
 <1274851741.25136.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"tony@atomide.com" <tony@atomide.com>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
	"Ha, Tristram" <Tristram.Ha@micrel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274851741.25136.16.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Eric, David,

[..]

> > > > -		if (skb_shinfo(skb)->nr_frags) {
> > > > +		if (skb_shinfo(skb)->nr_frags && skb_has_frags(skb)) {
> > > >  			int i;
> > > >  			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> > > >  				put_page(skb_shinfo(skb)->frags[i].page);
> > >
> > > skb_shinfo(skb)->nr_frags counts the number of entries contained
> > > in the skb_shinfo(skb)->frags[] array.
> > >
> > > This has nothing to do with the frag list pointer,
> > > skb_shinfo(skb)->frag_list, which is what skb_has_frags()
> > > tests.
> > >
> > > You've got some kind of memory corruption going on and it
> > > appears to have nothing to do with the code paths you're
> > > playing with here.
> >
> > Do you have any recommendation on debugging technique/tool for this memory
> corruption issue?

[..]

> It seems quite strange. You have a skb->nr_frags > 0 value, but a
> frags[i].page = 0 value
> 
> You might add following function :
> 
> shinfo_check(struct sk_buff *skb)
> {
> 	struct skb_shared_info *shinfo = skb_shinfo(skb);
> 	int i;
> 
> 	WARN_ON(shinfo->nr_frags >= MAX_SKB_FRAGS);
> 	for (i = 0; i < shinfo->nr_frags; i++)
> 		WARN_ON(!shinfo->frags[i].page);
> }
> 
> And call it from various points, to check who corrupts your skb.

By increasing the allocation length of our rx skbuff the corruption issue is fixed... I have increased it by 2... Were we writing outside our boundaries of skb data?

Please let me know about this approach...

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b4fb07a..6da81e1 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -504,7 +504,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
                               ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);

                if (rxlen > 0) {
-                       skb = netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
+                       skb = netdev_alloc_skb(ks->netdev, rxlen + 4 + 8);
                        if (!skb) {

Best Regards
Abraham
