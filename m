Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51147 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454Ab3JJTXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 15:23:16 -0400
Date: Thu, 10 Oct 2013 15:23:15 -0400
To: Simo Sorce <simo@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] svcrpc: fix error-handling on badd gssproxy downcall
Message-ID: <20131010192315.GA7463@fieldses.org>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
 <1381418103-3852-3-git-send-email-bfields@redhat.com>
 <1381419432.2684.15.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381419432.2684.15.camel@willson.li.ssimo.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 10, 2013 at 11:37:12AM -0400, Simo Sorce wrote:
> On Thu, 2013-10-10 at 11:15 -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > For every other problem here we bail out with an error, but here for
> > some reason we're setting a negative cache entry (with, note, an
> > undefined expiry).
> > 
> > It seems simplest just to bail out in the same way as we do in other
> > cases.
> > 
> > Cc: Simo Sorce <simo@redhat.com>
> > Reported-by: Andi Kleen <andi@firstfloor.org>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/svcauth_gss.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > index 09fb638..008cdad 100644
> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > @@ -1167,8 +1167,8 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
> >  	if (!ud->found_creds) {
> >  		/* userspace seem buggy, we should always get at least a
> >  		 * mapping to nobody */
> > -		dprintk("RPC:       No creds found, marking Negative!\n");
> > -		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
> > +		dprintk("RPC:       No creds found!\n");
> > +		goto out;
> >  	} else {
> >  
> >  		/* steal creds */
> 
> IIRC, we are doing this to avoid rapid upcall loops in the kernel, where
> we keep hammering upcalls out and keep getting an error back.

Looks like returning an error instead results in closing the connection
to the client, so, depends how the client replies I guess.

In any case I don't see why we'd treat this particular gss-proxy bug
differently than we would any other (like, say, passing down bad xdr, or
a gss context that we can't import).

--b.

> I am not sure it is wise to not set a temp negative cache here.
