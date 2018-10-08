Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35822 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726078AbeJHVfd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Oct 2018 17:35:33 -0400
Date: Mon, 8 Oct 2018 10:23:35 -0400
From: J Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix up a typo in nfs_dns_ent_put
Message-ID: <20181008142335.GA5567@fieldses.org>
References: <20181005142720.25280-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181005142720.25280-1-trond.myklebust@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 05, 2018 at 10:27:20AM -0400, Trond Myklebust wrote:
> call_rcu() needs to take a first argument of type (struct rcu_head *).
> 
> Fixes: fd497f1e40d9 ("NFS: Lockless DNS lookups")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

Thanks!  Applying.--b.

> ---
> - Apologies for the screwup
> 
>  fs/nfs/dns_resolve.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index e93a5dc07c8c..a7d3df85736d 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -116,7 +116,7 @@ static void nfs_dns_ent_put(struct kref *ref)
>  	struct nfs_dns_ent *item;
>  
>  	item = container_of(ref, struct nfs_dns_ent, h.ref);
> -	call_rcu(item, nfs_dns_ent_free_rcu);
> +	call_rcu(&item->rcu_head, nfs_dns_ent_free_rcu);
>  }
>  
>  static struct cache_head *nfs_dns_ent_alloc(void)
> -- 
> 2.17.1
