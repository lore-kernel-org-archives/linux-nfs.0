Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3574 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129AbbAEU7H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 15:59:07 -0500
Message-ID: <54AAFB18.7040500@Netapp.com>
Date: Mon, 5 Jan 2015 15:59:04 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 20/49] nfs41: close a small race window when adding
 new layout to global list
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com> <1419405208-25975-21-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-21-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi again,

On 12/24/2014 02:12 AM, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> ---
>  fs/nfs/pnfs.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 2d25670..fa00b56 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1288,7 +1288,6 @@ pnfs_update_layout(struct inode *ino,
>  	struct nfs_client *clp = server->nfs_client;
>  	struct pnfs_layout_hdr *lo;
>  	struct pnfs_layout_segment *lseg = NULL;
> -	bool first;
>  
>  	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
>  		goto out;
> @@ -1321,16 +1320,15 @@ pnfs_update_layout(struct inode *ino,
>  	if (pnfs_layoutgets_blocked(lo, 0))
>  		goto out_unlock;
>  	atomic_inc(&lo->plh_outstanding);
> -
> -	first = list_empty(&lo->plh_layouts) ? true : false;
>  	spin_unlock(&ino->i_lock);
>  
> -	if (first) {
> +	if (list_empty(&lo->plh_layouts)) {
>  		/* The lo must be on the clp list if there is any
>  		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
>  		 */
>  		spin_lock(&clp->cl_lock);
> -		list_add_tail(&lo->plh_layouts, &server->layouts);
> +		if (list_empty(&lo->plh_layouts))
> +			list_add_tail(&lo->plh_layouts, &server->layouts);
>  		spin_unlock(&clp->cl_lock);
>  	}

Do we really need to call list_empty() twice?  Would there be a serious performance drawback if we removed the outer layer if condition and then always call list_empty() under the cl_lock?

Thanks,
Anna

>  
> 

