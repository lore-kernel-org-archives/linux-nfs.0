From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: IS_ERR/PTR_ERR confusion
Date: Mon, 7 Dec 2009 18:07:26 -0500
Message-ID: <20091207230726.GA4685@fieldses.org>
References: <4B1CE844.1040108@gmail.com> <20091207152654.GA29416@fieldses.org> <1260227059.2951.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Roel Kluin <roel.kluin@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49625 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935688AbZLGXHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 18:07:19 -0500
In-Reply-To: <1260227059.2951.13.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2009 at 06:04:19PM -0500, Trond Myklebust wrote:
> On Mon, 2009-12-07 at 10:26 -0500, J. Bruce Fields wrote: 
> > On Mon, Dec 07, 2009 at 12:34:28PM +0100, Roel Kluin wrote:
> > > IS_ERR returns 1 or 0, PTR_ERR returns the error value.
> > 
> > Whoops, thanks, looks like that was my mistake, from
> > 79a3f20b641f9f93787ada49d1d7cfa98ee5a11e "rpc: use count of pipe openers
> > to wait for first open".
> 
> Are you planning on shepherding this fix into mainline, or should I?

I don't care, but I think of that as client-side code, so I'm assuming
you're taking it.

--b.
