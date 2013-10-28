Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50881 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833Ab3J1Tn2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 15:43:28 -0400
Date: Mon, 28 Oct 2013 15:43:26 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: nfs4_free_stid
Message-ID: <20131028194326.GI31322@fieldses.org>
References: <1381730691-18105-1-git-send-email-bhalevy@primarydata.com>
 <1381747492-14026-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381747492-14026-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 14, 2013 at 01:44:52PM +0300, Benny Halevy wrote:
> Make it symmetric to nfs4_alloc_stid.

OK, applying.--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 06984e3..64c167f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -402,11 +402,16 @@ static void remove_stid(struct nfs4_stid *s)
>  	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
>  }
>  
> +static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
> +{
> +	kmem_cache_free(slab, s);
> +}
> +
>  void
>  nfs4_put_delegation(struct nfs4_delegation *dp)
>  {
>  	if (atomic_dec_and_test(&dp->dl_count)) {
> -		kmem_cache_free(deleg_slab, dp);
> +		nfs4_free_stid(deleg_slab, &dp->dl_stid);
>  		num_delegations--;
>  	}
>  }
> @@ -610,7 +615,7 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
>  static void free_generic_stateid(struct nfs4_ol_stateid *stp)
>  {
>  	remove_stid(&stp->st_stid);
> -	kmem_cache_free(stateid_slab, stp);
> +	nfs4_free_stid(stateid_slab, &stp->st_stid);
>  }
>  
>  static void release_lock_stateid(struct nfs4_ol_stateid *stp)
> -- 
> 1.8.3.1
> 
