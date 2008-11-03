From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 12:37:14 -0500
Message-ID: <1225733834.6958.12.camel@heimdal.trondhjem.org>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <20081103172529.GA9008@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47415 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbYKCRhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2008 12:37:21 -0500
In-Reply-To: <20081103172529.GA9008@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-03 at 12:25 -0500, Jim Rees wrote:
> Trond Myklebust wrote:
> 
>   BTW: NFSv4 + soft == BAD BAD BAD!
> 
> Maybe this combination should be prohibited.  Does it make any sense given
> the stateful nature of v4?

It might make sense if we were to fix up the granularity of the recovery
routines so that we are able to recover all the state associated with
just a single open owner or lock owner. Currently we'd have to recover
all the state associated with that server.

IOW: we might be able to fix things up in the future, but right now,
NFSv4+soft is not a good idea.

Trond

