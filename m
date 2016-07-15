Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:35215 "EHLO
	mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcGOOi1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2016 10:38:27 -0400
Received: by mail-qt0-f178.google.com with SMTP id j35so60356789qtj.2
        for <linux-nfs@vger.kernel.org>; Fri, 15 Jul 2016 07:38:27 -0700 (PDT)
Message-ID: <1468593503.3584.3.camel@redhat.com>
Subject: Re: [PATCH 2/4] pNFS: Separate handling of NFS4ERR_LAYOUTTRYLATER
 and RECALLCONFLICT
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Date: Fri, 15 Jul 2016 10:38:23 -0400
In-Reply-To: <1468537115-65826-2-git-send-email-trond.myklebust@primarydata.com>
References: <1468537115-65826-1-git-send-email-trond.myklebust@primarydata.com>
	 <1468537115-65826-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-07-14 at 18:58 -0400, Trond Myklebust wrote:
> They are not the same error, and need to be handled differently.
> 
> Fixes: 183d9e7b112aa ("pnfs: rework LAYOUTGET retry handling")
> Cc: stable@vger.kernel.org # 4.7
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 23 ++++++++++++++---------
>  fs/nfs/pnfs.c     |  1 +
>  2 files changed, 15 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 519368b98762..ee8efe0a5202 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -437,6 +437,7 @@ static int nfs4_do_handle_exception(struct
> nfs_server *server,
>  		case -NFS4ERR_DELAY:
>  			nfs_inc_server_stats(server, NFSIOS_DELAY);
>  		case -NFS4ERR_GRACE:
> +		case -NFS4ERR_LAYOUTTRYLATER:
>  		case -NFS4ERR_RECALLCONFLICT:
>  			exception->delay = 1;
>  			return 0;
> @@ -7883,11 +7884,12 @@ nfs4_layoutget_handle_exception(struct
> rpc_task *task,
>  	struct inode *inode = lgp->args.inode;
>  	struct nfs_server *server = NFS_SERVER(inode);
>  	struct pnfs_layout_hdr *lo;
> -	int status = task->tk_status;
> +	int nfs4err = task->tk_status;
> +	int err, status = 0;
>  
>  	dprintk("--> %s tk_status => %d\n", __func__, -task-
> >tk_status);
>  
> -	switch (status) {
> +	switch (nfs4err) {
>  	case 0:
>  		goto out;
>  
> @@ -7919,12 +7921,11 @@ nfs4_layoutget_handle_exception(struct
> rpc_task *task,
>  			status = -EOVERFLOW;
>  			goto out;
>  		}
> -		/* Fallthrough */
> +		status = -EBUSY;
> +		break;

May also want to update the comment above this stanza. It says that we
treat the two cases identically, but I'm not sure that that is valid
now.

>  	case -NFS4ERR_RECALLCONFLICT:
> -		nfs4_handle_exception(server,
> -NFS4ERR_RECALLCONFLICT,
> -					exception);
>  		status = -ERECALLCONFLICT;
> -		goto out;
> +		break;
>  	case -NFS4ERR_EXPIRED:
>  	case -NFS4ERR_BAD_STATEID:
>  		exception->timeout = 0;
> @@ -7955,9 +7956,13 @@ nfs4_layoutget_handle_exception(struct
> rpc_task *task,
>  			spin_unlock(&inode->i_lock);
>  	}
>  
> -	status = nfs4_handle_exception(server, status, exception);
> -	if (exception->retry)
> -		status = -EAGAIN;
> +	err = nfs4_handle_exception(server, nfs4err, exception);
> +	if (!status) {
> +		if (exception->retry)
> +			status = -EAGAIN;
> +		else
> +			status = err;
> +	}
>  out:
>  	dprintk("<-- %s\n", __func__);
>  	return status;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 73b0dc90265a..b5c1306f63c1 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1648,6 +1648,7 @@ lookup_again:
>  	atomic_dec(&lo->plh_outstanding);
>  	if (IS_ERR(lseg)) {
>  		switch(PTR_ERR(lseg)) {
> +		case -EBUSY:
>  		case -ERECALLCONFLICT:
>  			if (time_after(jiffies, giveup))
>  				lseg = NULL;

-- 

Jeff Layton <jlayton@redhat.com>
