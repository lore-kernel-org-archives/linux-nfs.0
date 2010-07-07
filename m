From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 2/5] SQUASHME pnfs-submit remove pnfs_alloc_init_inode
Date: Wed, 07 Jul 2010 12:27:02 +0300
Message-ID: <4C344866.1070600@panasas.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com> <1278451022-2889-2-git-send-email-andros@netapp.com> <1278451022-2889-3-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:12346 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751768Ab0GGJ1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 05:27:05 -0400
In-Reply-To: <1278451022-2889-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/07/2010 12:16 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Place all layout initialization in nfs4_init_once
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/inode.c |   19 ++++++-------------
>  1 files changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 231cfa3..fa310b1 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1361,18 +1361,6 @@ void nfs4_clear_inode(struct inode *inode)
>  }
>  #endif
>  
> -static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
> -{
> -#ifdef CONFIG_NFS_V4_1
> -	nfsi->layout.pnfs_layout_state = 0;
> -	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
> -	nfsi->layout.roc_iomode = 0;
> -	nfsi->layout.lo_cred = NULL;
> -	nfsi->layout.pnfs_write_begin_pos = 0;
> -	nfsi->layout.pnfs_write_end_pos = 0;
> -#endif /* CONFIG_NFS_V4_1 */
> -}
> -
>  struct inode *nfs_alloc_inode(struct super_block *sb)
>  {
>  	struct nfs_inode *nfsi;
> @@ -1388,7 +1376,6 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
>  #ifdef CONFIG_NFS_V4
>  	nfsi->nfs4_acl = NULL;
>  #endif /* CONFIG_NFS_V4 */
> -	pnfs_alloc_init_inode(nfsi);
>  	return &nfsi->vfs_inode;
>  }
>  
> @@ -1430,6 +1417,12 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
>  	INIT_LIST_HEAD(&nfsi->layout.segs);
>  	nfsi->layout.refcount = 0;
>  	nfsi->layout.ld_data = NULL;
> +	nfsi->layout.pnfs_layout_state = 0;
> +	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
> +	nfsi->layout.roc_iomode = 0;
> +	nfsi->layout.lo_cred = NULL;
> +	nfsi->layout.pnfs_write_begin_pos = 0;
> +	nfsi->layout.pnfs_write_end_pos = 0;

If we are already here. What are the rules with zeros? It is costume elsewhere in
Kernel that at construction points all zeros are just not done, if a kzalloc or memset
is guaranteed. Isn't nfs_inode zero_allocated? If not it should. Adding zero initialization
to every new member, and an extra remove line to any member remove is just maintenance
nightmare.

(This patch could be much more beautiful if it was "only removed lines")

Boaz


>  #endif /* CONFIG_NFS_V4_1 */
>  #endif
>  }

