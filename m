Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53761 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbaLPVMD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2014 16:12:03 -0500
Message-ID: <5490A020.1060000@Netapp.com>
Date: Tue, 16 Dec 2014 16:12:00 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 39/50] nfs/flexfiles: send layoutreturn before freeing
 lseg
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com> <1418756513-95187-40-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-40-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/16/2014 02:01 PM, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> Otherwise we'll lose error tracking information when
> encoding layoutreturn.
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index e123cfc..35465cb 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -355,7 +355,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
>  		return false;
>  
>  	list_for_each_entry(s, &lo->plh_segs, pls_list)
> -		if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
> +		if (s != lseg && test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
>  			return false;
>  
>  	*stateid = lo->plh_stateid;
> @@ -386,15 +386,22 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
>  		enum pnfs_iomode iomode;
>  
>  		pnfs_get_layout_hdr(lo);
> -		pnfs_layout_remove_lseg(lo, lseg);
>  		need_return = pnfs_layout_need_return(lo, lseg,
>  						      &stateid, &iomode);
> -		spin_unlock(&inode->i_lock);
> -		pnfs_free_lseg(lseg);
> -		if (need_return)
> +		if (need_return) {
> +			spin_unlock(&inode->i_lock);
> +			/* hdr reference dropped in nfs4_layoutreturn_release */
>  			pnfs_send_layoutreturn(lo, stateid, iomode);
> -		else
> +			spin_lock(&inode->i_lock);
> +			pnfs_layout_remove_lseg(lo, lseg);
> +			spin_unlock(&inode->i_lock);
> +			pnfs_free_lseg(lseg);
> +		} else {
> +			pnfs_layout_remove_lseg(lo, lseg);
> +			spin_unlock(&inode->i_lock);
> +			pnfs_free_lseg(lseg);
>  			pnfs_put_layout_hdr(lo);
> +		}

Is there a way to rephrase this so we're not using every other line to either lock or unlock?

Anna

>  	}
>  }
>  EXPORT_SYMBOL_GPL(pnfs_put_lseg);
> 

