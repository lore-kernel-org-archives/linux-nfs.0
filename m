From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] pnfs-submit: test for sending LAYOUTRETURN was reversed
Date: Tue, 15 Jun 2010 15:51:51 -0400
Message-ID: <4C17D9D7.3070207@panasas.com>
References: <1276578117-22597-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52704 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751916Ab0FOTvu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 15:51:50 -0400
In-Reply-To: <1276578117-22597-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 15, 2010, 1:01 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> Setting this correctly also simplifies the call to layout_return.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>

Merged at pnfs-all-2.6.35-rc3-2010-06-15

Thanks!

Benny

> ---
>  fs/nfs/pnfs.c |   11 +++--------
>  1 files changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index edffee3..56d2932 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -731,7 +731,6 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  
>  static int
>  return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
> -	      const nfs4_stateid *stateid, /* optional */
>  	      enum pnfs_layoutreturn_type type, struct pnfs_layout_type *lo,
>  	      bool wait)
>  {
> @@ -755,10 +754,7 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  	lrp->args.lseg = *range;
>  	lrp->args.inode = ino;
>  	lrp->lo = lo;
> -	if (stateid)
> -		lrp->args.stateid = *stateid;
> -	else if (lo)
> -		pnfs_get_layout_stateid(&lrp->args.stateid, lo);
> +	pnfs_get_layout_stateid(&lrp->args.stateid, lo);
>  
>  	status = pnfs4_proc_layoutreturn(lrp, wait);
>  out:
> @@ -830,9 +826,8 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  			}
>  		}
>  
> -		if (stateid && wait)
> -			status = return_layout(ino, &arg, stateid, type,
> -					       lo, wait);
> +		if (!stateid)
> +			status = return_layout(ino, &arg, type, lo, wait);
>  		else
>  			pnfs_layout_release(lo, &arg);
>  	}


-- 
Benny Halevy
Software Architect
Panasas, Inc.
bhalevy@panasas.com
Tel/Fax: +972-3-647-8340
Mobile: +972-54-802-8340

Panasas: The Leader in Parallel Storage
www.panasas.com
