From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/6] SUNRPC: Fix a bug in rpcauth_lookup_credcache()
Date: Fri, 28 Mar 2008 15:08:53 -0400
Message-ID: <1206731334.15567.5.camel@heimdal.trondhjem.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080313174806.13840.26367.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080328151249.GA30169@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35316 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968AbYC1TJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 15:09:01 -0400
In-Reply-To: <20080328151249.GA30169@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-28 at 11:12 -0400, J. Bruce Fields wrote:
> Sorry for the delayed response--I read over these offline and them
> forgot about them....:
> 
> On Thu, Mar 13, 2008 at 01:48:07PM -0400, Trond Myklebust wrote:
> > The hash bucket is for some reason always being set to zero.
> 
> The changelog seems out of sync with the code; nr is normally set a
> little lower to the low bits of acred->uid:
> 
> ...
> > @@ -280,7 +281,9 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
> >  	struct hlist_node *pos;
> >  	struct rpc_cred	*cred = NULL,
> >  			*entry, *new;
> > -	int		nr = 0;
> > +	unsigned int nr;
> > +
> > +	nr = hash_long(acred->uid, RPC_CREDCACHE_HASHBITS);
> >  
> >  	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS))
> >  		nr = acred->uid & RPC_CREDCACHE_MASK;
> 
> So what you're really doing is switching to a better hash fn.  (Except
> that the result is being overwritten immediately afterwards in the
> !RPCAUTH_LOOKUP_ROOTRCREDS case.)
> 
> Wouldn't it have made more sense to replace the existing assignment,
> then remove just make it unconditional in next patch?

Originally I developed the second patch first, then added this one.
After a spot of re-ordering, I got confused.

The end result is correct, though, and git bisection will not be broken,
so I figure we might as well keep it rather than rebuilding the git
trees...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
