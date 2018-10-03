Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57600 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726818AbeJCW75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Oct 2018 18:59:57 -0400
Date: Wed, 3 Oct 2018 12:10:55 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/15] NFS: Lockless DNS lookups
Message-ID: <20181003161055.GF17517@fieldses.org>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181001144157.3515-9-trond.myklebust@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The individual conversions of these caches looks straightforward to me.
Thanks for doing this in these small steps.  I'm assuming you're OK with
these nfs/ changes going through the nfsd tree.

--b.

On Mon, Oct 01, 2018 at 10:41:50AM -0400, Trond Myklebust wrote:
> Enable RCU protected lookup in the legacy DNS resolver.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/dns_resolve.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index 060c658eab66..e93a5dc07c8c 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -65,6 +65,7 @@ struct nfs_dns_ent {
>  
>  	struct sockaddr_storage addr;
>  	size_t addrlen;
> +	struct rcu_head rcu_head;
>  };
>  
>  
> @@ -101,15 +102,23 @@ static void nfs_dns_ent_init(struct cache_head *cnew,
>  	}
>  }
>  
> -static void nfs_dns_ent_put(struct kref *ref)
> +static void nfs_dns_ent_free_rcu(struct rcu_head *head)
>  {
>  	struct nfs_dns_ent *item;
>  
> -	item = container_of(ref, struct nfs_dns_ent, h.ref);
> +	item = container_of(head, struct nfs_dns_ent, rcu_head);
>  	kfree(item->hostname);
>  	kfree(item);
>  }
>  
> +static void nfs_dns_ent_put(struct kref *ref)
> +{
> +	struct nfs_dns_ent *item;
> +
> +	item = container_of(ref, struct nfs_dns_ent, h.ref);
> +	call_rcu(item, nfs_dns_ent_free_rcu);
> +}
> +
>  static struct cache_head *nfs_dns_ent_alloc(void)
>  {
>  	struct nfs_dns_ent *item = kmalloc(sizeof(*item), GFP_KERNEL);
> @@ -195,7 +204,7 @@ static struct nfs_dns_ent *nfs_dns_lookup(struct cache_detail *cd,
>  {
>  	struct cache_head *ch;
>  
> -	ch = sunrpc_cache_lookup(cd,
> +	ch = sunrpc_cache_lookup_rcu(cd,
>  			&key->h,
>  			nfs_dns_hash(key));
>  	if (!ch)
> -- 
> 2.17.1
