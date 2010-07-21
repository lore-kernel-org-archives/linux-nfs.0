From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] SQUASHME pnfs-submit remove pnfs4_layout_reclaim
Date: Wed, 21 Jul 2010 20:40:06 +0300
Message-ID: <4C4730F6.8000701@panasas.com>
References: <1279723416-4467-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18753 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756887Ab0GURkK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 13:40:10 -0400
In-Reply-To: <1279723416-4467-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 21, 2010, 17:43 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Not used. Destroy all layouts on lease expiration instead.

What do you mean by not used?
You've just deleted two uses in this patch...

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   13 -------------
>  1 files changed, 0 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index fd6438d..05f072c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1094,17 +1094,6 @@ static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *
>  	return ERR_PTR(-ENOENT);
>  }
>  
> -static void pnfs4_layout_reclaim(struct nfs4_state *state)
> -{
> -#if defined(CONFIG_NFS_V4_1)
> -	/* FIXME: send gratuitous layout commits and return with the reclaim
> -	 * flag during grace period
> -	 */
> -	pnfs_destroy_layout(NFS_I(state->inode));
> -	pnfs_set_layout_stateid(NFS_I(state->inode)->layout, &zero_stateid);
> -#endif /* CONFIG_NFS_V4_1 */
> -}
> -
>  static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context *ctx, struct nfs4_state *state)
>  {
>  	struct nfs4_opendata *opendata;
> @@ -1181,7 +1170,6 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
>  			       sizeof(state->stateid.u.data));
>  		write_sequnlock(&state->seqlock);
>  	}
> -	pnfs4_layout_reclaim(state);
>  	return 0;
>  }
>  
> @@ -1236,7 +1224,6 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
>  		return PTR_ERR(ctx);
>  	ret = nfs4_do_open_reclaim(ctx, state);
>  	put_nfs_open_context(ctx);
> -	pnfs4_layout_reclaim(state);
>  	return ret;
>  }
>  
