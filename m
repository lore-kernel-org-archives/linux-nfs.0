From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/22] Don't expect blocksize to always be 8 when
	calculating padding
Date: Mon, 15 Mar 2010 19:38:35 -0400
Message-ID: <20100315233835.GA25710@fieldses.org>
References: <1268655627-18712-1-git-send-email-steved@redhat.com> <1268655627-18712-3-git-send-email-steved@redhat.com> <1268668930.2993.91.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933017Ab0COXhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 19:37:03 -0400
In-Reply-To: <1268668930.2993.91.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 15, 2010 at 12:02:10PM -0400, Trond Myklebust wrote:
> On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
> > From: Kevin Coffman <kwc@citi.umich.edu>
> > 
> > Allow blocksizes other than 8 when calculating padding
> > 
> > Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
> >  1 files changed, 1 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > index a0660f5..4c14b0a 100644
> > --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> > @@ -13,10 +13,7 @@
> >  static inline int
> >  gss_krb5_padding(int blocksize, int length)
> >  {
> > -	/* Most of the code is block-size independent but currently we
> > -	 * use only 8: */
> > -	BUG_ON(blocksize != 8);
> > -	return 8 - (length & 7);
> > +	return blocksize - (length & (blocksize - 1));
> >  }
> >  
> 
> What happens if blocksize is not a power of 2?

It's extremely unlikely we'll care about any blocksize other than 8 or
16 bytes, but may as well make this:

	return blocksize - (length % blocksize)

--b.
