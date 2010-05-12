Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:17678 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab0ELGvS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 02:51:18 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1741955fgg.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 23:51:17 -0700 (PDT)
Message-ID: <4BEA4FE2.9070409@panasas.com>
Date: Wed, 12 May 2010 09:51:14 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
CC: linux-nfs@vger.kernel.org, iisaman@citi.umich.edu
Subject: Re: [PATCH] pnfs: send layoutcommit until IO completed when return
 layout
References: <20100511085943.GA6822@MDS-78.localdomain>
In-Reply-To: <20100511085943.GA6822@MDS-78.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On May. 11, 2010, 11:59 +0300, Zhang Jingwang <zhangjingwang@nrchpc.ac.cn> wrote:
> If we call layoutcommit before IO completed, then some extents we are
> writing may not be in the commit list. When we return layout, they
> may not get a chance to be committed to server.
> 
> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
> ---
>  fs/nfs/pnfs.c |   20 ++++++++++----------
>  1 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 3739c38..6fa295b 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -726,16 +726,6 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  		arg.length = ~0;
>  	}
>  	if (type == RETURN_FILE) {
> -		if (nfsi->layoutcommit_ctx) {
> -			status = pnfs_layoutcommit_inode(ino, 1);
> -			if (status) {
> -				dprintk("%s: layoutcommit failed, status=%d. "
> -					"Returning layout anyway\n",
> -					__func__, status);
> -				status = 0;
> -			}
> -		}
> -
>  		lo = get_lock_current_layout(nfsi);
>  		if (lo && !has_layout_to_return(lo, &arg)) {
>  			put_unlock_current_layout(lo);
> @@ -763,6 +753,16 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  			wait_event(nfsi->lo_waitq,
>  				!pnfs_return_layout_barrier(nfsi, &arg));
>  		}
> +
> +		if (nfsi->layoutcommit_ctx) {
> +			status = pnfs_layoutcommit_inode(ino, 1);
> +			if (status) {
> +				dprintk("%s: layoutcommit failed, status=%d. "
> +					"Returning layout anyway\n",
> +					__func__, status);
> +				status = 0;
> +			}
> +		}

OK, I guess doing that after the send_return label is superfluous
as there should be nothing to layoutcommit if we got there after finding
no layout to return.

Benny

>  	}
>  send_return:
>  	status = return_layout(ino, &arg, stateid, type, lo);

