From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 6/6] SQUASHME pnfs-submit: move layoutcommit to nfs_write_inode
Date: Thu, 03 Jun 2010 10:44:35 +0300
Message-ID: <4C075D63.2080105@panasas.com>
References: <1275494067-4058-1-git-send-email-andros@netapp.com> <1275494067-4058-2-git-send-email-andros@netapp.com> <1275494067-4058-3-git-send-email-andros@netapp.com> <1275494067-4058-4-git-send-email-andros@netapp.com> <1275494067-4058-5-git-send-email-andros@netapp.com> <1275494067-4058-6-git-send-email-andros@netapp.com> <1275494067-4058-7-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13217 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752486Ab0FCHoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 03:44:37 -0400
In-Reply-To: <1275494067-4058-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/02/2010 06:54 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The LAYOUTCOMMIT call indicates an update to the file meta data is needed,
> and should be called when clearing the I_DIRTY_SYNC state.
> 
> A call to LAYOUTCOMMIT in nfs_write_inode replaces the calls in nfs_wb_all,
> nfs_commit_inode, and __nfs4_close.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4state.c |    2 --
>  fs/nfs/write.c     |   22 ++++++++++------------
>  2 files changed, 10 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index d0dbdd4..e1207fa 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -589,8 +589,6 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
>  #ifdef CONFIG_NFS_V4_1
>  		struct nfs_inode *nfsi = NFS_I(state->inode);
>  
> -		if (layoutcommit_needed(nfsi))
> -			pnfs_layoutcommit_inode(state->inode, wait);
>  		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
>  			struct nfs4_pnfs_layout_segment range;
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 0fd33cb..875d07f 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1489,13 +1489,6 @@ static int nfs_commit_inode(struct inode *inode, int how)
>  			wait_on_bit(&NFS_I(inode)->flags, NFS_INO_COMMIT,
>  					nfs_wait_bit_killable,
>  					TASK_KILLABLE);
> -#ifdef CONFIG_NFS_V4_1
> -		if (may_wait && layoutcommit_needed(NFS_I(inode))) {
> -			error = pnfs_layoutcommit_inode(inode, 1);
> -			if (error < 0)
> -				return error;
> -		}
> -#endif /* CONFIG_NFS_V4_1 */
>  	} else
>  		nfs_commit_clear_lock(NFS_I(inode));
>  out:
> @@ -1545,7 +1538,16 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
>  
>  int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>  {
> -	return nfs_commit_unstable_pages(inode, wbc);
> +	int ret;
> +	ret = nfs_commit_unstable_pages(inode, wbc);
> +#ifdef CONFIG_NFS_V4_1
> +	if (ret >= 0 && layoutcommit_needed(NFS_I(inode))) {
> +		int err = pnfs_layoutcommit_inode(inode, 1);
> +		if (err < 0)
> +			ret = err;
> +	}
> +#endif /* CONFIG_NFS_V4_1 */

Here you should do better. Now that it's so easy for sure.

define an inline called pnfs_layoutcommit_inode that does
the if() and calls a _pnfs_layoutcommit_inode(). The later
is today's original function.

In header define that inline for the pnfs case and define
an empty one returning 0 for the not CONFIG_NFS_V4_1 case.

I had a patch like that but after your patch it is much
easier and makes more sense.

I would fold it into this patch.

Boaz
> +	return ret;
>  }
>  
>  /*
> @@ -1562,10 +1564,6 @@ int nfs_wb_all(struct inode *inode)
>  	};
>  
>  	ret = sync_inode(inode, &wbc);
> -#ifdef CONFIG_NFS_V4_1
> -	if (!ret && layoutcommit_needed(NFS_I(inode)))
> -		ret = pnfs_layoutcommit_inode(inode, 1);
> -#endif
>  	return ret;
>  }
>  

