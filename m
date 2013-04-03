Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33666 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763172Ab3DCTYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 15:24:32 -0400
Date: Wed, 3 Apr 2013 15:24:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, tj@kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 4/6] nfsd: convert nfs4_alloc_stid to use
 idr_alloc_cyclic
Message-ID: <20130403192429.GI6044@fieldses.org>
References: <1364412578-7462-1-git-send-email-jlayton@redhat.com>
 <1364412578-7462-5-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364412578-7462-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Err, and ack v2.--b.

On Wed, Mar 27, 2013 at 03:29:36PM -0400, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> ---
>  fs/nfsd/nfs4state.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e27430..417c848 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -234,7 +234,6 @@ static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
>  kmem_cache *slab)
>  {
>  	struct idr *stateids = &cl->cl_stateids;
> -	static int min_stateid = 0;
>  	struct nfs4_stid *stid;
>  	int new_id;
>  
> @@ -242,7 +241,7 @@ kmem_cache *slab)
>  	if (!stid)
>  		return NULL;
>  
> -	new_id = idr_alloc(stateids, stid, min_stateid, 0, GFP_KERNEL);
> +	new_id = idr_alloc_cyclic(stateids, stid, 0, 0, GFP_KERNEL);
>  	if (new_id < 0)
>  		goto out_free;
>  	stid->sc_client = cl;
> @@ -261,10 +260,6 @@ kmem_cache *slab)
>  	 * amount of time until an id is reused, by ensuring they always
>  	 * "increase" (mod INT_MAX):
>  	 */
> -
> -	min_stateid = new_id+1;
> -	if (min_stateid == INT_MAX)
> -		min_stateid = 0;
>  	return stid;
>  out_free:
>  	kfree(stid);
> -- 
> 1.7.11.7
> 
