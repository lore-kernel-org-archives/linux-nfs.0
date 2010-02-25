From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: allocation under spinlock
Date: Wed, 24 Feb 2010 21:49:15 -0500
Message-ID: <20100225024915.GO16665@fieldses.org>
References: <20100224212358.GH16665@fieldses.org> <1267065109.19857.10.camel@netappnfs60-170.Connectathon.ORG>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53170 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758825Ab0BYCsR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2010 21:48:17 -0500
In-Reply-To: <1267065109.19857.10.camel-UuHi6rWCfGWzdaK+V31Xzzg6DN0g1aqAy1WmG7uI1WA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 24, 2010 at 06:31:49PM -0800, Trond Myklebust wrote:
> On Wed, 2010-02-24 at 16:23 -0500, J. Bruce Fields wrote: 
> > nfs_dns_ent_init() is trying to kstrndup() something, but it's called under a
> > spinlock.
> > 
> > Could refernce count that string instead, but other code I believe actually
> > just does something like:
> > 
> > 	new->hostname = key->hostname;
> > 	key->hostname = NULL;
> > 
> > --b.
> > 
> > BUG: sleeping function called from invalid context at mm/slab.c:3034
> > in_atomic(): 1, irqs_disabled(): 0, pid: 3300, name: nfs_cache_geten
> > 2 locks held by nfs_cache_geten/3300:
> >  #0:  (&sb->s_type->i_mutex_key#4){+.+.+.}, at: [<c1795506>] cache_write+0x46/0x100
> >  #1:  (&cd->hash_lock){+++++.}, at: [<c17964a5>] sunrpc_cache_update+0x25/0x170
> > Pid: 3300, comm: nfs_cache_geten Not tainted 2.6.33-rc8-13669-g724e6d3 #156
> 
> Does the following fix it for you?

No more warning; thanks!

--b.

> 
> Cheers
>   Trond
> ---------------------------------------------------------------------------- 
> NFS: Fix an allocation-under-spinlock bug
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> sunrpc_cache_update() will always call detail->update() from inside the
> detail->hash_lock, so it cannot allocate memory.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@kernel.org
> ---
> 
>  fs/nfs/dns_resolve.c |   18 +++++++++++++++---
>  1 files changed, 15 insertions(+), 3 deletions(-)
> 
> 
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index 95e1ca7..3f0cd4d 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -36,6 +36,19 @@ struct nfs_dns_ent {
>  };
>  
> 
> +static void nfs_dns_ent_update(struct cache_head *cnew,
> +		struct cache_head *ckey)
> +{
> +	struct nfs_dns_ent *new;
> +	struct nfs_dns_ent *key;
> +
> +	new = container_of(cnew, struct nfs_dns_ent, h);
> +	key = container_of(ckey, struct nfs_dns_ent, h);
> +
> +	memcpy(&new->addr, &key->addr, key->addrlen);
> +	new->addrlen = key->addrlen;
> +}
> +
>  static void nfs_dns_ent_init(struct cache_head *cnew,
>  		struct cache_head *ckey)
>  {
> @@ -49,8 +62,7 @@ static void nfs_dns_ent_init(struct cache_head *cnew,
>  	new->hostname = kstrndup(key->hostname, key->namelen, GFP_KERNEL);
>  	if (new->hostname) {
>  		new->namelen = key->namelen;
> -		memcpy(&new->addr, &key->addr, key->addrlen);
> -		new->addrlen = key->addrlen;
> +		nfs_dns_ent_update(cnew, ckey);
>  	} else {
>  		new->namelen = 0;
>  		new->addrlen = 0;
> @@ -234,7 +246,7 @@ static struct cache_detail nfs_dns_resolve = {
>  	.cache_show = nfs_dns_show,
>  	.match = nfs_dns_match,
>  	.init = nfs_dns_ent_init,
> -	.update = nfs_dns_ent_init,
> +	.update = nfs_dns_ent_update,
>  	.alloc = nfs_dns_ent_alloc,
>  };
>  
> 
