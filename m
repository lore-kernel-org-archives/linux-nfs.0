Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:28550 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab1GVOQH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 10:16:07 -0400
Subject: Re: [PATCH 08/13] net: convert drivers to paged frag API.
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chas Williams <chas@cmf.nrl.navy.mil>,
        <linux-atm-general@lists.sourceforge.net>
In-Reply-To: <20110722.071217.607687554920673786.davem@davemloft.net>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <1311340653-19336-8-git-send-email-ian.campbell@citrix.com>
	 <20110722.071217.607687554920673786.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jul 2011 15:16:04 +0100
Message-ID: <1311344164.12772.78.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-22 at 15:12 +0100, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Fri, 22 Jul 2011 14:17:28 +0100
> 
> > -				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
> > -				    skb_shinfo(skb)->frags[i].page + skb_shinfo(skb)->frags[i].page_offset,
> > +				put_dma(tx->index,eni_dev->dma,&j,
> > +				    (unsigned long)skb_frag_address(&skb_shinfo(skb)->frags[i]),
> 
> This is not an equivalent transformation.
> 
> skb_frag_address() does a page_address() on the frag page, but that is
> not what the code was doing here previously.
> 
> It's possible the code was buggy, but you can't do a fix like that
> amidst what is supposed to be a semantically NOP transformation.

Ouch, you are absolutely right, I didn't spot that, sorry.

The original code does look pretty bogus though, indexing off a struct
page * like that -- CC'ing the ATM maintainer + list.

Ian.

