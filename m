Return-Path: linux-nfs-owner@vger.kernel.org
Received: from order.stressinduktion.org ([87.106.68.36]:45267 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756611Ab3LVCa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Dec 2013 21:30:57 -0500
Date: Sun, 22 Dec 2013 03:30:54 +0100
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexander Aring <alex.aring@gmail.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, werner@almesberger.net
Subject: Re: [PATCH] nfs: fix dead code of ipv6_addr_scope
Message-ID: <20131222023054.GH14073@order.stressinduktion.org>
References: <1387600744-11366-1-git-send-email-alex.aring@gmail.com> <20131221124440.GG14073@order.stressinduktion.org> <20131221133253.GA20745@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20131221133253.GA20745@omega>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 21, 2013 at 02:32:54PM +0100, Alexander Aring wrote:
> Hi Hannes,
> 
> On Sat, Dec 21, 2013 at 01:44:40PM +0100, Hannes Frederic Sowa wrote:
> > On Sat, Dec 21, 2013 at 05:39:04AM +0100, Alexander Aring wrote:
> > > The correct way to check on IPV6_ADDR_SCOPE_LINKLOCAL is to check with
> > > the ipv6_addr_src_scope function.
> > > 
> > > Currently this can't be work, because ipv6_addr_scope returns a int with
> > > a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
> > > is 0x02. So the condition is always false.
> > > 
> > > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > > ---
> > > I think ipv6_addr_src_scope should be correct, can somebody from netdev ml
> > > confirm this please?
> > > I stumple over that and I did not compile and test it. Maybe this is something
> > > for stable?
> > > 
> > >  fs/nfs/nfs4filelayoutdev.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> > > index c7c295e5..efac602 100644
> > > --- a/fs/nfs/nfs4filelayoutdev.c
> > > +++ b/fs/nfs/nfs4filelayoutdev.c
> > > @@ -95,7 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
> > >  		b6 = (struct sockaddr_in6 *)addr2;
> > >  
> > >  		/* LINKLOCAL addresses must have matching scope_id */
> > > -		if (ipv6_addr_scope(&a6->sin6_addr) ==
> > > +		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
> > >  		    IPV6_ADDR_SCOPE_LINKLOCAL &&
> > >  		    a6->sin6_scope_id != b6->sin6_scope_id)
> > >  			return false;
> > 
> > Good catch!
> > 
> thanks.
> 
> I am still unsure if sctp is correct or not, I think it isn't correct.
> Because we compare and don't check if any bit is set.
> 
> We don't use IPV6_ADDR_SCOPE_TYPE here. We use IPV6_ADDR_TYPE. But we can't
> compare it.

Actually, this is fine, too. ipv6_addr_scope does mask the addr_type with
IPV6_ADDR_SCOPE_MASK (which is 0x00f0U). If you look at addrconf_core.c you
see that the 4 bits stand by itself each time.

Actually it seems ipv6_addr_src_scope is better suitable for multicast scope
handling and ipv6_addr_scope with IFA_{HOST,LINK,SITE} is fine for
non-multicast. In this case there is no difference.

Maybe an int ipv6_cmp_sockaddr(struct in6_addr *a1, int scope1,
			  struct in6_addr *a2, int scope2)
or
int ipv6_cmp_sockaddr(struct sockaddr_in6 *s1,
		      struct sockaddr_in6 *s2)

would be nice so we don't need to open code it everywhere.

Greetings,

  Hannes

