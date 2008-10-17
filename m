From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NFS:Prevent infinite loop in
	decode_attr_fs_locations.
Date: Fri, 17 Oct 2008 14:53:59 -0400
Message-ID: <20081017185359.GB13791@fieldses.org>
References: <1224267468-775-1-git-send-email-dhildeb@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Dean Hildebrand <dhildeb@us.ibm.com>
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54582 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753342AbYJQSyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:54:06 -0400
In-Reply-To: <1224267468-775-1-git-send-email-dhildeb@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 11:17:47AM -0700, Dean Hildebrand wrote:
> An infinite loop could occur if n > NFS4_FS_LOCATIONS_MAXENTRIES.
> 
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> ---
>  fs/nfs/nfs4xdr.c |   14 ++++++++++++--
>  1 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index b916297..5e59481 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2577,6 +2577,16 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
>  	READ32(n);
>  	if (n <= 0)
>  		goto out_eio;
> +
> +	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
> +		dprintk("%s: using first %u of %d fs locations\n",
> +			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, n);
> +		n = NFS4_FS_LOCATIONS_MAXENTRIES;
> +	} else {
> +		dprintk("%s: using %d fs locations\n",
> +			__func__, n);
> +	}

I think the first case is the interesting one, so I'd drop the else
clause.

Looks fine otherwise.

The inner loop has the same problem, I assume.

--b.

> +
>  	res->nlocations = 0;
>  	while (res->nlocations < n) {
>  		u32 m;
> @@ -2614,8 +2624,8 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
>  		status = decode_pathname(xdr, &loc->rootpath);
>  		if (unlikely(status != 0))
>  			goto out_eio;
> -		if (res->nlocations < NFS4_FS_LOCATIONS_MAXENTRIES)
> -			res->nlocations++;
> +
> +		res->nlocations++;
>  	}
>  out:
>  	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
> -- 
> 1.5.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
