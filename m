From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 4/4] SQUASHME pnfs-submit: move layoutcommit to nfs_write_inode
Date: Tue, 08 Jun 2010 19:01:30 +0300
Message-ID: <4C0E695A.6090801@panasas.com>
References: <1275582327-9285-1-git-send-email-andros@netapp.com> <1275582327-9285-2-git-send-email-andros@netapp.com> <1275582327-9285-3-git-send-email-andros@netapp.com> <1275582327-9285-4-git-send-email-andros@netapp.com> <1275582327-9285-5-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: andros@netapp.com, Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42650 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751716Ab0FHQBe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 12:01:34 -0400
In-Reply-To: <1275582327-9285-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/03/2010 07:25 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The LAYOUTCOMMIT call indicates an update to the file meta data is needed,
> and should be called when clearing the I_DIRTY_SYNC state.
> 
> A call to LAYOUTCOMMIT in nfs_write_inode replaces the calls in nfs_wb_all,
> nfs_commit_inode, and __nfs4_close.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>

This patch no longer applies on 2.6.35-rc2 in write.c at nfs_commit_inode.
But it was easy enough to fix. (Benny tell me if you want a tree with these
in)

So I did a rough test "git clone linux" and cthon. It looks very good
(few comments below)

> ---
>  fs/nfs/nfs4state.c |    2 --
>  fs/nfs/pnfs.h      |    4 ++++
>  fs/nfs/write.c     |   24 ++++++++++++------------
>  3 files changed, 16 insertions(+), 14 deletions(-)
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
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index c89be78..009393e 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -256,6 +256,10 @@ static inline int pnfs_use_rpc(struct nfs_server *nfss)
>  	return 1;
>  }
>  
> +static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
> +{
> +	return 0;
> +}
>  #endif /* CONFIG_NFS_V4_1 */
>  

Just for correctness this patch belongs to [patch 3/4], for it to
compile independently.

If they are all squashed then that does not matter. Just as a note.
You might as well combine them.

>  #endif /* FS_NFS_PNFS_H */
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 0fd33cb..513b308 100644
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
> @@ -1545,7 +1538,18 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
>  
>  int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>  {
> -	return nfs_commit_unstable_pages(inode, wbc);
> +	int ret;
> +	ret = nfs_commit_unstable_pages(inode, wbc);
> +	if (ret >= 0 && layoutcommit_needed(NFS_I(inode))) {
> +		int err, sync = wbc->sync_mode;
> +
> +		if (wbc->nonblocking || wbc->for_background)
> +			sync = 0;
> +		err = pnfs_layoutcommit_inode(inode, sync);
> +		if (err < 0)
> +			ret = err;
> +	}
> +	return ret;
>  }
>  
>  /*
> @@ -1562,10 +1566,6 @@ int nfs_wb_all(struct inode *inode)
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

Grate stuff.
Boaz
