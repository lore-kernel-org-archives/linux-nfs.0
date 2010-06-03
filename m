From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 4/6] SQUASHME pnfs-submit: cleanup layoutcommit call
Date: Thu, 03 Jun 2010 10:35:49 +0300
Message-ID: <4C075B55.7010604@panasas.com>
References: <1275494067-4058-1-git-send-email-andros@netapp.com> <1275494067-4058-2-git-send-email-andros@netapp.com> <1275494067-4058-3-git-send-email-andros@netapp.com> <1275494067-4058-4-git-send-email-andros@netapp.com> <1275494067-4058-5-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17249 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755593Ab0FCHfw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 03:35:52 -0400
In-Reply-To: <1275494067-4058-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/02/2010 06:54 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> pnfs_layoutcommit_inode prints its status upon exit.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c |   11 ++---------
>  1 files changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index def27f8..91e944a 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -766,15 +766,8 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
>  				!pnfs_return_layout_barrier(nfsi, &arg));
>  		}
>  
> -		if (layoutcommit_needed(nfsi)) {
> -			status = pnfs_layoutcommit_inode(ino, wait);
> -			if (status) {
> -				dprintk("%s: layoutcommit failed, status=%d. "
> -					"Returning layout anyway\n",
> -					__func__, status);
> -				status = 0;
> -			}
> -		}
> +		if (layoutcommit_needed(nfsi))
> +			pnfs_layoutcommit_inode(ino, wait);

The print was not for the fail but for the status ignored by
layout_return. But ye we can do with out.

But please leave a big comment why we ignore the status from
pnfs_layoutcommit_inode.

Boaz
>  	}
>  send_return:
>  	status = return_layout(ino, &arg, stateid, type, lo, wait);

