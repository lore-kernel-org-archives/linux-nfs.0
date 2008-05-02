From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] [stable 2.6.24] Fix oops at
	rpcb_getport_async in sunrpc
Date: Fri, 2 May 2008 13:27:03 -0700
Message-ID: <20080502202703.GB11135@kroah.com>
References: <8408c1a50805021307x2f1843ffrfb53efbbfaf8aaba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, linux-nfs@vger.kernel.org
To: HIRANO Takahito <hiranotaka-FWFpUBK1X0Y@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40033 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbYECXDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 May 2008 19:03:22 -0400
In-Reply-To: <8408c1a50805021307x2f1843ffrfb53efbbfaf8aaba-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 03, 2008 at 05:07:21AM +0900, HIRANO Takahito wrote:
> The rpcb_getport_async in the sunrpc module copies larger memory area than
> the allocated. Because of this problem, NFS users might encounter oops.
> 
> This problem only exists in 2.6.24.y.
> It is fixed in 2.6.25 by the commit 86d61d8638ddf9cdf87df26c7fa69b2804425fbe.

The 2.6.24.y kernel tree is pretty much "closed" now, we don't want to
do any more releases of it, so I'm not going to add this to any queue,
sorry.

thanks,

greg k-h
