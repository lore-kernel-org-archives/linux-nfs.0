From: David Miller <davem@davemloft.net>
Subject: Re: NULL Pointer Deference: NFS & Telnet
Date: Tue, 25 May 2010 18:52:36 -0700 (PDT)
Message-ID: <20100525.185236.193707791.davem@davemloft.net>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	<27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-omap@vger.kernel.org,
	tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org, santosh.shilimkar@ti.com
To: x0066660@ti.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52485
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759151Ab0EZBw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 21:52:26 -0400
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6-lTKHBJngVwKIQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Arce, Abraham" <x0066660@ti.com>
Date: Tue, 25 May 2010 20:48:02 -0500

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f8abf68..eb81f76 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -334,7 +334,7 @@ static void skb_release_data(struct sk_buff *skb)
>  	if (!skb->cloned ||
>  	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
>  			       &skb_shinfo(skb)->dataref)) {
> -		if (skb_shinfo(skb)->nr_frags) {
> +		if (skb_shinfo(skb)->nr_frags && skb_has_frags(skb)) {
>  			int i;
>  			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
>  				put_page(skb_shinfo(skb)->frags[i].page);

skb_shinfo(skb)->nr_frags counts the number of entries contained
in the skb_shinfo(skb)->frags[] array.

This has nothing to do with the frag list pointer,
skb_shinfo(skb)->frag_list, which is what skb_has_frags()
tests.

You've got some kind of memory corruption going on and it
appears to have nothing to do with the code paths you're
playing with here.
