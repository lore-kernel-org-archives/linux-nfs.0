Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60615 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755336Ab3JJUpz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 16:45:55 -0400
Subject: Re: [PATCH 2/4] svcrpc: fix error-handling on badd gssproxy
 downcall
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20131010192315.GA7463@fieldses.org>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
	 <1381418103-3852-3-git-send-email-bfields@redhat.com>
	 <1381419432.2684.15.camel@willson.li.ssimo.org>
	 <20131010192315.GA7463@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Oct 2013 16:45:52 -0400
Message-ID: <1381437952.2684.64.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-10 at 15:23 -0400, J. Bruce Fields wrote:
> On Thu, Oct 10, 2013 at 11:37:12AM -0400, Simo Sorce wrote:
> > On Thu, 2013-10-10 at 11:15 -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > For every other problem here we bail out with an error, but here for
> > > some reason we're setting a negative cache entry (with, note, an
> > > undefined expiry).
> > > 
> > > It seems simplest just to bail out in the same way as we do in other
> > > cases.
> > > 
> > > Cc: Simo Sorce <simo@redhat.com>
> > > Reported-by: Andi Kleen <andi@firstfloor.org>
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  net/sunrpc/auth_gss/svcauth_gss.c |    4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > > index 09fb638..008cdad 100644
> > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > @@ -1167,8 +1167,8 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
> > >  	if (!ud->found_creds) {
> > >  		/* userspace seem buggy, we should always get at least a
> > >  		 * mapping to nobody */
> > > -		dprintk("RPC:       No creds found, marking Negative!\n");
> > > -		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
> > > +		dprintk("RPC:       No creds found!\n");
> > > +		goto out;
> > >  	} else {
> > >  
> > >  		/* steal creds */
> > 
> > IIRC, we are doing this to avoid rapid upcall loops in the kernel, where
> > we keep hammering upcalls out and keep getting an error back.
> 
> Looks like returning an error instead results in closing the connection
> to the client, so, depends how the client replies I guess.
> 
> In any case I don't see why we'd treat this particular gss-proxy bug
> differently than we would any other (like, say, passing down bad xdr, or
> a gss context that we can't import).

Uhmm I did not recall that, I guess the change is ok then.

Simo.

> --b.
> 
> > I am not sure it is wise to not set a temp negative cache here.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Simo Sorce * Red Hat, Inc * New York

