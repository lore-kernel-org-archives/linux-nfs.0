Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932370Ab1INMXT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 08:23:19 -0400
Date: Wed, 14 Sep 2011 08:23:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>, Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] SUNRPC: compare scopeid for link-local addresses
Message-ID: <20110914122318.GB3435@fieldses.org>
References: <4E5CABE9.5090401@cn.fujitsu.com>
 <4E6F0A14.1050103@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E6F0A14.1050103@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 13, 2011 at 03:45:24PM +0800, Mi Jinlong wrote:
> Hi guys:
> 
>   What's the situation about those two paths?

Apologies for the delay; both look reasonable to me, thanks.  Applying
for 3.2.  (May be a few days before I push it out to my public tree.)

--b.

> 
> 
> thanks,
> Mi Jinlong
> 
> Mi Jinlong:
> > For ipv6 link-local addresses, sunrpc do not compare those scope id.
> > This patch let sunrpc compares scope id only on link-local addresses.
> > 
> > Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> > ---
> >  include/linux/sunrpc/clnt.h |    8 +++++++-
> >  1 files changed, 7 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> > index db7bcaf..ee1bb67 100644
> > --- a/include/linux/sunrpc/clnt.h
> > +++ b/include/linux/sunrpc/clnt.h
> > @@ -218,7 +218,13 @@ static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
> >  {
> >  	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
> >  	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
> > -	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
> > +
> > +	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
> > +		return false;
> > +	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> > +		return sin1->sin6_scope_id == sin2->sin6_scope_id;
> > +
> > +	return true;
> >  }
> >  
> >  static inline bool __rpc_copy_addr6(struct sockaddr *dst,
> 
