Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51240 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab3LUNdB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Dec 2013 08:33:01 -0500
Date: Sat, 21 Dec 2013 14:32:54 +0100
From: Alexander Aring <alex.aring@gmail.com>
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, werner@almesberger.net
Subject: Re: [PATCH] nfs: fix dead code of ipv6_addr_scope
Message-ID: <20131221133253.GA20745@omega>
References: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
 <20131221124440.GG14073@order.stressinduktion.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20131221124440.GG14073@order.stressinduktion.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Hannes,

On Sat, Dec 21, 2013 at 01:44:40PM +0100, Hannes Frederic Sowa wrote:
> On Sat, Dec 21, 2013 at 05:39:04AM +0100, Alexander Aring wrote:
> > The correct way to check on IPV6_ADDR_SCOPE_LINKLOCAL is to check with
> > the ipv6_addr_src_scope function.
> > 
> > Currently this can't be work, because ipv6_addr_scope returns a int with
> > a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
> > is 0x02. So the condition is always false.
> > 
> > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > ---
> > I think ipv6_addr_src_scope should be correct, can somebody from netdev ml
> > confirm this please?
> > I stumple over that and I did not compile and test it. Maybe this is something
> > for stable?
> > 
> >  fs/nfs/nfs4filelayoutdev.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> > index c7c295e5..efac602 100644
> > --- a/fs/nfs/nfs4filelayoutdev.c
> > +++ b/fs/nfs/nfs4filelayoutdev.c
> > @@ -95,7 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
> >  		b6 = (struct sockaddr_in6 *)addr2;
> >  
> >  		/* LINKLOCAL addresses must have matching scope_id */
> > -		if (ipv6_addr_scope(&a6->sin6_addr) ==
> > +		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
> >  		    IPV6_ADDR_SCOPE_LINKLOCAL &&
> >  		    a6->sin6_scope_id != b6->sin6_scope_id)
> >  			return false;
> 
> Good catch!
> 
thanks.

I am still unsure if sctp is correct or not, I think it isn't correct.
Because we compare and don't check if any bit is set.

We don't use IPV6_ADDR_SCOPE_TYPE here. We use IPV6_ADDR_TYPE. But we can't
compare it.

Current implementation is:

	v6scope = ipv6_addr_scope(&addr->v6.sin6_addr);
        switch (v6scope) {      
        case IFA_HOST:          
                retval = SCTP_SCOPE_LOOPBACK;
                break;
        case IFA_LINK:
                retval = SCTP_SCOPE_LINK;
                break;
        case IFA_SITE:
                retval = SCTP_SCOPE_PRIVATE;
                break;
        default:
                retval = SCTP_SCOPE_GLOBAL;
                break;
        }

and should be something like:

        v6scope = ipv6_addr_src_scope(&addr->v6.sin6_addr);
        switch (v6scope) {      
        case IPV6_ADDR_SCOPE_NODELOCAL:          
                retval = SCTP_SCOPE_LOOPBACK;
                break;
        case IPV6_ADDR_SCOPE_LINKLOCAL:
                retval = SCTP_SCOPE_LINK;
                break;
        case IPV6_ADDR_SCOPE_SITELOCAL:
                retval = SCTP_SCOPE_PRIVATE;
                break;
	case IPV6_ADDR_SCOPE_GLOBAL:
                retval = SCTP_SCOPE_GLOBAL;
		break;
        default:
                retval = SCTP_SCOPE_UNUSABLE;
                break;
        }

Looks this okay for you? Then we can handle SCTP_SCOPE_UNUSABLE, too.

- Alex
