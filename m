Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab1GVOMV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 10:12:21 -0400
Date: Fri, 22 Jul 2011 07:12:17 -0700 (PDT)
Message-Id: <20110722.071217.607687554920673786.davem@davemloft.net>
To: ian.campbell@citrix.com
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] net: convert drivers to paged frag API.
From: David Miller <davem@davemloft.net>
In-Reply-To: <1311340653-19336-8-git-send-email-ian.campbell@citrix.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	<1311340653-19336-8-git-send-email-ian.campbell@citrix.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Campbell <ian.campbell@citrix.com>
Date: Fri, 22 Jul 2011 14:17:28 +0100

> -				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
> -				    skb_shinfo(skb)->frags[i].page + skb_shinfo(skb)->frags[i].page_offset,
> +				put_dma(tx->index,eni_dev->dma,&j,
> +				    (unsigned long)skb_frag_address(&skb_shinfo(skb)->frags[i]),

This is not an equivalent transformation.

skb_frag_address() does a page_address() on the frag page, but that is
not what the code was doing here previously.

It's possible the code was buggy, but you can't do a fix like that
amidst what is supposed to be a semantically NOP transformation.
