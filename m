Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16558 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571Ab0LPMrp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 07:47:45 -0500
Message-ID: <4D0A0A6D.5060807@panasas.com>
Date: Thu, 16 Dec 2010 14:47:41 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>, Benny Halevy <bhalevy@panasas.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 20/22] pnfs-submit: wave2: remove all LAYOUTRETURN code
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com> <1291944177-7819-21-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-21-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/10/2010 03:22 AM, Fred Isaman wrote:

> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -599,55 +599,6 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
>  		}
>  }
>  
> -/* Return true if there is layout based io in progress in the given range.
> - * Assumes range has already been marked invalid, and layout marked to
> - * prevent any new lseg from being inserted.
> - */
> -bool
> -pnfs_return_layout_barrier(struct nfs_inode *nfsi,
> -			   struct pnfs_layout_range *range)
> -{
> -	struct pnfs_layout_segment *lseg;
> -	bool ret = false;
> -
> -	spin_lock(&nfsi->vfs_inode.i_lock);
> -	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list)
> -		if (should_free_lseg(&lseg->range, range)) {
> -			ret = true;
> -			break;
> -		}
> -	spin_unlock(&nfsi->vfs_inode.i_lock);
> -	dprintk("%s:Return %d\n", __func__, ret);
> -	return ret;
> -}
> -
> -static int
> -return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
> -{
> -	struct nfs4_layoutreturn *lrp;
> -	struct nfs_server *server = NFS_SERVER(ino);
> -	int status = -ENOMEM;
> -
> -	dprintk("--> %s\n", __func__);
> -
> -	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> -	if (lrp == NULL) {
> -		put_layout_hdr(ino);
> -		goto out;
> -	}
> -	lrp->args.reclaim = 0;
> -	lrp->args.layout_type = server->pnfs_curr_ld->id;
> -	lrp->args.return_type = RETURN_FILE;
> -	lrp->args.range = *range;
> -	lrp->args.inode = ino;
> -	lrp->clp = server->nfs_client;
> -
> -	status = nfs4_proc_layoutreturn(lrp, wait);
> -out:
> -	dprintk("<-- %s status: %d\n", __func__, status);
> -	return status;
> -}
> -
>  /* Initiates a LAYOUTRETURN(FILE) */
>  int
>  _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
> @@ -673,21 +624,10 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
>  		goto out;
>  	}
>  	lo->plh_block_lgets++;
> -	/* Reference matched in nfs4_layoutreturn_release */
> -	get_layout_hdr(lo);
>  	spin_unlock(&ino->i_lock);
>  	pnfs_free_lseg_list(&tmp_list);
>  
> -	if (layoutcommit_needed(nfsi)) {
> -		status = pnfs_layoutcommit_inode(ino, wait);
> -		if (status) {
> -			/* Return layout even if layoutcommit fails */
> -			dprintk("%s: layoutcommit failed, status=%d. "
> -				"Returning layout anyway\n",
> -				__func__, status);
> -		}
> -	}
> -	status = return_layout(ino, &arg, wait);


You are also removing the layoutcommit.
1. You have not stated it anywhere, and snacked it in silently
2. If you are removing layoutcommit please do that in a different
   patch with it's own comment and explanation.
3. How come? forgetful or not layoutcommits are a different issue
   and must be done correctly when writing !!!?!

Boaz
> +	/* Don't need to wait since this is followed by call to end_writeback */
>  out:
>  	dprintk("<-- %s status: %d\n", __func__, status);
>  	return status;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index d999e38..0ddab0d 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -183,7 +183,6 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
>  extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>  extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
>  				   int issync);
> -extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
>  
>  /* pnfs.c */
>  void get_layout_hdr(struct pnfs_layout_hdr *lo);
> @@ -193,7 +192,6 @@ bool should_free_lseg(struct pnfs_layout_range *lseg_range,
>  struct pnfs_layout_segment *
>  pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>  		   enum pnfs_iomode access_type);
> -bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
>  int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
>  void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>  void unset_pnfs_layoutdriver(struct nfs_server *);

