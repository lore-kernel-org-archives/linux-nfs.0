Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48848 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448Ab3J1ScQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:32:16 -0400
Date: Mon, 28 Oct 2013 14:32:14 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: no need to unhash_stid before free
Message-ID: <20131028183214.GH31322@fieldses.org>
References: <1381730515-18045-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381730515-18045-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 14, 2013 at 09:01:55AM +0300, Benny Halevy wrote:
> idr_remove is about to be called before kmem_cache_free so unhashing it
> is redundant

This leaves only two unhash_stid callers, in release_lock_stateid and
unhash_stid, both called just before destroying the stateid, so perhaps
we should remove those and unhash_stid?

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0874998..06984e3 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -668,7 +668,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
>  static void release_open_stateid(struct nfs4_ol_stateid *stp)
>  {
>  	unhash_open_stateid(stp);
> -	unhash_stid(&stp->st_stid);
>  	free_generic_stateid(stp);
>  }
>  
> @@ -690,7 +689,6 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
>  	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
>  
>  	if (s) {
> -		unhash_stid(&s->st_stid);
>  		free_generic_stateid(s);
>  		oo->oo_last_closed_stid = NULL;
>  	}
> @@ -3998,10 +3996,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
>  
>  	nfsd4_close_open_stateid(stp);
>  
> -	if (cstate->minorversion) {
> -		unhash_stid(&stp->st_stid);
> +	if (cstate->minorversion)
>  		free_generic_stateid(stp);
> -	} else
> +	else
>  		oo->oo_last_closed_stid = stp;
>  
>  	if (list_empty(&oo->oo_owner.so_stateids)) {
> -- 
> 1.8.3.1
> 
