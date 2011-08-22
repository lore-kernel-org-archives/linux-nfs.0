Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51310 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108Ab1HVTpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 15:45:03 -0400
Date: Mon, 22 Aug 2011 15:44:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: Add scope id to svc_addr_u for IPv6 LINKLOCAL
 address
Message-ID: <20110822194459.GC16261@fieldses.org>
References: <4E4F8B5D.6060404@cn.fujitsu.com>
 <20110822192620.GB16261@fieldses.org>
 <3CA77E10-4099-4DDB-BE7A-88395CC34C93@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3CA77E10-4099-4DDB-BE7A-88395CC34C93@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 22, 2011 at 03:32:13PM -0400, Chuck Lever wrote:
> 
> On Aug 22, 2011, at 3:26 PM, J. Bruce Fields wrote:
> 
> > On Sat, Aug 20, 2011 at 06:24:29PM +0800, Mi Jinlong wrote:
> >> +/* 
> >> + * Add scope id for LINKLOCAL address
> >> + */
> >> +struct in6_addr_scopeid{
> >> +	struct in6_addr	sin6_addr;
> >> +	__u32		sin6_scope_id;
> >> +};
> >> +
> >> union svc_addr_u {
> >> -    struct in_addr	addr;
> >> -    struct in6_addr	addr6;
> >> +	struct in_addr		addr;
> >> +	struct in6_addr_scopeid	addr6;
> > 
> > By the way, is there any reason why nfsd really needs its own address
> > structure?  Shouldn't we use sockaddr_storage or something?  I feel like
> > we've got a little too much one-off address handling in nfsd.
> 
> That would be my only complaint about the patch.
> 
> I think we chose a smaller struct here to save space, and we could do that because we didn't need a port number or scope ID.  If a scope ID is indeed required, then we should consider something larger like a struct sockaddr_storage, IMO.

If we care about the size of struct svc_rqst: rq_vec and rq_pages fields
are 4k and 2k, respectively, and the rest is lost in the noise.

Mi Jinlong, would you have the time to try this?

	- Replace svc_addr_u by sockaddr_storage
	- See of that allows us to delete some lines of code in nfsd by
	  using standard helper functions instead of copying things by
	  hand.

You'd do that in one patch, then apply your scope-id fix on top of it as
a second patch.

--b.
