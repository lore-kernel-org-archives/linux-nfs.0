Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21002 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964983Ab2CAPjh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 10:39:37 -0500
Message-ID: <4F4F9828.9040808@netapp.com>
Date: Thu, 01 Mar 2012 10:39:20 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSv4.1: Get rid of redundant NFS4CLNT_LAYOUTRECALL
 tests
References: <1330558445-4583-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330558445-4583-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/29/2012 06:34 PM, Trond Myklebust wrote:

> The NFS4CLNT_LAYOUTRECALL tests in pnfs_layout_process and
> pnfs_update_layout are redundant.
> 
> In the case of a bulk layout recall, we're always testing for
> the NFS_LAYOUT_BULK_RECALL flay anyway.
> In the case of a file or segment recall, the call to
> pnfs_set_layout_stateid() updates the layout_header 'barrier'
> sequence id, which triggers the test in pnfs_layoutgets_blocked()
> and is less race-prone than NFS4CLNT_LAYOUTRECALL anyway.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/pnfs.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a534216..9c19f92 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -966,8 +966,7 @@ pnfs_update_layout(struct inode *ino,
>  	}
>  
>  	/* Do we even need to bother with this? */
> -	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
> -	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
> +	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
>  		dprintk("%s matches recall, use MDS\n", __func__);
>  		goto out_unlock;
>  	}
> @@ -1048,8 +1047,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
>  	}
>  
>  	spin_lock(&ino->i_lock);
> -	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
> -	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {


This was the only place that the clp structure was used, so you could probably remove it to avoid this warning:

fs/nfs/pnfs.c: In function 'pnfs_layout_process':
fs/nfs/pnfs.c:1058:21: warning: unused variable 'clp' [-Wunused-variable]

- Bryan

> +	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
>  		dprintk("%s forget reply due to recall\n", __func__);
>  		goto out_forget_reply;
>  	}


