Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59932 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932840Ab3DKOmX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Apr 2013 10:42:23 -0400
Date: Thu, 11 Apr 2013 10:42:20 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: fanchaoting <tingchaofan@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: remove some useless code
Message-ID: <20130411144220.GF7081@fieldses.org>
References: <5163AFED.5060902@cn.fujitsu.com>
 <5166B97D.60805@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5166B97D.60805@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 11, 2013 at 09:24:13PM +0800, fanchaoting wrote:
> 
> the "list_empty(&oo->oo_owner.so_stateids)" is aways true ,
> so we remove it.

Thanks!  Applying.--b.

> 
>  Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e27430..e9f1d37 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3830,8 +3830,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  			 * In the 4.0 case we need to keep the owners around a
>  			 * little while to handle CLOSE replay.
>  			 */
> -			if (list_empty(&oo->oo_owner.so_stateids))
> -				move_to_close_lru(oo, SVC_NET(rqstp));
> +			move_to_close_lru(oo, SVC_NET(rqstp));
>  		}
>  	}
>  out:
> -- 
> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
