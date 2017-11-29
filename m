Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:17118 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751254AbdK2Tkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 14:40:31 -0500
Subject: Re: [PATCH] nfs: make pnfs_destroy_layout() wait on commit when inode
 is being evicted
To: Scott Mayhew <smayhew@redhat.com>,
        <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
References: <20171120214312.5263-1-smayhew@redhat.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <685ffa52-4800-c111-eaac-81442bf4ac79@Netapp.com>
Date: Wed, 29 Nov 2017 14:40:24 -0500
MIME-Version: 1.0
In-Reply-To: <20171120214312.5263-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott,

On 11/20/2017 04:43 PM, Scott Mayhew wrote:
> Otherwise nfs_commit_inode() can set I_DIRTY_DATASYNC in the inode's
> i_state, allowing the following BUG_ON in evict() to be triggered:
> 
>         BUG_ON(inode->i_state != (I_FREEING | I_CLEAR));
> 
> Fixes: 1f18b82c3437 ("pNFS: Ensure we commit the layout if it has been...")
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> Tested-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  fs/nfs/filelayout/filelayout.c         | 2 +-
>  fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
>  fs/nfs/nfs4super.c                     | 2 +-
>  fs/nfs/pnfs.c                          | 6 +++---
>  fs/nfs/pnfs.h                          | 2 +-
>  5 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
> index 4e54d8b..28b7228 100644
> --- a/fs/nfs/filelayout/filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -169,7 +169,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>  		 * i/o and all i/o waiting on the slot table to the MDS until
>  		 * layout is destroyed and a new valid layout is obtained.
>  		 */
> -		pnfs_destroy_layout(NFS_I(inode));
> +		pnfs_destroy_layout(NFS_I(inode), 0);
>  		rpc_wake_up(&tbl->slot_tbl_waitq);
>  		goto reset;
>  	/* RPC connection errors */
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index c75ad98..ab0a1e5 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1088,7 +1088,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
>  		 * i/o and all i/o waiting on the slot table to the MDS until
>  		 * layout is destroyed and a new valid layout is obtained.
>  		 */
> -		pnfs_destroy_layout(NFS_I(inode));
> +		pnfs_destroy_layout(NFS_I(inode), 0);
>  		rpc_wake_up(&tbl->slot_tbl_waitq);
>  		goto reset;
>  	/* RPC connection errors */
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 6fb7cb6..3b4a063 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -95,7 +95,7 @@ static void nfs4_evict_inode(struct inode *inode)
>  	nfs_inode_return_delegation_noreclaim(inode);
>  	/* Note that above delegreturn would trigger pnfs return-on-close */
>  	pnfs_return_layout(inode);
> -	pnfs_destroy_layout(NFS_I(inode));
> +	pnfs_destroy_layout(NFS_I(inode), FLUSH_SYNC);
>  	/* First call standard NFS clear_inode() code */
>  	nfs_clear_inode(inode);
>  }
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index d602fe9..09e66a8 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -696,7 +696,7 @@ pnfs_free_lseg_list(struct list_head *free_me)
>  }
>  
>  void
> -pnfs_destroy_layout(struct nfs_inode *nfsi)
> +pnfs_destroy_layout(struct nfs_inode *nfsi, int how)
>  {
>  	struct pnfs_layout_hdr *lo;
>  	LIST_HEAD(tmp_list);
> @@ -710,7 +710,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
>  		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
>  		spin_unlock(&nfsi->vfs_inode.i_lock);
>  		pnfs_free_lseg_list(&tmp_list);
> -		nfs_commit_inode(&nfsi->vfs_inode, 0);
> +		nfs_commit_inode(&nfsi->vfs_inode, how);
>  		pnfs_put_layout_hdr(lo);
>  	} else
>  		spin_unlock(&nfsi->vfs_inode.i_lock);
> @@ -1849,7 +1849,7 @@ pnfs_update_layout(struct inode *ino,
>  			}
>  			/* Destroy the existing layout and start over */
>  			if (time_after(jiffies, giveup))
> -				pnfs_destroy_layout(NFS_I(ino));
> +				pnfs_destroy_layout(NFS_I(ino), 0);
>  			/* Fallthrough */
>  		case -EAGAIN:
>  			break;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 8d507c3..3fe2160 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -245,7 +245,7 @@ size_t pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
>  void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
>  struct pnfs_layout_segment *pnfs_layout_process(struct nfs4_layoutget *lgp);
>  void pnfs_free_lseg_list(struct list_head *tmp_list);
> -void pnfs_destroy_layout(struct nfs_inode *);
> +void pnfs_destroy_layout(struct nfs_inode *, int how);

Can you also update the fallback pnfs_destroy_layout() for when CONFIG_NFS_V4_1=n?

fs/nfs/nfs4super.c: In function 'nfs4_evict_inode':
fs/nfs/nfs4super.c:98:2: error: too many arguments to function 'pnfs_destroy_layout'
  pnfs_destroy_layout(NFS_I(inode), FLUSH_SYNC);
  ^~~~~~~~~~~~~~~~~~~
In file included from fs/nfs/nfs4super.c:13:0:
fs/nfs/pnfs.h:627:20: note: declared here
 static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
                    ^~~~~~~~~~~~~~~~~~~

Thanks,
Anna

>  void pnfs_destroy_all_layouts(struct nfs_client *);
>  int pnfs_destroy_layouts_byfsid(struct nfs_client *clp,
>  		struct nfs_fsid *fsid,
> 
