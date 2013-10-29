Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33357 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754041Ab3J2P7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 11:59:07 -0400
Date: Tue, 29 Oct 2013 11:59:07 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] nfsd4: move nfs4_put_file from unhash to put
 delegation
Message-ID: <20131029155906.GV31322@fieldses.org>
References: <526F81DE.6060704@primarydata.com>
 <1383039572-27405-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1383039572-27405-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 11:39:32AM +0200, Benny Halevy wrote:
> revoked delegations are unhashed but are kept around in nfsv4.1	and we better
> hang on to dp_file in this case.

I don't agree: we shouldn't need dl_file any more once the delegation is
revoked.  It exists only to process delegreturns and set
SEQ4_STATUS_RECALLABLE_STATE_REVOKED.

If some other code (like delegreturn) *is* attempting to use dl_file on
revoked delegation, then that sounds like a delegreturn bug.

Among other things I think we'd like to be able to free up the reference
and deallocate the file on disk if necessary once the delegation has
been revoked.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 8840206..7f78ff5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -411,6 +411,8 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>  {
>  	remove_stid(&dp->dl_stid);
>  	if (atomic_dec_and_test(&dp->dl_count)) {
> +		if (dp->dl_file)
> +			put_nfs4_file(dp->dl_file);
>  		nfs4_free_stid(deleg_slab, &dp->dl_stid);
>  		num_delegations--;
>  	}
> @@ -450,8 +452,6 @@ static void unhash_stid(struct nfs4_stid *s)
>  	dp->dl_stid.sc_type = 0;
>  	nfs4_put_deleg_lease(dp->dl_file);
>  	spin_unlock(&recall_lock);
> -	put_nfs4_file(dp->dl_file);
> -	dp->dl_file = NULL;
>  }
>  
>  
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
