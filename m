Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50010 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab3KDWsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 17:48:04 -0500
Date: Mon, 4 Nov 2013 17:47:58 -0500
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove_stid can be incorporated into
 nfs4_put_delegation
Message-ID: <20131104224758.GB8828@fieldses.org>
References: <525CE711.1040107@primarydata.com>
 <1381820280-14120-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381820280-14120-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 09:58:00AM +0300, Benny Halevy wrote:
> All calls to nfs4_put_delegation are preceded with remove_stid.

Whoops, no, we missed the nfs4_put_delegation call in
fs/nfsd/nfs4callback.c.

Noticed because some pynfs tests triggered idr warnings about freeing
the same id twice.

I guess I'll revert.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b8f3c7e..93160b6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -410,6 +410,7 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>  void
>  nfs4_put_delegation(struct nfs4_delegation *dp)
>  {
> +	remove_stid(&dp->dl_stid);
>  	if (atomic_dec_and_test(&dp->dl_count)) {
>  		nfs4_free_stid(deleg_slab, &dp->dl_stid);
>  		num_delegations--;
> @@ -450,14 +451,12 @@ static void unhash_stid(struct nfs4_stid *s)
>  static void destroy_revoked_delegation(struct nfs4_delegation *dp)
>  {
>  	list_del_init(&dp->dl_recall_lru);
> -	remove_stid(&dp->dl_stid);
>  	nfs4_put_delegation(dp);
>  }
>  
>  static void destroy_delegation(struct nfs4_delegation *dp)
>  {
>  	unhash_delegation(dp);
> -	remove_stid(&dp->dl_stid);
>  	nfs4_put_delegation(dp);
>  }
>  
> @@ -3157,7 +3156,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
>  	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
>  	return;
>  out_free:
> -	remove_stid(&dp->dl_stid);
>  	nfs4_put_delegation(dp);
>  out_no_deleg:
>  	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
> -- 
> 1.8.3.1
> 
