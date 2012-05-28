Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54347 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188Ab2E1Qxo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:53:44 -0400
Message-ID: <4FC3AD86.7040509@panasas.com>
Date: Mon, 28 May 2012 19:53:26 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] pnfsd: add debug printouts to pnfsd_roc
References: <4FC3A235.8090908@tonian.com> <1338221378-22567-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1338221378-22567-1-git-send-email-bhalevy@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 07:09 PM, Benny Halevy wrote:

> Signed-off-by: Benny Halevy <bhalevy@tonian.com>


Benny I disagree with this patch.

Not specifically with the print but with the !found print.

pnfsd_roc is always called layouts or not. So these
!found print are bogus.

> ---
>  fs/nfsd/nfs4pnfsd.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index cfaac56..0a8d5b5 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -1227,7 +1227,9 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
>  void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
>  {
>  	struct nfs4_layout *lo, *nextlp;
> +	bool found = false;
>  
> +	dprintk("%s: fp=%p clp=%p", __func__, fp, clp);
>  	spin_lock(&layout_lock);
>  	list_for_each_entry_safe (lo, nextlp, &fp->fi_layouts, lo_perfile) {
>  		struct nfsd4_pnfs_layoutreturn lr;
> @@ -1245,11 +1247,15 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
>  		destroy_layout(lo); /* do not access lp after this */
>  
>  		empty = list_empty(&fp->fi_layouts);
> +		found = true;
> +		dprintk("%s: fp=%p clp=%p: return on close", __func__, fp, clp);
>  		fs_layout_return(fp->fi_inode->i_sb, fp->fi_inode, &lr,
>  				 LR_FLAG_INTERN,
>  				 empty ? PNFS_LAST_LAYOUT_NO_RECALLS : NULL);


fs_layout_return already prints for each call. So we should only add one
global print so to know we came from ROC

Please don't fix it. I have this covered in my patches. In fact this
function is totally changed.

>  	}
>  	spin_unlock(&layout_lock);
> +	if (!found)
> +		dprintk("%s: no layout found", __func__);


Again please no prints here. pnfsd_roc is always called unconditionally
from last close.
(And found should be conditional on SUNRPC_DEBUG if is left)

>  }
>  
>  void pnfs_expire_client(struct nfs4_client *clp)


Thanks
Boaz
