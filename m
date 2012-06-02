Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53145 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab2FBWeE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jun 2012 18:34:04 -0400
Message-ID: <4FCA94A6.3070105@panasas.com>
Date: Sun, 3 Jun 2012 01:33:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <andros@netapp.com>
CC: <trond.myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4.1 fence all layouts with file layout data server
 connection errors
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-3-git-send-email-andros@netapp.com>
In-Reply-To: <1338571178-2096-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2012 08:19 PM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 


The tittle does not match at all the message text nor the patch.

More like: Don't send LAYOUTCOMMIT if data is rewritten through MDS 

I think.
Boaz

> Clear the inode LAYOUTCOMMIT flag as we will resend writes through the MDS.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index e134029..96a75d1 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -205,8 +205,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>  	case -EPIPE:
>  		dprintk("%s DS connection error %d\n", __func__,
>  			task->tk_status);
> -		if (!filelayout_test_devid_invalid(devid))
> -			_pnfs_return_layout(inode);
> +		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
> +		_pnfs_return_layout(inode);
>  		filelayout_mark_devid_invalid(devid);
>  		rpc_wake_up(&tbl->slot_tbl_waitq);
>  		nfs4_ds_disconnect(clp);


