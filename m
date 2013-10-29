Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40834 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab3J2PEQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 11:04:16 -0400
Date: Tue, 29 Oct 2013 11:04:14 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] nfsd4: need to destroy revoked delegations in
 destroy_client
Message-ID: <20131029150414.GS31322@fieldses.org>
References: <526F81DE.6060704@primarydata.com>
 <1383039552-27209-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1383039552-27209-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whoops, yes, looks like a good fix.

I'm not convinced of the need for the recall_lock here for reasons given
before.  Could you just drop the recall_lock here and resend?

--b.

On Tue, Oct 29, 2013 at 11:39:12AM +0200, Benny Halevy wrote:
> [use list_splice_init]
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a403502..a66b0ad 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1129,6 +1129,13 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>  		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
>  		destroy_delegation(dp);
>  	}
> +	spin_lock(&recall_lock);
> +	list_splice_init(&clp->cl_revoked, &reaplist);
> +	spin_unlock(&recall_lock);
> +	while (!list_empty(&reaplist)) {
> +		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
> +		destroy_revoked_delegation(dp);
> +	}
>  	while (!list_empty(&clp->cl_openowners)) {
>  		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
>  		release_openowner(oo);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
