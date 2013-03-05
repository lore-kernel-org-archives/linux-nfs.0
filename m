Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35256 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755197Ab3CEWbp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 17:31:45 -0500
Date: Tue, 5 Mar 2013 17:31:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        jackm@dev.mellanox.co.il, ogerlitz@mellanox.com,
        roland@purestorage.com, dan.magenheimer@oracle.com,
        gregkh@linuxfoundation.org, vjaquez@igalia.com, rene.sapiens@ti.com,
        x0095078@ti.com, omar.ramirez@ti.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] nfsd: convert to idr_alloc()
Message-ID: <20130305223135.GI15816@fieldses.org>
References: <1362513772-15174-1-git-send-email-tj@kernel.org>
 <1362513772-15174-3-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362513772-15174-3-git-send-email-tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 05, 2013 at 12:02:47PM -0800, Tejun Heo wrote:
> idr_get_new*() and friends are about to be deprecated.  Convert to the
> new idr_alloc() interface.
> 
> Only compile-tested.

Runs fine too--thanks.

Acked-by: J. Bruce Fields <bfields@redhat.com>

--b.

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> ---
>  fs/nfsd/nfs4state.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d91d6db..2e27430 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -242,9 +242,8 @@ kmem_cache *slab)
>  	if (!stid)
>  		return NULL;
>  
> -	if (!idr_pre_get(stateids, GFP_KERNEL))
> -		goto out_free;
> -	if (idr_get_new_above(stateids, stid, min_stateid, &new_id))
> +	new_id = idr_alloc(stateids, stid, min_stateid, 0, GFP_KERNEL);
> +	if (new_id < 0)
>  		goto out_free;
>  	stid->sc_client = cl;
>  	stid->sc_type = 0;
> -- 
> 1.8.1.4
> 
